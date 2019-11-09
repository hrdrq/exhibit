//
//  RoughExhibitTableViewCellProtocol.h
//  ExhibitAPP
//
//  Created by sfffaaa sfffaaa on 12/8/30.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol RoughExhibitTableViewCellProtocol <NSObject>

@optional
- (BOOL) setNameLabelinProctocol: (NSString*) NSName;
- (BOOL) setDateLableinProctocol: (NSString*) NSdate;

@required
- (BOOL) setImageinProctocol: (NSString*) NSImageURL;
@end

