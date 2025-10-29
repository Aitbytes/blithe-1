#!/usr/bin/env python3
import os
import json
import hvac
import yaml
import argparse
import sys

def eprint(*args, **kwargs):
    """Prints to stderr."""
    print(*args, file=sys.stderr, **kwargs)

def get_vault_client():
    """Initializes and returns an authenticated HVAC client."""
    eprint("DEBUG: Attempting to get Vault client.")
    vault_addr = os.environ.get('VAULT_ADDR')
    vault_token = os.environ.get('VAULT_TOKEN')
    eprint(f"DEBUG: VAULT_ADDR found: {vault_addr is not None}")
    eprint(f"DEBUG: VAULT_TOKEN found: {vault_token is not None}")

    if not vault_addr or not vault_token:
        raise ValueError("VAULT_ADDR and VAULT_TOKEN environment variables must be set.")

    client = hvac.Client(url=vault_addr, token=vault_token)
    eprint("DEBUG: HVAC client created. Checking authentication.")
    if not client.is_authenticated():
        raise ConnectionError("Failed to authenticate with Vault. Check your token.")
    eprint("DEBUG: Vault client authenticated successfully.")
    return client

def read_inventory_from_vault(client):
    """Reads the Ansible inventory from a Vault KV secret."""
    secret_path = 'blithe/ansible-inventory/proxmox-vnet'
    mount_point = 'kv'
    eprint(f"DEBUG: Reading inventory from Vault at {mount_point}/{secret_path}")
    
    try:
        secret = client.secrets.kv.v2.read_secret_version(
            path=secret_path,
            mount_point=mount_point,
            raise_on_deleted_version=True,
        )
        eprint("DEBUG: Successfully read secret from Vault.")
        inventory_yaml = secret['data']['data']['inventory']
        eprint("DEBUG: Extracted inventory YAML from secret.")
        return yaml.safe_load(inventory_yaml)
    except Exception as e:
        eprint(f"DEBUG: An exception occurred while reading from Vault: {e}")
        raise RuntimeError(f"Failed to read inventory from Vault at {mount_point}/{secret_path}: {e}")

def format_for_ansible(inventory_data):
    """
    Builds the full Ansible inventory structure from the source data,
    ensuring it's in a format Ansible can parse.
    """
    eprint("DEBUG: Formatting data for Ansible.")
    ansible_inventory = {
        "all": {
            "children": []
        },
        "_meta": {
            "hostvars": {}
        }
    }

    source_children = inventory_data.get('all', {}).get('children', {})
    
    for group_name, group_data in source_children.items():
        # Add group to the 'all' children list
        ansible_inventory["all"]["children"].append(group_name)
        
        # Create the group with its hosts
        ansible_inventory[group_name] = {
            "hosts": list(group_data.get("hosts", {}).keys())
        }
        
        # Populate hostvars from the group's hosts
        for host, variables in group_data.get("hosts", {}).items():
            # Only add non-empty host variable dicts
            if variables:
                ansible_inventory["_meta"]["hostvars"][host] = variables

    eprint("DEBUG: Formatting complete.")
    return ansible_inventory

def get_host_vars(inventory_data, hostname):
    """Returns the variables for a specific host."""
    # In the new flat structure, all host variables are in the network_appliances group.
    try:
        return inventory_data['all']['children']['network_appliances']['hosts'][hostname]
    except KeyError:
        return {}

def main():
    """Main function to fetch, format, and print the inventory."""
    eprint("DEBUG: Dynamic inventory script started.")
    parser = argparse.ArgumentParser()
    parser.add_argument('--list', action='store_true')
    parser.add_argument('--host', type=str)
    args = parser.parse_args()
    eprint(f"DEBUG: Parsed arguments: {args}")

    try:
        client = get_vault_client()
        inventory = read_inventory_from_vault(client)
        eprint("DEBUG: Inventory read from Vault successfully.")
        
        if not inventory or not inventory.get("all"):
            raise ValueError("Inventory data read from Vault is empty or malformed.")
        eprint("DEBUG: Inventory data is valid.")

        if args.host:
            eprint(f"DEBUG: Getting vars for host: {args.host}")
            host_vars = get_host_vars(inventory, args.host)
            print(json.dumps(host_vars, indent=4))
        else:
            eprint("DEBUG: Listing all hosts.")
            ansible_inventory = format_for_ansible(inventory)
            print(json.dumps(ansible_inventory, indent=4))
        eprint("DEBUG: Script finished successfully.")

    except (ValueError, ConnectionError, RuntimeError) as e:
        eprint(f"DEBUG: An error occurred: {e}")
        print(json.dumps({"_meta": {"hostvars": {}}, "error": str(e)}))
        exit(1)

if __name__ == '__main__':
    main()