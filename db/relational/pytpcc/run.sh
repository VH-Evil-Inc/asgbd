#!/usr/bin/env bash

cd /app/py-tpcc/pytpcc

find ./ -type f -name '*.py' -exec sed -i 's/\t/        /g' {} +

python ./tpcc.py \
  --config ../benchmark/docker-postgres.conf \
  --reset \
  --warehouses 100 \
  --clients 80 \
  --duration 1800 \
  --ddl ../benchmark/pytpcc-ddl.sql \
  --stop-on-error \
  postgresql
