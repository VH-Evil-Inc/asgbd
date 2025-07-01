# Set database and benchmark type
dbset db pg               ;# Select PostgreSQL as the database

# Set connection parameters for PostgreSQL
diset connection pg_host 127.0.0.1
diset connection pg_port 5432

dbset bm TPROC-C            ;# Select TPC-C benchmark

diset tpcc pg_superuser postgres
diset tpcc pg_user postgres
diset tpcc pg_dbase postgres

# Enable Citus compatibility
diset tpcc pg_cituscompat true

# Set TPC-C specific parameters
diset tpcc pg_count_ware 100        ;# Number of warehouses
diset tpcc pg_num_vu 64            ;# Virtual users
diset tpcc pg_driver timed         ;# Timed driver
diset tpcc pg_rampup 2             ;# 2-minute rampup
diset tpcc pg_duration 10           ;# 5-minute test
diset tpcc pg_allwarehouse true
diset tpcc pg_timeprofile true     ;# Enabled to collect latency data
diset tpcc pg_vacuum false         ;# Disable during test for stability

# Configure jobs database for result storage
giset commandline keepalive_margin 300  ;# Extend completion wait to 5 mins
jobs
jobs format text                        ;# Human-readable output

# Load the TPC-C benchmark script
loadscript

# Build the TPC-C schema and load data
puts "Starting schema build..."
buildschema
puts "Schema build complete."

# Verify schema (must destroy any existing VUs first)
vudestroy                             ;# Ensure clean state
puts "Checking schema..."
checkschema
puts "Schema check complete."
