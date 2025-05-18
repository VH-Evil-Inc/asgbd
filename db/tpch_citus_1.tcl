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

# Enable Citus compatibility
diset tpch pg_cituscompat true

# Set TPC-H specific parameters
diset tpch pg_scale_fact 100    ;# Scale factor (e.g., 100GB)
diset tpch pg_num_tpch_threads 16 ;# Parallel data generation
diset tpch pg_degree_of_parallel 8 ;# Query parallelism
diset tpch pg_refresh_on false     ;# Disable refresh
diset tpch pg_driver timed        ;# Timed driver
diset tpch pg_rampup 2           ;# 2-min rampup
diset tpch pg_duration 10         ;# 10-min test
diset tpch pg_storage_raid false  ;# Disable RAID simulation
diset tpch pg_maxdop 16           ;# Increase parallel degree
diset tpch pg_analyze true        ;# Force stats collection

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
