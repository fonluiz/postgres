/*-------------------------------------------------------------------------
 *
 * geo_selfuncs.c
 *	  Selectivity routines registered in the operator catalog in the
 *	  "oprrest" and "oprjoin" attributes.
 *
 * Portions Copyright (c) 1996-2020, PostgreSQL Global Development Group
 * Portions Copyright (c) 1994, Regents of the University of California
 *
 *
 * IDENTIFICATION
 *	  src/backend/utils/adt/geo_selfuncs.c
 *
 *	XXX These are totally bogus.  Perhaps someone will make them do
 *	something reasonable, someday.
 *
 *-------------------------------------------------------------------------
 */
#include "postgres.h"

#include "utils/builtins.h"
#include "utils/geo_decls.h"

#include <math.h>

#include "access/htup_details.h"
#include "catalog/pg_operator.h"
#include "catalog/pg_statistic.h"
#include "utils/inet.h"
#include "utils/lsyscache.h"
#include "utils/selfuncs.h"

#include "catalog/pg_type.h"
#include "utils/float.h"
#include "utils/fmgrprotos.h"
#include "utils/rangetypes.h"
#include "utils/typcache.h"


/*
 *	Selectivity functions for geometric operators.  These are bogus -- unless
 *	we know the actual key distribution in the index, we can't make a good
 *	prediction of the selectivity of these operators.
 *
 *	Note: the values used here may look unreasonably small.  Perhaps they
 *	are.  For now, we want to make sure that the optimizer will make use
 *	of a geometric index if one is available, so the selectivity had better
 *	be fairly small.
 *
 *	In general, GiST needs to search multiple subtrees in order to guarantee
 *	that all occurrences of the same key have been found.  Because of this,
 *	the estimated cost for scanning the index ought to be higher than the
 *	output selectivity would indicate.  gistcostestimate(), over in selfuncs.c,
 *	ought to be adjusted accordingly --- but until we can generate somewhat
 *	realistic numbers here, it hardly matters...
 */

static float compute_join_cardinality_estimation(TypeCacheEntry *typcache, Datum *hist1_values, int nvalues1, Datum *hist2_values, int nvalues2);
static float compute_selectivity_for_one_range(TypeCacheEntry *typcache, Datum range, Datum *hist_values, int nvalues2);
static float subtract_range_bounds(TypeCacheEntry *typcache, const RangeBound *b1, const RangeBound *b2);

/*
 * Selectivity for operators that depend on area, such as "overlap".
 */

Datum
areasel(PG_FUNCTION_ARGS)
{
	PG_RETURN_FLOAT8(0.005);
}

Datum
areajoinsel(PG_FUNCTION_ARGS)
{
	PlannerInfo *root = (PlannerInfo *) PG_GETARG_POINTER(0);
	Oid			operator = PG_GETARG_OID(1);
	List	   *args = (List *) PG_GETARG_POINTER(2);
	JoinType	jointype = (JoinType) PG_GETARG_INT16(3);
	SpecialJoinInfo *sjinfo = (SpecialJoinInfo *) PG_GETARG_POINTER(4);

	TypeCacheEntry *typcache = NULL;

	VariableStatData vardata1;
	VariableStatData vardata2;
	bool		join_is_reversed;

	get_join_variables(root, args, sjinfo,
					   &vardata1, &vardata2, &join_is_reversed);

	AttStatsSlot bound_histogram1;
	AttStatsSlot length_histogram1;

	AttStatsSlot bound_histogram2;
	AttStatsSlot length_histogram2;

	get_attstatsslot(&bound_histogram1, vardata1.statsTuple,
						 STATISTIC_KIND_BOUNDS_HISTOGRAM, InvalidOid,
						 ATTSTATSSLOT_VALUES);


	get_attstatsslot(&bound_histogram2, vardata2.statsTuple,
						STATISTIC_KIND_BOUNDS_HISTOGRAM, InvalidOid,
						ATTSTATSSLOT_VALUES);

	typcache = range_get_typcache(fcinfo, vardata1.vartype);

	float selec;
	if (bound_histogram1.nvalues <= bound_histogram2.nvalues) {
		selec = compute_join_cardinality_estimation(typcache, bound_histogram1.values, bound_histogram1.nvalues, bound_histogram2.values, bound_histogram2.nvalues);
	} else {
		selec = compute_join_cardinality_estimation(typcache, bound_histogram2.values, bound_histogram2.nvalues, bound_histogram1.values, bound_histogram1.nvalues);
	}
	
	
	PG_RETURN_FLOAT8(selec);
}


/*
	The first histogram is expected to be the smallest one.
*/
float 
compute_join_cardinality_estimation(TypeCacheEntry *typcache, Datum *hist1_values, int nvalues1, Datum *hist2_values, int nvalues2) {

	RangeBound lower1, upper1, lower2, upper2;
	float selec = 0;
	bool empty;
	int overlaps_count = 0;
	
	for (int iter1 = 0; iter1 < nvalues1; iter1++) {

		range_deserialize(typcache, DatumGetRangeTypeP(hist1_values[iter1]), &lower1, &upper1, &empty);

		for (int iter2 = 0; iter2 < nvalues2; iter2++) {

			range_deserialize(typcache, DatumGetRangeTypeP(hist2_values[iter2]), &lower2, &upper2, &empty);

			// check if the bins overlap
			if (range_cmp_bounds(typcache, &(upper1), &(lower2)) >= 0 && range_cmp_bounds(typcache, &(upper2), &(lower1)) >= 0) {
				overlaps_count++;
			}
			
		}
	}

	return overlaps_count / (float) (nvalues1 * nvalues2);
}

float
subtract_range_bounds(TypeCacheEntry *typcache, const RangeBound *b1, const RangeBound *b2) {
	return DatumGetFloat8(FunctionCall2Coll(&typcache -> rng_subdiff_finfo, typcache -> rng_collation, b1 -> val, b2 -> val));
}

/*
 *	positionsel
 *
 * How likely is a box to be strictly left of (right of, above, below)
 * a given box?
 */

Datum
positionsel(PG_FUNCTION_ARGS)
{
	PG_RETURN_FLOAT8(0.1);
}

Datum
positionjoinsel(PG_FUNCTION_ARGS)
{
	PG_RETURN_FLOAT8(0.1);
}

/*
 *	contsel -- How likely is a box to contain (be contained by) a given box?
 *
 * This is a tighter constraint than "overlap", so produce a smaller
 * estimate than areasel does.
 */

Datum
contsel(PG_FUNCTION_ARGS)
{
	PG_RETURN_FLOAT8(0.001);
}

Datum
contjoinsel(PG_FUNCTION_ARGS)
{
	PG_RETURN_FLOAT8(0.001);
}
