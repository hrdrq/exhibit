//
//  RoughExhibitWithNetworkTableViewCell.h
//  ExhibitAPP
//
//  Created by sfffaaa sfffaaa on 12/8/30.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RoughExhibitTableViewCellProtocol.h"
#import "UIImageView+WebCache.h"

@interface RoughExhibitWithNetworkTableViewCell : UITableViewCell <RoughExhibitTableViewCellProtocol, SDWebImageManagerDelegate>

@property (strong, nonatomic) IBOutlet UILabel* _nameLabel;
@property (strong, nonatomic) IBOutlet UILabel* _dateLabel;
@property (strong, nonatomic) IBOutlet UIImageView* _imageUIView;

@end
