#!/bin/bash

docker run --rm -it \
  -v $(pwd)/tpcc_citus_1.tcl:/benchmark.tcl \
  --network=host \
  tpcorg/hammerdb:latest \
  ./hammerdbcli auto /benchmark.tcl

cat tpcc_citus.sql | docker compose -f ./docker-compose.citus-std.yml exec master psql -U postgres -d tpcc

docker run --rm -it \
  -v $(pwd)/tpcc_citus_2.tcl:/benchmark.tcl \
  --network=host \
  tpcorg/hammerdb:latest \
  ./hammerdbcli auto /benchmark.tcl
