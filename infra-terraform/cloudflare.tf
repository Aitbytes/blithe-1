provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

resource "cloudflare_dns_record" "main_dns_record" {
  zone_id = var.cloudflare_zone_id
  # comment = "Domain verification record"
  content = hcloud_server.nodes[0].ipv4_address  # Assuming you want to use the first node's IP
  name = var.dns_record_name
  proxied = false
  ttl = 3600
  type = "A"
  lifecycle {
    create_before_destroy = true
  }
}

resource "cloudflare_dns_record" "wildcard_subdomain" {
  zone_id = var.cloudflare_zone_id
  content = hcloud_server.nodes[0].ipv4_address
  name    = "*"
  proxied = false
  ttl     = 3600
  type    = "A"
  lifecycle {
    create_before_destroy = true
  }
}
