-----------------------------------------------------
----- BENCHMARKING WITH DIFFERENT RANGE SIZES -------
-----------------------------------------------------

-- Fixed variables: table size(1000 rows), range type (int8range) and distribution (normal)
-- Variable that changes: range size (small (1 up to 500) and large (1 to 1 million))

-- Analyze all tables
vacuum analyze normal_dist_1000_large_range_a;
vacuum analyze normal_dist_1000_large_range_b;

-- Run queries to explain analyze the join estimations

-- small x small
explain analyze select * from normal_dist_1000_a a, normal_dist_1000_b b where a.integer_range && b.integer_range;

-- small x large
explain analyze select * from normal_dist_1000_a a, normal_dist_1000_large_range_b b where a.integer_range && b.integer_range;

-- large x large
explain analyze select * from normal_dist_1000_large_range_a a, normal_dist_1000_large_range_b b where a.integer_range && b.integer_range;

