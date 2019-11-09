//
//  MyFavoriteDBBehavior.m
//  ExhibitAPP
//
//  Created by sfffaaa on 12/11/13.
//
//

#import "MyFavoriteDBBehavior.h"
#import "../FMDB/FMDatabase.h"
#import "../Updater.h"
#import "../../ActivityListViewController.h"
#import "../SQLDefine.h"


#define DB_GET_REGION 

@interface MyFavoriteDBBehavior()

@property (strong, nonatomic) FMDatabase* _fmdbHandler;

@end

@implementation MyFavoriteDBBehavior
@synthesize _fmdbHandler;

-(void) dealloc
{
    if (FALSE == [FMDatabase APPMyFavoriteDatabaseRemove]) {
        CHECK_NOT_ENTER_HERE;
    }
}

+(MyFavoriteDBBehavior*) InstanceGet
{
    static MyFavoriteDBBehavior *behaviorManager = nil;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        behaviorManager = [[MyFavoriteDBBehavior alloc] init];
        Updater* updateHandler = [Updater InstanceGet];
        NSString* path = [updateHandler MyFavoriteFilePathGet];
        CHECK_NIL(path);
        behaviorManager._fmdbHandler = [FMDatabase APPMyFavoriteDBGet:path];
        [behaviorManager._fmdbHandler setShouldCacheStatements:YES];
        
        NSString* SqlStr = [[NSString alloc] initWithFormat: @"create table if not exists %@(%@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@)", MY_FAVORITE_TABLE_NAME,EXPO_REGION, EXPO_TITLE, EXPO_INFO, EXPO_IMAGEURL, EXPO_START_DATE, EXPO_END_DATE, EXPO_START_TIME, EXPO_END_TIME, EXPO_WEEK, EXPO_PLACE, EXPO_ADDRESS, EXPO_LATITUDE, EXPO_LONGITUDE, EXPO_PRICE, EXPO_TELEPHONE, EXPO_WEBURL, EXPO_CATEGORY];
        CHECK_NIL(SqlStr);
        if (NO == [behaviorManager._fmdbHandler executeUpdate:SqlStr]) {
            CHECK_NOT_ENTER_HERE;
        };
        
    });
    CHECK_NIL(behaviorManager);
    return behaviorManager;
}

