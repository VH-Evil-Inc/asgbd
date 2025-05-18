#!/bin/bash

docker run --rm -it \
  -v $(pwd)/tpch_citus_1.tcl:/benchmark.tcl \
  --network=host \
  tpcorg/hammerdb:latest \
  ./hammerdbcli auto /benchmark.tcl

docker run --rm -it \
  -v $(pwd)/tpch_citus_2.tcl:/benchmark.tcl \
  --network=host \
  tpcorg/hammerdb:latest \
  ./hammerdbcli auto /benchmark.tcl
