# Set database and benchmark type
dbset db pg               ;# Select PostgreSQL as the database
dbset bm TPROC-C            ;# Select TPC-C benchmark

# Set connection parameters for PostgreSQL
diset connection pg_host 127.0.0.1
diset connection pg_port 5432
diset tpcc pg_superuser postgres
diset tpcc pg_superuserpass password
diset tpcc pg_user postgres
diset tpcc pg_pass password
diset tpcc pg_dbase postgres

# Set TPC-C specific parameters
diset tpcc pg_count_ware 40        ;# Number of warehouses
diset tpcc pg_num_vu 32            ;# Virtual users
diset tpcc pg_driver timed         ;# Timed driver
diset tpcc pg_rampup 2             ;# 2-minute rampup
diset tpcc pg_duration 5           ;# 5-minute test
diset tpcc pg_allwarehouse true
diset tpcc pg_timeprofile true     ;# Enabled to collect latency data
diset tpcc pg_vacuum false         ;# Disable during test for stability

# Configure jobs database for result storage
giset commandline keepalive_margin 300  ;# Extend completion wait to 5 mins
jobs format text                        ;# Human-readable output

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

# Load the TPC-C benchmark script
vudestroy

# Configure virtual users
vuset vu 64
vuset logtotemp 1                   ;# Enable temp logging
vuset unique 1                      ;# Unique VU IDs
vuset showoutput 1                  ;# Show console output

tcset total 10000
tcstart
tcstatus
jobs cloud 1

# Run benchmark
puts "Starting test..."
vucreate
vurun
keepalive                          ;# Wait for completion
puts "Test complete."

vudestroy
tcstop
job 1 getchart result
