//
//  RoughExhibitTableViewController.h
//  ExhibitAPP
//
//  Created by sfffaaa sfffaaa on 12/8/27.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h> 
#import <CoreLocation/CLLocationManagerDelegate.h>

@interface RoughExhibitTableViewController : UITableViewController <CLLocationManagerDelegate>
@property (strong, nonatomic) NSMutableArray *_eachRoughExhibitData;
@property (strong, nonatomic) UIViewController *_topViewController;

- (BOOL) DataSetup: (int)cityindex;
- (void) DistanceSort:(UIBarButtonItem *)sender;
    
@end
