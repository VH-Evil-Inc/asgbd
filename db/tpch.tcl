# Set database and benchmark type
dbset db pg                  ;# Select PostgreSQL as the database
dbset bm TPROC-H             ;# Select TPC-H (TPROC-H) benchmark

# Set connection parameters for PostgreSQL
diset connection pg_host 127.0.0.1
diset connection pg_port 5432
diset tpch pg_tpch_superuser postgres
diset tpch pg_tpch_superuserpass password
diset tpch pg_tpch_user postgres
diset tpch pg_tpch_pass password
diset tpch pg_tpch_dbase postgres
diset tpch pg_tpch_tspace pg_default

# Set TPC-H specific parameters
diset tpch pg_scale_fact 100    ;# Scale factor (e.g., 100GB)
diset tpch pg_num_tpch_threads 16 ;# Parallel data generation
diset tpch pg_degree_of_parallel 8 ;# Query parallelism
diset tpch pg_refresh_on false     ;# Disable refresh
diset tpch pg_driver timed        ;# Timed driver
diset tpch pg_rampup 2           ;# 2-min rampup
diset tpch pg_duration 10         ;# 10-min test

# Load the TPC-H benchmark script
print dict
loadscript

# Build the TPC-H schema and load data
puts "Starting schema build..."
buildschema
puts "Schema build complete."

# Ensure no virtual users are running before schema check
vudestroy
puts "Checking schema..."
checkschema
puts "Schema check complete."

vudestroy

# Configure virtual users
vuset vu 100
vuset logtotemp 1
vuset unique 1
vuset showoutput 1

tcset total 10000
tcstart
tcstatus
jobs cloud 1

# Start the benchmark run
puts "Starting test..."
vucreate
vurun
keepalive
puts "Test complete."

vudestroy
tcstop
job 1 getchart result
