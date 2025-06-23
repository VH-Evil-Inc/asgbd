# Provisioning

For running the databases on a cloud environment, we are going to use
DigitalOcean droplets, due to the 200$ student credits grant (which I might
somehow gotten more than once 🤠).

Due to restrictions on the DigitalOcean resources available, we could go for either:

- Shared CPU using "Premium AMD" CPUs (NVMe SSD and network speed of 10Gbps),
  but with inconsistent results due to resource contention.
- Dedicated CPU using "Regular" CPUs (SATA SSD and network speed of 2Gbps) with
  stable results.

We are deciding to go for the shared CPUs due to significantly better disk
performance, but we know that there might be some result variability due to
resource contention.

## Cluster

For all benchmarks, we are going to dispatch the requests from a single droplet
with with 16GB of RAM and 8 vCPUs.

For all tests, there is going to be a machine running Grafana and Prometheus
for monitoring the cluster.

### PostgreSQL

Every instance will be using a 4 vCPUs with 8GB of RAM VM.

The machine assignment will be the following:

- Master
- Worker 1
- Worker 2
- Worker 3

### Cassandra

- Member 1
- Member 2
- Member 3

## Setup

The Terraform provisioning setup accompanies cloud-init scripts to properly
provision every machine. The only manual step required is to add the worker
nodes to Citus, which can be done by running the `add_workers.sh` script at
the master node.
