#import "CLLocationManagerSingleton.h"

#ifndef __IPHONE_4_0
#error "This class uses features only available in iPhone SDK 4.0 and later."
#endif

#ifndef NSFoundationVersionNumber_iOS_4_2
#define NSFoundationVersionNumber_iOS_4_2  751.49
#endif

@implementation CLLocationManagerSingleton

+ (CLLocationManagerSingleton *)sharedManager {
    static CLLocationManagerSingleton *manager = nil;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        manager = [[CLLocationManagerSingleton alloc] init];
    });
    return manager;
}
+ (BOOL)areLocationServicesAvailable {
    BOOL available = [CLLocationManager locationServicesEnabled];
	if (NSFoundationVersionNumber >= NSFoundationVersionNumber_iOS_4_2) {
		CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
		CLAuthorizationStatus unknown = kCLAuthorizationStatusNotDetermined;
		CLAuthorizationStatus authorized = kCLAuthorizationStatusAuthorized;
		return (available && (status == unknown || status == authorized));
	}
	else {
		return available;
	}
}

@end
