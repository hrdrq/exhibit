//
//  RoughViewController.h
//  ExhibitAPP
//
//  Created by eric on 12/10/4.
//
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreLocation/CLLocationManagerDelegate.h>
#import "UIButtonAboveTable.h"

@interface RoughViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate>
@property (strong, nonatomic) NSMutableArray *_eachRoughExhibitData;
@property (strong, nonatomic) UIViewController *_topViewController;
@property (strong, nonatomic) IBOutlet UITableView *tableView;

- (BOOL) DataSetup: (int)cityindex;
- (void) DistanceSort:(UIBarButtonItem *)sender;
- (IBAction)statusPressed:(id)sender;
- (IBAction)sortingPressed:(id)sender;
- (IBAction)cityPressed:(id)sender;
- (IBAction)categoryPressed:(id)sender;
- (IBAction)zoomPressed:(id)sender;
- (IBAction)distancePressed:(id)sender;


@end
