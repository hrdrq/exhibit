//
//  DetailExhibitViewController.h
//  ExhibitAPP
//
//  Created by sfffaaa sfffaaa on 12/8/29.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIImageView+WebCache.h"

@interface DetailExhibitViewController : UIViewController<SDWebImageManagerDelegate>
@property (strong, nonatomic) IBOutlet UILabel *_titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *_timeLabel;
@property (strong, nonatomic) IBOutlet UILabel *_dtimeLabel;
@property (strong, nonatomic) IBOutlet UILabel *_placeLabel;
@property (strong, nonatomic) IBOutlet UILabel *_priceLabel;
@property (strong, nonatomic) IBOutlet UILabel *_pageLabel;
@property (strong, nonatomic) IBOutlet UILabel *_infoLabel;
@property (strong, nonatomic) IBOutlet UIImageView *_imageView;

- (BOOL) DetailDataSetup: (NSString*) title regionID:(int) region;

@end
