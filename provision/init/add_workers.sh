#!/usr/bin/env bash
sudo -i -u postgres psql -c "SELECT citus_set_coordinator_host('postgres-01.private.do-usp.lelis.gay', 5432);"
sudo -i -u postgres psql -c "SELECT * FROM master_add_node('postgres-02.private.do-usp.lelis.gay', 5432);"
sudo -i -u postgres psql -c "SELECT * FROM master_add_node('postgres-03.private.do-usp.lelis.gay', 5432);"
