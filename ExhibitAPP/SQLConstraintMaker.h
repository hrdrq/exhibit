//
//  SQLConstraintMaker.h
//  ExhibitAPP
//
//  Created by sfffaaa on 12/10/13.
//
//

#import <Foundation/Foundation.h>

@interface SQLConstraintMaker : NSObject

@property (strong, nonatomic) NSMutableSet* _citySelectedSet;
@property (strong, nonatomic) NSMutableSet* _distSelectedSet;
@property (strong, nonatomic) NSMutableSet* _activitySelectedSet;
@property (strong, nonatomic) NSMutableSet* _categorySelectedSet;
@property (strong, nonatomic) NSString* _searchText;

- (BOOL) activitySelectedSetAlloc;
- (BOOL) categorySelectedSetAlloc;
- (BOOL) citySelectedSetAlloc;
- (BOOL) distSelectedSetAlloc;

//TODO Wrap the NSMutableSet, doesn't let anybody to use it.
//- (BOOL) activitySelectedSetRemoveAll;

- (void) cityMutualSetAdd: (NSNumber*) cityIndex;
- (void) distanceMutualSetAdd: (float) distance;
- (void) categoryMutualSetAdd: (NSString*) categoryString;

- (NSString*) citySQLConstraint;
- (NSString*) activitySQLConstraint;
- (float) distanceConstraint;
- (NSString*) categorySQLConstraint;
- (NSString*) searchSQLConstraint;

+ (NSString*) dateSQLConstraint;
+ (NSString*) searchTextSQLConstraintGenerate:(int)scopeIndex searchText:(NSString*)str;
+ (NSString*) searchTimeSQLConstraintGenerate:(NSDate*)strDate endDate:(NSDate*)endDate;

@end
