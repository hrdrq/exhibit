//
//  SQLConstraintMaker.m
//  ExhibitAPP
//
//  Created by sfffaaa on 12/10/13.
//
//

#import "SQLConstraintMaker.h"
#import "DebugUtil.h"
#import "NSDateHandler.h"
#import "GlobalVariable.h"
#import "SearchViewController.h"

#import "SQLDefine.h"


enum SQL_TYPE {
    EQUAL_TYPE = 0,
    LIKE_TYPE,
};

@implementation SQLConstraintMaker

@synthesize _activitySelectedSet;
@synthesize _categorySelectedSet;
@synthesize _citySelectedSet;
@synthesize _distSelectedSet;
@synthesize _searchText;

- (BOOL) activitySelectedSetAlloc
{
    if (!_activitySelectedSet) {
        _activitySelectedSet = [[NSMutableSet alloc] init];
    }
    CHECK_NIL(_activitySelectedSet);
    return FALSE;
}

- (BOOL) categorySelectedSetAlloc
{
    if (!_categorySelectedSet) {
        _categorySelectedSet = [[NSMutableSet alloc] init];
    }
    CHECK_NIL(_categorySelectedSet);
    return FALSE;
}

- (BOOL) citySelectedSetAlloc
{
    if (!_citySelectedSet) {
        _citySelectedSet = [[NSMutableSet alloc] init];
    }
    CHECK_NIL(_citySelectedSet);
    return FALSE;
}

- (BOOL) distSelectedSetAlloc
{
    if (!_distSelectedSet) {
        _distSelectedSet = [[NSMutableSet alloc] init];
    }
    CHECK_NIL(_distSelectedSet);
    return FALSE;
}

- (void) cityMutualSetAdd: (NSNumber*) cityIndex
{
    if (!_citySelectedSet) {
        _citySelectedSet = [[NSMutableSet alloc] init];
    }
    [_citySelectedSet addObject:cityIndex];
}

- (void) distanceMutualSetAdd: (float) distance
{
    if (!_distSelectedSet) {
        _distSelectedSet = [[NSMutableSet alloc] init];
    }
    [_distSelectedSet addObject:[NSNumber numberWithFloat:distance]];
}

- (void) categoryMutualSetAdd: (NSString*) categoryString
{
    CHECK_NIL(categoryString);
    if (!_categorySelectedSet) {
        _categorySelectedSet = [[NSMutableSet alloc] init];
    }
    [_categorySelectedSet addObject:categoryString];
}

- (NSString*) citySQLConstraint
{
    if (nil == _citySelectedSet || 0 == [_citySelectedSet count]) {
        return nil;
    }
    return [self normalSQLConstraint:_citySelectedSet sqlEntry:EXPO_REGION OutputType:EQUAL_TYPE];
}

- (NSString*) activitySQLConstraint
{
    if (nil == _activitySelectedSet || 0 == [_activitySelectedSet count]) {
        return nil;
    }
    if (1 != [_activitySelectedSet count]) {
        DLog(@"should not in here");
        assert(0);
    }
    NSArray* array = [_activitySelectedSet allObjects];
    CHECK_NIL(array);
    switch ([[array objectAtIndex:0] intValue]) {
        case ALL_ACTIVITY:
            return nil;
        case START_ACTIVITY:
            return [[NSString alloc] initWithFormat:@" and %@ <= \"%@\"", EXPO_START_DATE, [NSDateHandler LocalDateStringGet:OUTPUT_DATE_FORMATTER]];
        case NONSTART_ACTIVITY:
            return [[NSString alloc] initWithFormat:@" and %@ > \"%@\"", EXPO_START_DATE, [NSDateHandler LocalDateStringGet:OUTPUT_DATE_FORMATTER]];
        default:
            DLog(@"should not in here %i", [[array objectAtIndex:0] intValue]);
            assert(0);
            return nil;
    }
}

- (float) distanceConstraint
{
    float defaultDistance = DISTANCE_10KM;
    if (nil == _distSelectedSet || 0 == [_distSelectedSet count]) {
        return 0;
    }
    if (1 != [_distSelectedSet count]) {
        DLog(@"should not in here");
        assert(0);
    }
    NSArray* array = [_distSelectedSet allObjects];
    CHECK_NIL(array);
    switch ([[array objectAtIndex:0] intValue]) {
        case MIN_DISTANCE:
            return DISTANCE_5KM;
        case DEFAULT_DISTANCE:
            return defaultDistance;
        case MAX_DISTANCE:
            return DISTANCE_20KM;
        default:
            DLog(@"should not in here");
            assert(0);
            return DISTANCE_10KM;
    }
}