#pragma mark - Finish MyFavoriteAbstractLayerProtocol
-(BOOL) ItemAdd: (ActivityRoughData*) roughData
{
    CHECK_NIL(_fmdbHandler);
    CHECK_NIL(roughData);
    CHECK_NIL(roughData._title);
    CHECK_VALUE(0, roughData._region);
    if (nil == roughData) {
        DLog(@"Error: wrong parameter");
        return TRUE;
    }
    int isExist = -1;
    if (-1 == (isExist = [self ItemIsExist:roughData])) {
        return TRUE;
    } else if (1 == isExist) {
        return FALSE;
    }
    
    //Get the detail data from db
    Updater* updateHandler = [Updater InstanceGet];
    CHECK_NIL(updateHandler);
    FMDatabase* db = [FMDatabase APPDatabaseGet:[updateHandler LastUpdateFilePathGet]];
    CHECK_NIL(db);
    //select * from expo where region = 28 and name = xxxxx and edate >= "2012-09-16"
    NSString* NSdetail = nil;
    if (roughData._region) {
        NSdetail = [[NSString alloc] initWithFormat:@"select \
            %@, %@, %@, \
            %@, %@, %@, \
            %@, %@, %@, \
            %@, %@, %@, \
            %@, %@, %@, \
            %@, %@ \
            from %@ where %@ = %i and %@ = \"%@\"",
            EXPO_REGION, EXPO_TITLE, EXPO_INFO,
            EXPO_IMAGEURL, EXPO_START_DATE, EXPO_END_DATE,
            EXPO_START_TIME, EXPO_END_TIME, EXPO_WEEK,
            EXPO_PLACE, EXPO_ADDRESS, EXPO_LATITUDE,
            EXPO_LONGITUDE, EXPO_PRICE, EXPO_TELEPHONE,
            EXPO_WEBURL, EXPO_CATEGORY,
            EXPO_TABLE_NAME,
            EXPO_REGION, roughData._region,
            EXPO_TITLE, roughData._title];
    } else {
        CHECK_NOT_ENTER_HERE;
    }
    FMResultSet *dbResult = [db executeQuery:NSdetail];
    CHECK_NIL(dbResult);
    
    while ([dbResult next]) {
        NSString* SQLstr = [[NSString alloc] initWithFormat:@"insert into %@\
        (%@, %@, %@, \
        %@, %@, %@, \
        %@, %@, %@, \
        %@, %@, %@, \
        %@, %@, %@, \
        %@, %@) \
        VALUES(\
        %@, \"%@\", \"%@\", \
        \"%@\", \"%@\", \"%@\", \
        %@, %@, %@, \
        \"%@\", \"%@\", \"%@\", \
        %@, \"%@\", \"%@\", \
        \"%@\", \"%@\")",
        MY_FAVORITE_TABLE_NAME,
        EXPO_REGION, EXPO_TITLE, EXPO_INFO,
        EXPO_IMAGEURL, EXPO_START_DATE, EXPO_END_DATE,
        EXPO_START_TIME, EXPO_END_TIME, EXPO_WEEK,
        EXPO_PLACE, EXPO_ADDRESS, EXPO_LATITUDE,
        EXPO_LONGITUDE, EXPO_PRICE, EXPO_TELEPHONE,
        EXPO_WEBURL, EXPO_CATEGORY,
        [NSNumber numberWithInt: roughData._region],
        roughData._title,
        [dbResult stringForColumn:EXPO_INFO],
        [dbResult stringForColumn:EXPO_IMAGEURL],
        [dbResult stringForColumn:EXPO_START_DATE],
        [dbResult stringForColumn:EXPO_END_DATE],
        [dbResult stringForColumn:EXPO_START_TIME],
        [dbResult stringForColumn:EXPO_END_TIME],
        [dbResult stringForColumn:EXPO_WEEK],
        [dbResult stringForColumn:EXPO_PLACE],
        [dbResult stringForColumn:EXPO_ADDRESS],
        [dbResult stringForColumn:EXPO_LATITUDE],
        [dbResult stringForColumn:EXPO_LONGITUDE],
        [dbResult stringForColumn:EXPO_PRICE],
        [dbResult stringForColumn:EXPO_TELEPHONE],
        [dbResult stringForColumn:EXPO_WEBURL],
        [dbResult stringForColumn:EXPO_CATEGORY]];
        [_fmdbHandler executeUpdate:SQLstr];
    }
    return FALSE;

}

-(BOOL) ItemRemove: (ActivityRoughData*) roughData
{
    CHECK_NIL(_fmdbHandler);
    CHECK_NIL(roughData);
    CHECK_NIL(roughData._title);
    CHECK_VALUE(0, roughData._region);
    if (nil == roughData) {
        DLog(@"Error: wrong parameter");
        return TRUE;
    }
    /*
     *  SQL command
     *  delet from expo where edate"
     */
    NSString* NSsql = [[NSString alloc] initWithFormat:@"delete from %@ where %@ = \"%@\" and %@ = %i", MY_FAVORITE_TABLE_NAME, EXPO_TITLE, roughData._title, EXPO_REGION, roughData._region];
    [_fmdbHandler executeUpdate:NSsql];
    return FALSE;
}
/*
 return: 1 -> Exist
 0 -> Non-Exist
 -1 -> Error
 */
-(int) ItemIsExist: (ActivityRoughData*) roughData
{
    CHECK_NIL(_fmdbHandler);
    CHECK_NIL(roughData);
    CHECK_NIL(roughData._title);
    CHECK_VALUE(0, roughData._region);
    if (nil == roughData) {
        DLog(@"Error: wrong parameter");
        return TRUE;
    }
    NSString* SQLCommand = [[NSString alloc] initWithFormat:@"select %@ from %@ where (%@ = \"%@\" and %@ = %i)", EXPO_REGION, MY_FAVORITE_TABLE_NAME, EXPO_TITLE, roughData._title, EXPO_REGION, roughData._region];
    
    FMResultSet *dbResult = [_fmdbHandler executeQuery:SQLCommand];
    
    while ([dbResult next]) {
        return 1;
    }
    return 0;
}

