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

# Grafana droplet
resource "digitalocean_droplet" "grafana" {
  name    = "tf-usp-asgbd-grafana"
  region  = local.do_region
  size    = local.do_grafana_size
  image   = "ubuntu-24-04-x64"
  vpc_uuid = digitalocean_vpc.asgbd.id
  ssh_keys = [digitalocean_ssh_key.asgbd.id]

  tags = [digitalocean_tag.asgbd.id]

  user_data = file("./init/grafana-init.yml")
}

# DNS for the droplet
resource "digitalocean_record" "grafana" {
  domain = data.digitalocean_domain.base.id
  name    = "grafana"
  type    = "A"
  value   = digitalocean_droplet.grafana.ipv4_address
  ttl     = 60
}

resource "digitalocean_record" "grafana_private" {
  domain = data.digitalocean_domain.base.id
  name    = "grafana.private"
  type    = "A"
  value   = digitalocean_droplet.grafana.ipv4_address_private
  ttl     = 60
}

output "grafana_ip" {
  value = digitalocean_droplet.grafana.ipv4_address
}

# Benchmark droplet
resource "digitalocean_droplet" "benchmark" {
  name    = "tf-usp-asgbd-benchmark"
  region  = local.do_region
  size    = local.do_bench_size
  image   = "ubuntu-24-04-x64"
  vpc_uuid = digitalocean_vpc.asgbd.id
  ssh_keys = [digitalocean_ssh_key.asgbd.id]

  tags = [digitalocean_tag.asgbd.id]
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
resource "digitalocean_droplet" "citus_master" {
  name    = "tf-usp-asgbd-citus-master"
  region  = local.do_region
  size    = local.do_instance_size
  image   = "ubuntu-24-04-x64"
  vpc_uuid = digitalocean_vpc.asgbd.id
  ssh_keys = [digitalocean_ssh_key.asgbd.id]
  tags = [digitalocean_tag.asgbd.id]
  user_data = file("./init/citus-master-init.yml")
}

resource "digitalocean_record" "citus_master" {
  domain = data.digitalocean_domain.base.id
  name    = "citus-master"
  type    = "A"
  value   = digitalocean_droplet.citus_master.ipv4_address
  ttl     = 60
}

resource "digitalocean_record" "citus_master_private" {
  domain = data.digitalocean_domain.base.id
  name    = "citus-master.private"
  type    = "A"
  value   = digitalocean_droplet.citus_master.ipv4_address_private
  ttl     = 60
}

output "citus_master_ip" {
  value = digitalocean_droplet.citus_master.ipv4_address
}

# PostgreSQL Citus Workers
resource "digitalocean_droplet" "citus_worker" {
  count   = 3
  name    = "tf-usp-asgbd-citus-worker-${format("%02d", count.index + 1)}"
  region  = local.do_region
  size    = local.do_instance_size
  image   = "ubuntu-24-04-x64"
  vpc_uuid = digitalocean_vpc.asgbd.id
  ssh_keys = [digitalocean_ssh_key.asgbd.id]
  tags = [digitalocean_tag.asgbd.id]
  user_data = file("./init/citus-worker-init.yml")
}

resource "digitalocean_record" "citus_worker" {
  count   = 3
  domain  = data.digitalocean_domain.base.id
  name    = "citus-worker-${format("%02d", count.index + 1)}"
  type    = "A"
  value   = digitalocean_droplet.citus_worker[count.index].ipv4_address
  ttl     = 60
}

resource "digitalocean_record" "citus_worker_private" {
  count   = 3
  domain  = data.digitalocean_domain.base.id
  name    = "citus-worker-${format("%02d", count.index + 1)}.private"
  type    = "A"
  value   = digitalocean_droplet.citus_worker[count.index].ipv4_address_private
  ttl     = 60
}

output "citus_worker_ips" {
  value = digitalocean_droplet.citus_worker[*].ipv4_address
} 

# Cassandra Cluster (3 machines)
resource "digitalocean_droplet" "cassandra" {
  count   = 3
  name    = "tf-usp-asgbd-cassandra-${format("%02d", count.index + 1)}"
  region  = local.do_region
  size    = local.do_instance_size
  image   = "ubuntu-24-04-x64"
  vpc_uuid = digitalocean_vpc.asgbd.id
  ssh_keys = [digitalocean_ssh_key.asgbd.id]
  tags = [digitalocean_tag.asgbd.id]
  user_data = file("./init/cassandra-init.yml")
}

resource "digitalocean_record" "cassandra" {
  count   = 3
  domain  = data.digitalocean_domain.base.id
  name    = "cassandra-${format("%02d", count.index + 1)}"
  type    = "A"
  value   = digitalocean_droplet.cassandra[count.index].ipv4_address
  ttl     = 60
}

resource "digitalocean_record" "cassandra_private" {
  count   = 3
  domain  = data.digitalocean_domain.base.id
  name    = "cassandra-${format("%02d", count.index + 1)}.private"
  type    = "A"
  value   = digitalocean_droplet.cassandra[count.index].ipv4_address_private
  ttl     = 60
}

output "cassandra_ips" {
  value = digitalocean_droplet.cassandra[*].ipv4_address
}

# TODO: generate/create prometheus config and grafana dashboards
# TODO: domain assignments
