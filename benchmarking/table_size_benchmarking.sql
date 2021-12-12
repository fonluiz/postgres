-----------------------------------------------------
---------- BENCHMARKING WITH DIFFERENT SIZES --------
-----------------------------------------------------

-- Fixed variables: distribution(normal) and range type (int8range)
-- variable that changes: table size (1k rows or 10k rows)

-- Analyze all tables
vacuum analyze normal_dist_1000_a;
vacuum analyze normal_dist_1000_b;
vacuum analyze normal_dist_10k_a;
vacuum analyze normal_dist_10k_b;

-- Run queries to explain analyze the join estimations

-- small x small
explain analyze select * from normal_dist_1000_a a, normal_dist_1000_b b where a.integer_range && b.integer_range;

-- small x big
explain analyze select * from normal_dist_1000_a a, normal_dist_10k_b b where a.integer_range && b.integer_range;

-- big x big
explain analyze select * from normal_dist_10k_a a, normal_dist_10k_b b where a.integer_range && b.integer_range;
