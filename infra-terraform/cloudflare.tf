provider "cloudflare" {
  api_token = local.cloudflare_config.api_token
}

resource "cloudflare_dns_record" "main_dns_record" {
  zone_id = local.cloudflare_config.zone_id
  # comment = "Domain verification record"
  content = hcloud_server.nodes[0].ipv4_address  # Assuming you want to use the first node's IP
  name = local.cloudflare_config.record_name
  proxied = false
  ttl = 3600
  type = "A"
  lifecycle {
    create_before_destroy = true
  }
}

resource "cloudflare_dns_record" "wildcard_subdomain" {
  zone_id = local.cloudflare_config.zone_id
  content = hcloud_server.nodes[0].ipv4_address
  name    = "*"
  proxied = false
  ttl     = 3600
  type    = "A"
  lifecycle {
    create_before_destroy = true
  }
}
