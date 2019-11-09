#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface CLLocationManagerSingleton : CLLocationManager

+ (CLLocationManagerSingleton *)sharedManager;
+ (BOOL)areLocationServicesAvailable;

@end
