//
//  
//    ___  _____   ______  __ _   _________ 
//   / _ \/ __/ | / / __ \/ /| | / / __/ _ \
//  / , _/ _/ | |/ / /_/ / /_| |/ / _// , _/
// /_/|_/___/ |___/\____/____/___/___/_/|_| 
//
//  Created by Bart Claessens. bart (at) revolver . be
//

#import "REVClusterPin.h"


@implementation REVClusterPin
@synthesize title,coordinate,subtitle;
@synthesize nodes;
@synthesize region;

- (NSUInteger) nodeCount
{
    if( nodes )
        return [nodes count];
    return 0;
}

-(id) initWithCoordinate:(CLLocationCoordinate2D)argCoordinate title:(NSString*)argTitle region:(short)argRegion
{
    self = [super init];
    if(self)
    {
        coordinate = argCoordinate;
        title = argTitle;
        region = argRegion;
    }
    return self;
}

#if !__has_feature(objc_arc)
- (void)dealloc
{
    [title release];
    [subtitle release];
    [nodes release];
    [super dealloc];
}
#endif

@end
