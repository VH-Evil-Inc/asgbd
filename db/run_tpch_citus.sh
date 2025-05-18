#!/bin/bash

docker run --rm -it \
  -v $(pwd)/tpcc_citus_1.tcl:/benchmark.tcl \
  --network=host \
  tpcorg/hammerdb:latest \
  ./hammerdbcli auto /benchmark.tcl

cat tpch_citus.sql | docker exec -i vh-evil-inc-citus-cluster_master psql -U postgres -d postgres

docker run --rm -it \
  -v $(pwd)/tpcc_citus_2.tcl:/benchmark.tcl \
  --network=host \
  tpcorg/hammerdb:latest \
  ./hammerdbcli auto /benchmark.tcl
