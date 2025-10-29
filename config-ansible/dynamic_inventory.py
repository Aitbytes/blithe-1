#!/usr/bin/env python3
import os
import json
import hvac
import yaml
import argparse
import sys

def get_vault_client():
    """Initializes and returns an authenticated HVAC client."""
    vault_addr = os.environ.get('VAULT_ADDR')
    vault_token = os.environ.get('VAULT_TOKEN')

    if not vault_addr or not vault_token:
        raise ValueError("VAULT_ADDR and VAULT_TOKEN environment variables must be set.")

    client = hvac.Client(url=vault_addr, token=vault_token)
    if not client.is_authenticated():
        raise ConnectionError("Failed to authenticate with Vault. Check your token.")
    return client

def read_inventory_from_vault(client):
    """Reads the Ansible inventory from a Vault KV secret."""
    secret_path = 'blithe/ansible-inventory/proxmox-vnet'
    mount_point = 'kv'
    
    try:
        secret = client.secrets.kv.v2.read_secret_version(
            path=secret_path,
            mount_point=mount_point,
            raise_on_deleted_version=True,
        )
        inventory_yaml = secret['data']['data']['inventory']
        return yaml.safe_load(inventory_yaml)
    except Exception as e:
        raise RuntimeError(f"Failed to read inventory from Vault at {mount_point}/{secret_path}: {e}")

def format_for_ansible(inventory_data):
    """
    Builds the full Ansible inventory structure from the source data,
    ensuring it's in a format Ansible can parse.
    """
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
    parser = argparse.ArgumentParser()
    parser.add_argument('--list', action='store_true')
    parser.add_argument('--host', type=str)
    args = parser.parse_args()

    try:
        client = get_vault_client()
        inventory = read_inventory_from_vault(client)
        
        if not inventory or not inventory.get("all"):
            raise ValueError("Inventory data read from Vault is empty or malformed.")

        if args.host:
            host_vars = get_host_vars(inventory, args.host)
            print(json.dumps(host_vars, indent=4))
        else:
            ansible_inventory = format_for_ansible(inventory)
            print(json.dumps(ansible_inventory, indent=4))

    except (ValueError, ConnectionError, RuntimeError) as e:
        print(json.dumps({"_meta": {"hostvars": {}}, "error": str(e)}))
        exit(1)

if __name__ == '__main__':
    main()
