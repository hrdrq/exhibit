//
//  DetailExhibitTableViewController.h
//  ExhibitAPP
//
//  Created by eric on 12/9/26.
//
//

#import <UIKit/UIKit.h>
#import "ActivityInfoViewController.h"
#import "ActivityListViewControllerProtocol.h"
#import "ActivityRoughData.h"
#import "../ActivityListViewController.h"
#import "MyFaviroteHandler/MyFavoriteHandler.h"

@interface ActivityInfoViewController : UITableViewController< UIActionSheetDelegate, MyFavoriteHandlerProtocol>

@property (strong, nonatomic) ActivityRoughData* roughData;
@property (weak, nonatomic) id<UpdateActivityListTableViewProtocol> updateTableDelegate;
@property (weak, nonatomic) ActivityListViewController* fromFavorite;

@property (nonatomic) int week;
@property (strong, nonatomic) NSString *price;
@property (strong, nonatomic) NSString *page;
@property (strong, nonatomic) NSString *tel;
@property (strong, nonatomic) NSString *telNumberString;
@property (strong, nonatomic) NSString *telExtString;
@property (strong, nonatomic) NSString *info;
@property (strong, nonatomic) NSString *address;

- (BOOL) DetailDataSetup: (ActivityRoughData*) data;

@end
