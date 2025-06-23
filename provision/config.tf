terraform {
  required_version = ">= 1.0"
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}

locals {
  do_region = "nyc3"
  do_grafana_size = "s-2vcpu-4gb-amd"
  do_bench_size = "s-8vcpu-16gb-amd"
  do_instance_size = "s-4vcpu-8gb-amd"
}

variable "do_token" {
  type = string
}

provider "digitalocean" {
  token = var.do_token
}
