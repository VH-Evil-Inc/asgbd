#!/usr/bin/env bash

cd /app/py-tpcc/pytpcc

# find ./ -type f -name '*.py' -exec sed -i 's/\t/        /g' {} +

cp ../benchmark/cassandradriver.py ./drivers/cassandradriver.py

python ./tpcc.py \
  --config ../benchmark/docker-cassandra.conf \
  --reset \
  --warehouses 100 \
  --clients 80 \
  --duration 1800 \
  --stop-on-error \
  cassandra
