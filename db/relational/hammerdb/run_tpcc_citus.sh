#!/bin/bash

REPLICATION_FACTOR="${1:-1}"
POSTGRES_HOST="${2:-postgres-01.private.do-usp.lelis.gay}"
POSTGRES_PORT="${3:-5432}"
POSTGRES_USER="${4:-postgres}"
POSTGRES_PASS="${5:-password}"

echo "Applying schema with replication factor $REPLICATION_FACTOR"

# Update session replication factor
docker run --rm -it \
  --network=host \
  postgres:17 \
  psql -h $POSTGRES_HOST -p $POSTGRES_PORT -U $POSTGRES_USER -d postgres -c "ALTER SYSTEM SET citus.shard_replication_factor = $REPLICATION_FACTOR;"

docker run --rm -it \
  --network=host \
  postgres:17 \
  psql -h $POSTGRES_HOST -p $POSTGRES_PORT -U $POSTGRES_USER -d postgres -c "SHOW citus.shard_replication_factor;"

# Run TPC-C creation script
docker run --rm -it \
  -v $(pwd)/tpcc_citus_1.tcl:/benchmark.tcl \
  --network=host \
  tpcorg/hammerdb:latest \
  ./hammerdbcli auto /benchmark.tcl

# Run TPC-C benchmark
docker run --rm -it \
  -v $(pwd)/tpcc_citus_2.tcl:/benchmark.tcl \
  -v $(pwd)/tmp:/tmp \
  --network=host \
  tpcorg/hammerdb:latest \
  ./hammerdbcli auto /benchmark.tcl
