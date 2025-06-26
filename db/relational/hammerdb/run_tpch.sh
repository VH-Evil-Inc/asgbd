#!/bin/bash

docker run --rm -it \
  -v $(pwd)/tpch.tcl:/benchmark.tcl \
  -v $(pwd)/tmp:/tmp \
  --network=host \
  tpcorg/hammerdb:latest \
  ./hammerdbcli auto /benchmark.tcl
