//
//  MyAnnotation.m
//  120827map
//
//  Created by eric on 12/8/27.
//  Copyright (c) 2012年 eric. All rights reserved.
//

#import "MyAnnotation.h"

@implementation MyAnnotation

@synthesize coordinate;
@synthesize title;
@synthesize subtitle;
@synthesize region;
@synthesize groupTag;



-(id) initWithCoordinate:(CLLocationCoordinate2D)argCoordinate title:(NSString*)argTitle subtitle:(NSString*)argSubtitle groupTag:(NSString *)argGroupTag
{
    self = [super init];
    if(self)
    {
        coordinate = argCoordinate;
        title = argTitle;
        subtitle = argSubtitle;
        groupTag = argGroupTag;
    }
    return self;
}

-(id) initWithCoordinate:(CLLocationCoordinate2D)argCoordinate title:(NSString*)argTitle region:(short)argRegion groupTag:(NSString *)argGroupTag
{
    self = [super init];
    if(self)
    {
        coordinate = argCoordinate;
        title = argTitle;
        region = argRegion;
        groupTag = argGroupTag;
    }
    return self;
}

@end
