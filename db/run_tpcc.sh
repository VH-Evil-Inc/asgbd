#!/bin/bash

docker run --rm -it \
  -v $(pwd)/tpcc.tcl:/benchmark.tcl \
  --network=host \
  tpcorg/hammerdb:latest \
  ./hammerdbcli auto /benchmark.tcl
