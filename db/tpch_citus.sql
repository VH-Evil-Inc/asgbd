-- Distribute tables
SELECT create_distributed_table('lineitem', 'orderkey');
SELECT create_distributed_table('orders', 'orderkey');
SELECT create_distributed_table('customer', 'custkey');
SELECT create_distributed_table('supplier', 'suppkey');
SELECT create_distributed_table('nation', 'nationkey');
SELECT create_distributed_table('region', 'regionkey');
SELECT create_distributed_table('part', 'partkey');
SELECT create_distributed_table('partsupp', 'partkey');

-- Update statistics
VACUUM ANALYZE;
