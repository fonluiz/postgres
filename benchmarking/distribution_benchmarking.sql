-----------------------------------------------------
---- BENCHMARKING WITH DIFFERENT DISTRIBUTIONS ------
-----------------------------------------------------

-- Fixed variables: table size(1000 rows) and range type (int8range)
-- variable that changes: distribution (normal, left-aligned, right-aligned)

-- Analyze all tables
vacuum analyze normal_dist_1000_a;
vacuum analyze normal_dist_1000_b;
vacuum analyze left_dist_1000_a;
vacuum analyze left_dist_1000_b;
vacuum analyze right_dist_1000_a;
vacuum analyze right_dist_1000_b;

-- Run queries to explain analyze the join estimations

-- normal x normal
explain analyze select * from normal_dist_1000_a a, normal_dist_1000_b b where a.integer_range && b.integer_range;

-- normal x left
explain analyze select * from normal_dist_1000_a a, left_dist_1000_b b where a.integer_range && b.integer_range;

-- normal x right
explain analyze select * from normal_dist_1000_a a, right_dist_1000_b b where a.integer_range && b.integer_range;

-- left x left
explain analyze select * from left_dist_1000_a a, left_dist_1000_b b where a.integer_range && b.integer_range;

-- left x right
explain analyze select * from left_dist_1000_a a, right_dist_1000_b b where a.integer_range && b.integer_range;

-- right x right
explain analyze select * from right_dist_1000_a a, right_dist_1000_b b where a.integer_range && b.integer_range;