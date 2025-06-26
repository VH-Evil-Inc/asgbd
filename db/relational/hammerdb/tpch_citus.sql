select create_reference_table('nation');
select create_reference_table('region');
select create_distributed_table('part', 'p_partkey');
select create_reference_table('supplier');
select create_distributed_table('partsupp', 'ps_partkey');
select create_distributed_table('customer', 'c_custkey');
select create_distributed_table('orders', 'o_orderkey');
select create_distributed_table('lineitem', 'l_orderkey');
vacuum analyze;
