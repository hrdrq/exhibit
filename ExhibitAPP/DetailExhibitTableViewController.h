//
//  DetailExhibitTableViewController.h
//  ExhibitAPP
//
//  Created by eric on 12/9/26.
//
//

#import <UIKit/UIKit.h>
#import "UIImageView+WebCache.h"

@interface DetailExhibitTableViewController : UITableViewController<SDWebImageManagerDelegate, UIActionSheetDelegate>

@property (strong, nonatomic) NSString *titleString;
@property (strong, nonatomic) NSString *dateString;
@property (strong, nonatomic) NSString *timeString;
@property (strong, nonatomic) NSString *weekString;
@property (strong, nonatomic) NSString *placeString;
@property (strong, nonatomic) NSString *priceString;
@property (strong, nonatomic) NSString *pageString;
@property (strong, nonatomic) NSString *telString;
@property (strong, nonatomic) NSString *telNumberString;
@property (strong, nonatomic) NSString *telExtString;
@property (strong, nonatomic) NSString *infoString;
@property (strong, nonatomic) NSString *addressString;

@property (strong, nonatomic) UIImageView *_imageView;

- (BOOL) DetailDataSetup: (NSString*) title regionID:(int) region;

@end
