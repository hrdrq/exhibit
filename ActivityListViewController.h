//
//  RoughViewController.h
//  ExhibitAPP
//
//  Created by eric on 12/10/4.
//
//

#define ACTIONSHEET_ALL_ACTIVITY @"所有活動"
#define ACTIONSHEET_START_ACTIVITY @"進行中活動"
#define ACTIONSHEET_NONSTART_ACTIVITY @"未開始活動"
#define ACTIONSHEET_SORT_BY_DISTANCE @"依距離排序"
#define ACTIONSHEET_SORT_BY_STARTDATE @"依開始日期排序"
#define ACTIONSHEET_SORT_BY_ENDDATE @"依結束日期排序"
#define ACTIONSHEET_DISTANCE_5KM @"5公里"
#define ACTIONSHEET_DISTANCE_10KM @"10公里"
#define ACTIONSHEET_DISTANCE_20KM @"20公里"
#define ACTIONSHEET_CANCEL @"取消"

#import <UIKit/UIKit.h>
#import "Exhibit.h"
#import "UIButtonAboveTable.h"
#import "SQLConstraintMaker.h"
#import "BlockAlertView.h"
#import "ExhibitAPP/ActivityListViewControllerProtocol.h"

@interface ActivityListViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate, UIActionSheetDelegate, BlockAlertViewDelegate, BlockAlertViewDataSource, ActivityListDataSetupProtocol>
@property (strong, nonatomic) NSMutableArray *_eachRoughExhibitData;
@property (strong, nonatomic) id<ActivityListVCSegueFromOtherVCProtocol> _segueProtocol;
@property (weak, nonatomic) id<ActivityListDataSetupProtocol> _dataSetupDelegate;
@property (strong, nonatomic) IBOutlet UITableView *table;
@property (strong, nonatomic) SQLConstraintMaker* _SQLConstraintHandler;
@property (strong, nonatomic) NSString* _searchText;

- (NSMutableArray*) dataSetup: (SQLConstraintMaker*) sqlHandler;
- (void) dataSetupSelf;
- (IBAction)statusPressed:(UIButtonAboveTable*)sender;
- (IBAction)sortingPressed:(UIButtonAboveTable*)sender;
- (IBAction)cityPressed:(UIButtonAboveTable*)sender;
- (IBAction)categoryPressed:(UIButtonAboveTable*)sender;
- (IBAction)distancePressed:(UIButtonAboveTable*)sender;



@end
