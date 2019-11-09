//
//  RoughExhibitData.m
//  ExhibitAPP
//
//  Created by sfffaaa sfffaaa on 12/9/2.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "RoughExhibitData.h"

@implementation RoughExhibitData
@synthesize _date;
@synthesize _title;
@synthesize _imageURL;
@synthesize _locate;

- (void) setRegion: (int)input
{
    _region = input;
}
- (int) getRegion
{
    return _region;
}
@end
