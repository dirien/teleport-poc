data "digitalocean_domain" "domain" {
  name = var.domain
}

resource "digitalocean_record" "teleport" {
  domain = data.digitalocean_domain.domain.name
  type   = "A"
  name   = "teleport"
  value  = aws_eip.teleport-eip-manager.public_ip
  ttl    = 60
}

resource "digitalocean_record" "teleport-wild" {
  domain = data.digitalocean_domain.domain.name
  type   = "A"
  name   = "*.teleport"
  value  = aws_eip.teleport-eip-manager.public_ip
  ttl    = 60
}