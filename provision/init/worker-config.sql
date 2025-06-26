ALTER SYSTEM SET citus.max_adaptive_executor_pool_size = 100;
ALTER SYSTEM SET citus.executor_slow_start_interval = '10ms';

ALTER SYSTEM SET shared_buffers = '2GB';
ALTER SYSTEM SET work_mem = '128MB';
ALTER SYSTEM SET maintenance_work_mem = '1GB';
ALTER SYSTEM SET max_parallel_workers_per_gather = 4;
ALTER SYSTEM SET max_worker_processes = 20;
  
ALTER SYSTEM SET citus.coordinator_aggregation_strategy = 'disabled';
ALTER SYSTEM SET citus.enable_repartition_joins = on;

SELECT pg_reload_conf();
