//
//  RoughExhibitWithoutNetworkTableViewCell.h
//  ExhibitAPP
//
//  Created by sfffaaa sfffaaa on 12/8/30.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RoughExhibitTableViewCellProtocol.h"

@interface RoughExhibitWithoutNetworkTableViewCell : UITableViewCell <RoughExhibitTableViewCellProtocol>
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UILabel *dateLabel;

@end
