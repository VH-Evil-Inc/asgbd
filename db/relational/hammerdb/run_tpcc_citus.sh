#!/bin/bash

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
