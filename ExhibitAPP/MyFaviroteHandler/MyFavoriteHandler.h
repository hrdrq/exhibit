//
//  MyFavoriteHandler.h
//  ExhibitAPP
//
//  Created by sfffaaa on 12/11/9.
//
//

#import <Foundation/Foundation.h>

//[TODO], the include file should be replaced to the right directory
#import "../ActivityListViewControllerProtocol.h"
#import "../ActivityRoughData.h"

#define MYFAVORITE_STR_CANCEL @"取消我的最愛"
#define MYFAVORITE_STR_ADD    @"加到我的最愛"

/*
 * This protocol is for adding and removing the item in
 * my favorite view controller.
*/
@protocol MyFavoriteHandlerProtocol <NSObject>

- (void) MyFavoriteAdd: (ActivityRoughData*) favoriteData;
- (void) MyFavoriteRemove: (ActivityRoughData*) favoriteData;

@end

/*
 * This protocol is the abstract interface to my favaorite behavior.
 *
 * In other words, if someone want to implement the my favorite by other
 * data structure, mysql interface or other, please use this interface to
 * implement it.
 *
 * Note: each value function returns should be followed! Otherwise, the upper
 * layer, MyFavoriteHandler, will need be modified.
*/
@protocol MyFavoriteAbstractLayerProtocol <NSObject>
/*
 *  Return: FALSE -> success
 *           TRUE -> Error
 *
 */
-(BOOL) ItemAdd: (ActivityRoughData*) roughData;
/*
 *  Return: FALSE -> success
 *           TRUE -> Error
 */
-(BOOL) ItemRemove: (ActivityRoughData*) roughData;
/*
 return: 1 -> Exist
 0 -> Non-Exist
 -1 -> Error
 */
-(int) ItemIsExist: (ActivityRoughData*) roughData;
//If success return false, else return true;
-(BOOL) ItemRemoveAll;
-(NSMutableArray*) ItemSelect;

+(id<MyFavoriteAbstractLayerProtocol>) AbtractLayerDelegate;
+(id<ActivityListDataSetupProtocol>) DataSetupDelegate;
@end

@interface MyFavoriteHandler : NSObject

@property (strong, nonatomic) id<MyFavoriteAbstractLayerProtocol> _behaviorDelegate;
@property (strong, nonatomic) id<ActivityListDataSetupProtocol> _dataSetupDelegate;

+(MyFavoriteHandler*) InstanceGet;

-(BOOL) ItemAdd: (ActivityRoughData*) roughData;
-(BOOL) ItemRemove: (ActivityRoughData*) roughData;
-(int) ItemIsExist: (ActivityRoughData*) roughData;
-(BOOL) ItemRemoveAll;
-(NSMutableArray*) ItemSelect;

-(id<ActivityListDataSetupProtocol>) DataSetupProtocolGet;

@end