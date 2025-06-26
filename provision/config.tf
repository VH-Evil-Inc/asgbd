terraform {
  required_version = ">= 1.0"
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
    cloudinit = {
      source = "hashicorp/cloudinit"
      version = "~> 2.0"
    }
  }
}

locals {
  do_region = "nyc1"
  do_grafana_size = "s-2vcpu-4gb-amd"
  do_bench_size = "s-8vcpu-16gb-amd"
}

variable "do_token" {
  type = string
}

provider "digitalocean" {
  token = var.do_token
}

# Variables to control each database scaling profiles
variable "postgres_instance" {
  type = string
  default = "s-4vcpu-8gb-amd"
  description = "The Digital Ocean instance type to use for the Postgres database"
  validation {
    condition     = contains(["s-4vcpu-8gb-amd", "s-8vcpu-16gb-amd", "s-16vcpu-32gb-amd"], var.postgres_instance)
    error_message = "The Postgres instance type must be one of the following: s-4vcpu-8gb-amd, s-8vcpu-16gb-amd, s-16vcpu-32gb-amd."
  }
}

variable "postgres_size" {
  type = number
  default = 0
  description = "The number of machines in the Postgres cluster"
  validation {
    condition     = var.postgres_size >= 0 && var.postgres_size<= 9 && floor(var.postgres_size) == var.postgres_size
    error_message = "The value must be an integer between 0 and 9."
  }
}

variable "cassandra_instance" {
  type = string
  default = "s-4vcpu-8gb-amd"
  description = "The Digital Ocean instance type to use for the Cassandra database"
  validation {
    condition     = contains(["s-4vcpu-8gb-amd", "s-8vcpu-16gb-amd", "s-16vcpu-32gb-amd"], var.cassandra_instance)
    error_message = "The Cassandra instance type must be one of the following: s-4vcpu-8gb-amd, s-8vcpu-16gb-amd, s-16vcpu-32gb-amd."
  }
}

variable "cassandra_size" {
  type = number
  default = 0
  description = "The number of machines in the Cassandra cluster"
  validation {
    condition     = var.cassandra_size >= 0 && var.cassandra_size<= 9 && floor(var.cassandra_size) == var.cassandra_size
    error_message = "The value must be an integer between 0 and 9."
  }
}
