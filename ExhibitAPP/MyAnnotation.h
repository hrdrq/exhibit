//
//  MyAnnotation.h
//  120827map
//
//  Created by eric on 12/8/27.
//  Copyright (c) 2012年 eric. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "OCGrouping.h"
#import "RoughExhibitData.h"

@interface MyAnnotation : NSObject <MKAnnotation, OCGrouping>

@property (nonatomic) int region;


-(id) initWithCoordinate:(CLLocationCoordinate2D)argCoordinate title:(NSString*)argTitle subtitle:(NSString*)argSubtitle groupTag:(NSString *)argGroupTag;

-(id) initWithCoordinate:(CLLocationCoordinate2D)argCoordinate title:(NSString*)argTitle region:(short)argRegion groupTag:(NSString *)argGroupTag;



@end
