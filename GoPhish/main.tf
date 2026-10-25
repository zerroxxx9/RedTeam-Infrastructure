terraform {
  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "~> 1.48"
    }
  }
}

provider "hcloud" {
  token = var.hcloud_token
}

resource "hcloud_ssh_key" "admin" {
  name       = "gophish-admin"
  public_key = var.ssh_public_key
}

resource "hcloud_firewall" "gophish" {
  name = "gophish-fw"

  rule {
    direction  = "in"
    protocol   = "tcp"
    port       = "22"
    source_ips = [var.admin_ssh_source_ip]
  }

  # Phishing landing site
  rule {
    direction  = "in"
    protocol   = "tcp"
    port       = "80"
    source_ips = ["0.0.0.0/0", "::/0"]
  }
  rule {
    direction  = "in"
    protocol   = "tcp"
    port       = "443"
    source_ips = ["0.0.0.0/0", "::/0"]
  }

}

resource "hcloud_server" "gophish" {
  name        = var.server_name
  image       = "ubuntu-24.04"
  server_type = var.server_type
  location    = var.server_location
  ssh_keys    = [hcloud_ssh_key.admin.id]
  firewall_ids = [hcloud_firewall.gophish.id]

  user_data = templatefile("${path.module}/cloud-init.yaml.tftpl", {
    gophish_version = var.gophish_version
    phish_domain    = var.phish_domain
  })

  labels = {
    purpose = "phishing-sim"
  }
}

output "server_ipv4" {
  value       = hcloud_server.gophish.ipv4_address
  description = "Point your phish_domain A record at this address."
}

output "next_steps" {
  value = <<-EOT
    1. Create a DNS A record:  ${var.phish_domain}  ->  ${hcloud_server.gophish.ipv4_address}
    2. Wait for propagation, then on the box run:  sudo provision-tls.sh <your-email>
    3. Reach the admin UI via SSH tunnel, then browse http://localhost:3333 :
       ssh -L 3333:127.0.0.1:3333 root@${hcloud_server.gophish.ipv4_address}
    4. Get the admin password:  sudo journalctl -u gophish | grep -i password
  EOT
}
