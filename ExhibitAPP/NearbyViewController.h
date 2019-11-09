//
//  NearbyViewController.h
//  ExhibitAPP
//
//  Created by eric on 12/10/5.
//
//

#import <UIKit/UIKit.h>
#import "MapViewController.h"
#import "ActivityListViewControllerProtocol.h"

@interface NearbyViewController : UIViewController <ActivityListVCSegueFromOtherVCProtocol>

@property (strong, nonatomic) MapViewController *mvc;
@property (strong, nonatomic) ActivityListViewController *alvc;
- (IBAction)switchViews:(id)sender;
@end
