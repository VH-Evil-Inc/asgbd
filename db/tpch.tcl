# Set database and benchmark type
dbset db pg                  ;# Select PostgreSQL as the database
dbset bm TPROC-H             ;# Select TPC-H (TPROC-H) benchmark

# Set connection parameters for PostgreSQL
diset connection pg_host 127.0.0.1
diset connection pg_port 5432
diset tpch pg_superuser postgres
diset tpch pg_superuserpass password
diset tpch pg_user tpch
diset tpch pg_pass tpch
diset tpch pg_dbase tpch

# Set TPC-H specific parameters
diset tpch pg_scale 100         ;# Scale factor (e.g., 10GB)
diset tpch pg_num_vu 16         ;# Number of virtual users
diset tpch pg_driver timed     ;# Use timed driver
diset tpch pg_rampup 2         ;# Ramp-up time in minutes
diset tpch pg_duration 10       ;# Test duration in minutes

# Build the TPC-H schema and load data
puts "Starting schema build..."
buildschema
puts "Schema build complete."

# Ensure no virtual users are running before schema check
vudestroy
puts "Checking schema..."
checkschema
puts "Schema check complete."

# Load the TPC-H benchmark script
loadscript
vudestroy

# Configure virtual users
vuset vu 16
vuset logtotemp 1
vuset unique 1
vuset showoutput 1

# Start the benchmark run
puts "Starting test..."
vucreate
vurun
keepalive
puts "Test complete."
