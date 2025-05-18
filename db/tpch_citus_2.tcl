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

# Enable Citus compatibility
diset tpcc pg_cituscompat true

# Set TPC-H specific parameters
diset tpch pg_scale 10         ;# Scale factor (e.g., 10GB)
diset tpch pg_num_vu 4         ;# Number of virtual users
diset tpch pg_driver timed     ;# Use timed driver
diset tpch pg_rampup 2         ;# Ramp-up time in minutes
diset tpch pg_duration 5       ;# Test duration in minutes

# Load the TPC-H benchmark script
loadscript

# Configure virtual users
vuset vu 4
vuset logtotemp 1
vuset unique 1
vuset showoutput 1

# Start the benchmark run
puts "Starting test..."
vucreate
vurun
keepalive
puts "Test complete."

# Retrieve the last job ID
set jobid [jobs last]
if { $jobid eq "" } {
    puts "No job was created. Check for errors in workload execution."
    exit
}

# Optionally, set output format (text or JSON)
jobs format text

puts "======================="
puts "TPROC-H (TPC-H) SUMMARY RESULT"
jobs $jobid getchart result
puts "======================="
puts "TPROC-H (TPC-H) QUERY COUNT (per VU)"
# Loop through all VUs for detailed counts (replace 4 with your actual VU count)
for {set vuid 1} {$vuid <= 4} {incr vuid} {
    puts "Virtual User $vuid:"
    jobs $jobid tcount $vuid
}
puts "======================="
puts "TPROC-H (TPC-H) TIMING DATA (per VU)"
for {set vuid 1} {$vuid <= 4} {incr vuid} {
    puts "Virtual User $vuid:"
    jobs $jobid timing $vuid
}
puts "======================="
