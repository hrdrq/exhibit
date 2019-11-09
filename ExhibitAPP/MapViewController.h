//
//  ViewController.h
//  120827map
//
//  Created by eric on 12/8/27.
//  Copyright (c) 2012年 eric. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "Exhibit.h"
#import "REVClusterMap.h"
#import "MKNumberBadgeView.h"
#import "SingleAnnotation.h"
#import "ActivityListViewController.h"
#import "SQLConstraintMaker.h"
#import "BlockAlertView.h"

@interface MapViewController : UIViewController <MKMapViewDelegate, CLLocationManagerDelegate, UIActionSheetDelegate, BlockAlertViewDelegate, BlockAlertViewDataSource>
{
    CLGeocoder *geocoder;
}



@property (weak, nonatomic) IBOutlet REVClusterMapView *map;

@property (strong, nonatomic) ActivityListViewController *calloutTableViewController;
@property (strong, nonatomic) UIImageView *pageLineImage;
@property (strong, nonatomic) UIButton *expandButton;
@property (strong, nonatomic) UIButton *test;

@property (strong, nonatomic) NSArray *selectedAnnotations;
@property (weak, nonatomic) IBOutlet UIButton *userTrackingModeButton;
@property (strong, nonatomic) SQLConstraintMaker* sqlConstraintHandler;

- (IBAction)setUserTrackingMode;

- (IBAction)statusPressed:(UIButtonAboveTable *)sender;
- (IBAction)categoryPressed:(UIButtonAboveTable *)sender;

@property (nonatomic, assign) BOOL centering;
- (void)showData;

@end
