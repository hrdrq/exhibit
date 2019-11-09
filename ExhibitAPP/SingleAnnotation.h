//
//  MyAnnotation.h
//  120827map
//
//  Created by eric on 12/8/27.
//  Copyright (c) 2012年 eric. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>


#define	NAVIGATION_ANNOTATION_TYPE_START @"NavigationAnnotationTypeStart"
#define	NAVIGATION_ANNOTATION_TYPE_END @"NavigationAnnotationTypeEnd"
#define	NAVIGATION_ANNOTATION_TYPE_WAY_POINT @"NavigationAnnotationTypeWayPoint"


@interface SingleAnnotation : NSObject <MKAnnotation>

@property (nonatomic) int region;
@property (nonatomic, readonly, copy) NSString *groupTag;


-(id) initWithCoordinate:(CLLocationCoordinate2D)argCoordinate title:(NSString*)argTitle subtitle:(NSString*)argSubtitle groupTag:(NSString *)argGroupTag;

-(id) initWithCoordinate:(CLLocationCoordinate2D)argCoordinate title:(NSString*)argTitle region:(short)argRegion groupTag:(NSString *)argGroupTag;



@end
