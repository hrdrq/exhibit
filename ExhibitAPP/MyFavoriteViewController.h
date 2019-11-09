//
//  MyFavoriteViewController.h
//  ExhibitAPP
//
//  Created by sfffaaa on 12/11/11.
//
//

#import <UIKit/UIKit.h>
#import "MapViewController.h"
#import "ActivityListViewControllerProtocol.h"

@interface MyFavoriteViewController : UIViewController <ActivityListVCSegueFromOtherVCProtocol, UpdateActivityListTableViewProtocol>

@property (strong, nonatomic) ActivityListViewController *alvc;

@end
