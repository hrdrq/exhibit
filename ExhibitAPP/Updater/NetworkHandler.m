//
//  NetworkHandler.m
//  ExhibitAPP
//
//  Created by sfffaaa sfffaaa on 12/9/15.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "NetworkHandler.h"
#import <SystemConfiguration/SystemConfiguration.h>
#import "DebugUtil.h"

#import <arpa/inet.h>

@implementation NetworkHandler
{
    SCNetworkConnectionFlags _connectionFlags;
    SCNetworkReachabilityRef _reachability;
}

+ (NetworkHandler*) InstanceGet
{
    static NetworkHandler* instance = nil;
    if (nil == instance) {
        instance = [[NetworkHandler alloc] init];
    }
    CHECK_NIL(instance);
    return instance;
}


#pragma mark Checking Connections
- (void) pingReachabilityInternal
{
	if (!_reachability)
	{
		BOOL ignoresAdHocWiFi = NO;
		struct sockaddr_in ipAddress;
		bzero(&ipAddress, sizeof(ipAddress));
		ipAddress.sin_len = sizeof(ipAddress);
		ipAddress.sin_family = AF_INET;
		ipAddress.sin_addr.s_addr = htonl(ignoresAdHocWiFi ? INADDR_ANY : IN_LINKLOCALNETNUM);
		
		_reachability = SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, (struct sockaddr *)&ipAddress);
	}
	
	BOOL didRetrieveFlags = SCNetworkReachabilityGetFlags(_reachability, &_connectionFlags);
    if (FALSE == didRetrieveFlags) {
        DLog(@"cannot recover network reachability flags");
        assert(0);
    }
}

- (BOOL) networkAvailable
{
	[self pingReachabilityInternal];
	BOOL isReachable = ((_connectionFlags & kSCNetworkFlagsReachable) != 0);
    BOOL needsConnection = ((_connectionFlags & kSCNetworkFlagsConnectionRequired) != 0);
    return (isReachable && !needsConnection) ? YES : NO;
}

@end
