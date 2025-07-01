# Base domain
data "digitalocean_domain" "base" {
  name = "do-usp.lelis.gay"
}

# SSH key
resource "digitalocean_ssh_key" "asgbd" {
  name       = "tf-usp-asgbd-lelis"
  public_key = file("init/id_rsa.pub")
}

# Main network
resource "digitalocean_vpc" "asgbd" {
  name     = "tf-usp-asgbd"
  region   = local.do_region
  ip_range = "172.16.12.0/24"
}

# Tag for the droplets
resource "digitalocean_tag" "asgbd" {
  name = "tf-usp-asgbd"
}

# Block everything but SSH firewall
resource "digitalocean_firewall" "asgbd" {
  name = "tf-usp-asgbd"

  tags = [digitalocean_tag.asgbd.id]

  inbound_rule {
    protocol         = "tcp"
    port_range       = "22"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  inbound_rule {
    protocol         = "tcp"
    port_range       = "1-65535"
    source_addresses = ["172.16.12.0/24"]
  }

  inbound_rule {
    protocol         = "udp"
    port_range       = "1-65535"
    source_addresses = ["172.16.12.0/24"]
  }

  inbound_rule {
    protocol         = "icmp"
    source_addresses = ["172.16.12.0/24"]
  }

  outbound_rule {
    protocol              = "tcp"
    port_range            = "1-65535"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "udp"
    port_range            = "1-65535"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "icmp"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }
}

# Benchmark droplet
resource "digitalocean_droplet" "benchmark" {
  name    = "tf-usp-asgbd-benchmark"
  region  = local.do_region
  size    = local.do_bench_size
  image   = "ubuntu-22-04-x64"
  vpc_uuid = digitalocean_vpc.asgbd.id
  ssh_keys = [digitalocean_ssh_key.asgbd.id]
  tags = [digitalocean_tag.asgbd.id]
  user_data = file("./init/benchmark-init.yml")
}

resource "digitalocean_record" "benchmark" {
  domain = data.digitalocean_domain.base.id
  name    = "benchmark"
  type    = "A"
  value   = digitalocean_droplet.benchmark.ipv4_address
  ttl     = 60
}

resource "digitalocean_record" "benchmark_private" {
  domain = data.digitalocean_domain.base.id
  name    = "benchmark.private"
  type    = "A"
  value   = digitalocean_droplet.benchmark.ipv4_address_private
  ttl     = 60
}

output "benchmark_ip" {
  value = digitalocean_droplet.benchmark.ipv4_address
}

# PostgreSQL Citus Master
resource "digitalocean_droplet" "postgres" {
  count   = var.postgres_size
  name    = "tf-usp-asgbd-postgres-${format("%02d", count.index + 1)}"
  region  = local.do_region
  size    = var.postgres_instance
  image   = "ubuntu-22-04-x64"
  vpc_uuid = digitalocean_vpc.asgbd.id
  ssh_keys = [digitalocean_ssh_key.asgbd.id]
  tags = [digitalocean_tag.asgbd.id]
  user_data = count.index == 0 ? templatefile("./init/citus-master-init.yml.tftpl", {replication_factor = var.postgres_replication_factor}) : templatefile("./init/citus-worker-init.yml.tftpl", {replication_factor = var.postgres_replication_factor})
}

resource "digitalocean_record" "postgres" {
  count   = var.postgres_size
  domain  = data.digitalocean_domain.base.id
  name    = "postgres-${format("%02d", count.index + 1)}"
  type    = "A"
  value   = digitalocean_droplet.postgres[count.index].ipv4_address
  ttl     = 60
}

resource "digitalocean_record" "postgres_private" {
  count   = var.postgres_size
  domain  = data.digitalocean_domain.base.id
  name    = "postgres-${format("%02d", count.index + 1)}.private"
  type    = "A"
  value   = digitalocean_droplet.postgres[count.index].ipv4_address_private
  ttl     = 60
}

output "postgres_ips" {
  value = digitalocean_droplet.postgres[*].ipv4_address
} 

# Cassandra Cluster
resource "digitalocean_droplet" "cassandra" {
  count   = var.cassandra_size
  name    = "tf-usp-asgbd-cassandra-${format("%02d", count.index + 1)}"
  region  = local.do_region
  size    = var.cassandra_instance
  image   = "ubuntu-22-04-x64"
  vpc_uuid = digitalocean_vpc.asgbd.id
  ssh_keys = [digitalocean_ssh_key.asgbd.id]
  tags = [digitalocean_tag.asgbd.id]
  user_data = file("./init/cassandra-init.yml")
}

resource "digitalocean_record" "cassandra" {
  count   = var.cassandra_size
  domain  = data.digitalocean_domain.base.id
  name    = "cassandra-${format("%02d", count.index + 1)}"
  type    = "A"
  value   = digitalocean_droplet.cassandra[count.index].ipv4_address
  ttl     = 60
}

resource "digitalocean_record" "cassandra_private" {
  count   = var.cassandra_size
  domain  = data.digitalocean_domain.base.id
  name    = "cassandra-${format("%02d", count.index + 1)}.private"
  type    = "A"
  value   = digitalocean_droplet.cassandra[count.index].ipv4_address_private
  ttl     = 60
}

output "cassandra_ips" {
  value = digitalocean_droplet.cassandra[*].ipv4_address
}

# Setup prometheus scrape targets
locals {
  postgres_targets = [
    for r in digitalocean_record.postgres :
    "${r.fqdn}:9187"
  ]

  cassandra_targets = [
    for r in digitalocean_record.cassandra :
    "${r.fqdn}:7070"
  ]

  node_targets = concat(
    [for r in digitalocean_record.postgres : "${r.fqdn}:9100"],
    [for r in digitalocean_record.cassandra : "${r.fqdn}:9100"]
  )
}

# Create grafana cloud config from template
data "cloudinit_config" "grafana" {
  count = var.enable_grafana ? 1 : 0

  gzip          = false
  base64_encode = false

  part {
    filename     = "cloud-init.yml"
    content_type = "text/cloud-config"
    content = templatefile("./init/grafana-init.yml.tftpl", {
      postgres_targets  = local.postgres_targets
      cassandra_targets = local.cassandra_targets
      node_targets      = local.node_targets
    })
  }
}

# Grafana droplet
resource "digitalocean_droplet" "grafana" {
  count   = var.enable_grafana ? 1 : 0

  name    = "tf-usp-asgbd-grafana"
  region  = local.do_region
  size    = local.do_grafana_size
  image   = "ubuntu-22-04-x64"
  vpc_uuid = digitalocean_vpc.asgbd.id
  ssh_keys = [digitalocean_ssh_key.asgbd.id]

  tags = [digitalocean_tag.asgbd.id]

  user_data = data.cloudinit_config.grafana[0].rendered
}

# DNS for the droplet
resource "digitalocean_record" "grafana" {
  count = var.enable_grafana ? 1 : 0

  domain = data.digitalocean_domain.base.id
  name    = "grafana"
  type    = "A"
  value   = digitalocean_droplet.grafana[0].ipv4_address
  ttl     = 60
}

resource "digitalocean_record" "grafana_private" {
  count = var.enable_grafana ? 1 : 0

  domain = data.digitalocean_domain.base.id
  name    = "grafana.private"
  type    = "A"
  value   = digitalocean_droplet.grafana[0].ipv4_address_private
  ttl     = 60
}

output "grafana_ip" { 
  value = digitalocean_droplet.grafana[*].ipv4_address
}