-(BOOL) ItemRemoveAll
{
    CHECK_NIL(_fmdbHandler);
    /*
     *  SQL command
     *  delet from expo where edate"
     */
    NSString* NSsql = [[NSString alloc] initWithFormat:@"delete from %@", MY_FAVORITE_TABLE_NAME];
    [_fmdbHandler executeUpdate:NSsql];
    return false;
}

-(NSMutableArray*) ItemSelect
{
    NSMutableArray* roughDataArray = [[NSMutableArray alloc] init];
    CHECK_NIL(roughDataArray);
    /*
     *  SQL command
     *  select name, pic, time, latitude, longtitudefrom expo where edate >= "2012-12-10"
     */
    NSString* SQLCommand = [[NSString alloc] initWithFormat:@"select %@, %@, %@, %@, %@, %@, %@, %@, %@, %@ from %@", EXPO_TITLE, EXPO_REGION, EXPO_IMAGEURL,  EXPO_START_DATE, EXPO_END_DATE, EXPO_START_TIME, EXPO_END_TIME, EXPO_PLACE,  EXPO_LATITUDE, EXPO_LONGITUDE, MY_FAVORITE_TABLE_NAME];
    
    FMResultSet *dbResult = [_fmdbHandler executeQuery:SQLCommand];
    
    while ([dbResult next]) {
        ActivityRoughData *exhibitdata = [[ActivityRoughData alloc] init];
        CHECK_NIL(exhibitdata);
        exhibitdata._title = [dbResult stringForColumn:EXPO_TITLE];
        exhibitdata._region = [dbResult intForColumn:EXPO_REGION];
        exhibitdata._place = [dbResult stringForColumn:EXPO_PLACE];
        exhibitdata._imageURL = [NSURL URLWithString:[dbResult stringForColumn:EXPO_IMAGEURL]];
        exhibitdata._locate = [[CLLocation alloc] initWithLatitude:[[dbResult stringForColumn:EXPO_LATITUDE] floatValue] longitude:[[dbResult stringForColumn:EXPO_LONGITUDE] floatValue]];
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"yyyy-MM-dd HH:mm zzzz";
        exhibitdata._startDate = [formatter dateFromString:[[dbResult stringForColumn:EXPO_START_DATE] stringByAppendingFormat:@" %01d:%01d +0800",[dbResult intForColumn:EXPO_START_TIME]/60,[dbResult intForColumn:EXPO_START_TIME]%60]];
        exhibitdata._endDate = [formatter dateFromString:[[dbResult stringForColumn:EXPO_END_DATE] stringByAppendingFormat:@" %01d:%01d +0800",[dbResult intForColumn:EXPO_END_TIME]/60,[dbResult intForColumn:EXPO_END_TIME]%60]];
        
        exhibitdata._startTime = [dbResult intForColumn:EXPO_START_TIME];
        exhibitdata._endTime = [dbResult intForColumn:EXPO_END_TIME];
        
        CHECK_NIL(exhibitdata._title);
        CHECK_NIL(exhibitdata._imageURL);
        CHECK_NIL(exhibitdata._locate);
        [roughDataArray addObject:exhibitdata];
    }
    return roughDataArray;
}

+(id<MyFavoriteAbstractLayerProtocol>) AbtractLayerDelegate
{
    return [MyFavoriteDBBehavior InstanceGet];
}

+(id<ActivityListDataSetupProtocol>) DataSetupDelegate
{
    return [MyFavoriteDBBehavior InstanceGet];
}

#pragma mark - Finish ActivityListDataSetupProtocol

