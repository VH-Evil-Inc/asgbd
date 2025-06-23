#!/usr/bin/env bash
sudo -i -u postgres psql -c "SELECT citus_set_coordinator_host('citus-master.private.do-usp.lelis.gay', 5432);"
sudo -i -u postgres psql -c "SELECT * FROM master_add_node('citus-worker-01.private.do-usp.lelis.gay', 5432);"
sudo -i -u postgres psql -c "SELECT * FROM master_add_node('citus-worker-02.private.do-usp.lelis.gay', 5432);"
sudo -i -u postgres psql -c "SELECT * FROM master_add_node('citus-worker-03.private.do-usp.lelis.gay', 5432);"
