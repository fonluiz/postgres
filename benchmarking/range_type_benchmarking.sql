-----------------------------------------------------
----- BENCHMARKING WITH DIFFERENT RANGE TYPES -------
-----------------------------------------------------

-- Fixed variables: table size(1000 rows), range size (small (1 up to 500) and distribution (normal)
-- Variable that changes: range type (int8range, numrange)


-- Analyze all tables
vacuum analyze normal_dist_1000_a;
vacuum analyze normal_dist_1000_b;

-- Run queries to explain analyze the join estimations

-- integer ranges
explain analyze select * from normal_dist_1000_a a, normal_dist_1000_b b where a.integer_range && b.integer_range;

-- float ranges
explain analyze select * from normal_dist_1000_a a, normal_dist_1000_b b where a.float_range && b.float_range;

-- timestamp ranges
explain analyze select * from normal_dist_1000_a a, normal_dist_1000_b b where a.timestamp_range && b.timestamp_range;

-- date ranges
explain analyze select * from normal_dist_1000_a a, normal_dist_1000_b b where a.date_range && b.date_range;