- (NSMutableArray*) dataSetup: (SQLConstraintMaker*) sqlHandler
{
    NSMutableArray* dataArray = [[NSMutableArray alloc] init];
    CHECK_NIL(dataArray);
    
    /*
     *  SQL command
     *  select name, pic, time, latitude, longtitudefrom expo where edate >= "2012-12-10"
     */
    NSString* SQLCommand = [[NSString alloc] initWithFormat:@"select %@, %@, %@, %@, %@, %@, %@, %@, %@, %@ from %@ where edate <= \"3333-12-31\"", EXPO_TITLE, EXPO_REGION, EXPO_IMAGEURL,  EXPO_START_DATE, EXPO_END_DATE, EXPO_START_TIME, EXPO_END_TIME, EXPO_PLACE,  EXPO_LATITUDE, EXPO_LONGITUDE, MY_FAVORITE_TABLE_NAME];
    NSString* appendSQLConstraint = nil;
    float distance = 0;
    
    if (nil != sqlHandler) {
        if (nil != (appendSQLConstraint = [sqlHandler citySQLConstraint])) {
            SQLCommand = [SQLCommand stringByAppendingFormat:@"%@", appendSQLConstraint];
        }
        if (nil != (appendSQLConstraint = [sqlHandler categorySQLConstraint])) {
            SQLCommand = [SQLCommand stringByAppendingFormat:@"%@", appendSQLConstraint];
        }
        if (nil != (appendSQLConstraint = [sqlHandler activitySQLConstraint])) {
            SQLCommand = [SQLCommand stringByAppendingFormat:@"%@", appendSQLConstraint];
        }
        if (nil != (appendSQLConstraint = [sqlHandler searchSQLConstraint])) {
            SQLCommand = [SQLCommand stringByAppendingFormat:@"%@", appendSQLConstraint];
        }
        distance = [sqlHandler distanceConstraint];
    }
    
    FMResultSet *dbResult = [_fmdbHandler executeQuery:SQLCommand];
    
    while ([dbResult next]) {
        if (distance != 0) {
            CLLocation* location = [[CLLocation alloc] initWithLatitude:[[dbResult stringForColumn:EXPO_LATITUDE] floatValue] longitude:[[dbResult stringForColumn:EXPO_LONGITUDE] floatValue]];
            if ([location distanceFromLocation:[CLLocationManagerSingleton sharedManager].location] > distance *1000) {
                continue;
            }
        }
        
        ActivityRoughData *exhibitdata = [[ActivityRoughData alloc] init];
        CHECK_NIL(exhibitdata);
        exhibitdata._title = [dbResult stringForColumn:EXPO_TITLE];
        exhibitdata._region = [dbResult intForColumn:EXPO_REGION];
        exhibitdata._place = [dbResult stringForColumn:EXPO_PLACE];
        exhibitdata._imageURL = [NSURL URLWithString:[dbResult stringForColumn:EXPO_IMAGEURL]];
        exhibitdata._locate = [[CLLocation alloc] initWithLatitude:[[dbResult stringForColumn:EXPO_LATITUDE] floatValue] longitude:[[dbResult stringForColumn:EXPO_LONGITUDE] floatValue]];
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"yyyy-MM-dd HH:mm zzzz";
        exhibitdata._startDate = [formatter dateFromString:[[dbResult stringForColumn:EXPO_START_DATE] stringByAppendingFormat:@" %01d:%01d +0800",[dbResult intForColumn:EXPO_START_TIME]/60,[dbResult intForColumn:EXPO_START_TIME]%60]];
        exhibitdata._endDate = [formatter dateFromString:[[dbResult stringForColumn:EXPO_END_DATE] stringByAppendingFormat:@" %01d:%01d +0800",[dbResult intForColumn:EXPO_END_TIME]/60,[dbResult intForColumn:EXPO_END_TIME]%60]];
        
        exhibitdata._startTime = [dbResult intForColumn:EXPO_START_TIME];
        exhibitdata._endTime = [dbResult intForColumn:EXPO_END_TIME];
        
        CHECK_NIL(exhibitdata._title);
        CHECK_NIL(exhibitdata._imageURL);
        CHECK_NIL(exhibitdata._locate);
        [dataArray addObject:exhibitdata];
    }
    return dataArray;
}

@end
