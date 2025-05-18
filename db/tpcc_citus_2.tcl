# Set database and benchmark type
dbset db pg               ;# Select PostgreSQL as the database
dbset bm TPROC-C            ;# Select TPC-C benchmark

# Set connection parameters for PostgreSQL
diset connection pg_host 127.0.0.1
diset connection pg_port 5432
diset tpcc pg_superuser postgres
diset tpcc pg_superuserpass password
diset tpcc pg_user tpcc
diset tpcc pg_pass tpcc
diset tpcc pg_dbase tpcc

# Enable Citus compatibility
diset tpcc pg_cituscompat true

# Set TPC-C specific parameters
diset tpcc pg_count_ware 10       ;# Number of warehouses
diset tpcc pg_num_vu 4            ;# Virtual users
diset tpcc pg_driver timed        ;# Timed driver
diset tpcc pg_rampup 2           ;# 2-minute rampup (replaces 'rampup' command)
diset tpcc pg_duration 5         ;# 5-minute test (replaces 'runtimer')
diset tpcc pg_allwarehouse true
diset tpcc pg_timeprofile false  ;# Disable to prevent memory issues [3]
diset tpcc pg_vacuum false       ;# Disable during test for stability [3]

# Configure jobs database for result storage
giset commandline keepalive_margin 300  ;# Extend completion wait to 5 mins
jobs format text                        ;# Human-readable output

# Load the TPC-C benchmark script
loadscript

# Configure virtual users
vuset vu 4
vuset logtotemp 1                   ;# Enable temp logging
vuset unique 1                      ;# Unique VU IDs
vuset showoutput 1                  ;# Show console output

# Run benchmark
puts "Starting test..."
vucreate
vurun
keepalive                          ;# Wait for completion
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
puts "TPROC-C (TPC-C) SUMMARY RESULT"
jobs $jobid getchart result
puts "======================="
puts "TPROC-C (TPC-C) NEW ORDERS PER MINUTE (NOPM)"
jobs $jobid getchart nopm
puts "======================="
puts "TPROC-C (TPC-C) TRANSACTION COUNT (per VU)"
# Loop through all VUs for detailed counts (replace 4 with your actual VU count)
for {set vuid 1} {$vuid <= 4} {incr vuid} {
    puts "Virtual User $vuid:"
    jobs $jobid tcount $vuid
}
puts "======================="
puts "TPROC-C (TPC-C) TIMING DATA (per VU)"
for {set vuid 1} {$vuid <= 4} {incr vuid} {
    puts "Virtual User $vuid:"
    jobs $jobid timing $vuid
}
puts "======================="