- (NSString*) categorySQLConstraint
{
    if (nil == _categorySelectedSet || 0 == [_categorySelectedSet count]) {
        return nil;
    }
    return [self normalSQLConstraint:_categorySelectedSet sqlEntry:EXPO_CATEGORY OutputType:LIKE_TYPE];
}

- (NSString*) searchSQLConstraint
{
    if (nil == _searchText) {
        return nil;
    }
    return  _searchText;
}

- (NSString*) normalSQLConstraint: (NSMutableSet*)inSet sqlEntry: (NSString*) EntryName OutputType: (int) flag
{
    CHECK_NIL(inSet);
    CHECK_NIL(EntryName);
    if (0 == [inSet count]) {
        return nil;
    }
    
    NSArray* array = [inSet allObjects];
    NSString* constraintSQL = [[NSString alloc] init];
    constraintSQL = [constraintSQL stringByAppendingFormat:@" and ("];
    for (int i = 0; i < [array count]; i++) {
        if (EQUAL_TYPE == flag) {
            constraintSQL = [constraintSQL stringByAppendingFormat:@" %@ = %@ ", EntryName, [array objectAtIndex:i]];
        } else {
            constraintSQL = [constraintSQL stringByAppendingFormat:@" %@ like \"%%%@%%\" ", EntryName, [array objectAtIndex:i]];
        }

        if (i != [array count] - 1) {
            constraintSQL = [constraintSQL stringByAppendingFormat:@"or"];
        }
    }
    constraintSQL = [constraintSQL stringByAppendingFormat:@")"];
    return constraintSQL;
}

+ (NSString*) dateSQLConstraint
{
    NSString* strSQL = [[NSString alloc] initWithFormat:@"%@ >= \"2012-09-01\"", EXPO_EDATE, [NSDateHandler LocalDateStringGet:EXPO_DATE_FORMATTER]];
    CHECK_NIL(strSQL);
    return strSQL;
}

+ (NSString*) searchTextSQLConstraintGenerate:(int)scopeIndex searchText:(NSString*)str
{
    if (nil == str) {
        return nil;
    }
    NSArray* pairArray = [SearchViewController scopeItemPair];
    CHECK_NIL(pairArray);
    if ([pairArray count] <= scopeIndex || 0 > scopeIndex) {
        CHECK_NOT_ENTER_HERE;
    }
    NSString* SQLconstraint = [[NSString alloc] init];
    NSArray* SQLItem = [[pairArray objectAtIndex:scopeIndex] objectAtIndex:1];
    SQLconstraint = [SQLconstraint stringByAppendingFormat:@" and ("];
    for (int i = 0; i < [SQLItem count]; i++) {
        SQLconstraint = [SQLconstraint stringByAppendingFormat:@"%@ like \"%%%@%%\"", [SQLItem objectAtIndex:i], str];
        if (i < [SQLItem count] - 1) {
            SQLconstraint = [SQLconstraint stringByAppendingFormat:@" or "];
        }
    }
    SQLconstraint = [SQLconstraint stringByAppendingFormat:@") "];
    return SQLconstraint;
}

+ (NSString*) searchTimeSQLConstraintGenerate:(NSDate*)strDate endDate:(NSDate*)endDate
{
    CHECK_NIL(strDate);
    CHECK_NIL(endDate);
    NSString* SQLcommand = @"and";
    NSString* SQLconstraint = nil;
    
    //This for start time (start time should be less than end search time)
    SQLconstraint = [[NSString alloc] initWithFormat:@" (%@ <= \"%@\"", EXPO_START_DATE, [NSDateHandler ConvertDate2NSStr:endDate dateFormat:EXPO_DATE_FORMATTER]];
    if (SQLconstraint) {
        SQLcommand = [SQLcommand stringByAppendingFormat:@"%@", SQLconstraint];
    }
    SQLcommand = [SQLcommand stringByAppendingFormat:@" and"];
    //This is for end time (end time should be greater than start search time)
    SQLconstraint = [[NSString alloc] initWithFormat:@" %@ >= \"%@\"", EXPO_END_DATE, [NSDateHandler ConvertDate2NSStr:strDate dateFormat:EXPO_DATE_FORMATTER]];
    if (SQLconstraint) {
        SQLcommand = [SQLcommand stringByAppendingFormat:@"%@)", SQLconstraint];
    }
    return SQLcommand;
}
@end
