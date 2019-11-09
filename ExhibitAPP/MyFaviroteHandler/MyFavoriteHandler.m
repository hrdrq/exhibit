//
//  MyFavoriteHandler.m
//  ExhibitAPP
//
//  Created by sfffaaa on 12/11/9.
//
//

#import "MyFavoriteHandler.h"
#import "MyFavoriteDBBehavior.h"
#import "../DebugUtil.h"

@interface MyFavoriteHandler()

@property (strong, nonatomic) NSMutableArray* _elementArray;

@end

@implementation MyFavoriteHandler

@synthesize _elementArray;
@synthesize _behaviorDelegate;
@synthesize _dataSetupDelegate;

+(MyFavoriteHandler*) InstanceGet
{
    static MyFavoriteHandler *manager = nil;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        manager = [[MyFavoriteHandler alloc] init];
        manager._behaviorDelegate = [MyFavoriteDBBehavior AbtractLayerDelegate];
        manager._dataSetupDelegate = [MyFavoriteDBBehavior DataSetupDelegate];
    });
    return manager;
}

-(id<ActivityListDataSetupProtocol>) DataSetupProtocolGet
{
    return _dataSetupDelegate;
}

#pragma mark - public function
/*
 *  Return: FALSE -> success
 *           TRUE -> Error
 *
 */
-(BOOL) ItemAdd: (ActivityRoughData*) roughData
{
    CHECK_NIL(roughData);
    CHECK_NIL(_behaviorDelegate);
    return [_behaviorDelegate ItemAdd:roughData];
}

#pragma mark - public function
/*
 *  Return: FALSE -> success
 *           TRUE -> Error
 */
-(BOOL) ItemRemove: (ActivityRoughData*) roughData
{
    CHECK_NIL(roughData);
    CHECK_NIL(_behaviorDelegate);
    return [_behaviorDelegate ItemRemove:roughData];
}

//If success return false, else return true;
-(BOOL) ItemRemoveAll
{
    CHECK_NIL(_behaviorDelegate);
    return [_behaviorDelegate ItemRemoveAll];
}

-(NSMutableArray*) ItemSelect
{
    //If my favorite doesn't be modified, it can return directly.
    CHECK_NIL(_behaviorDelegate);
    return [_behaviorDelegate ItemSelect];
}

#pragma mark - private function
/*
 return: 1 -> Exist
         0 -> Non-Exist
        -1 -> Error
*/
-(int) ItemIsExist: (ActivityRoughData*) roughData
{
    CHECK_NIL(roughData);
    CHECK_NIL(_behaviorDelegate);
    return [_behaviorDelegate ItemIsExist:roughData];
}

@end

