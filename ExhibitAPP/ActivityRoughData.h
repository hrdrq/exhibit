//
//  ActivityRoughData.h
//  ExhibitAPP
//
//  Created by sfffaaa on 12/11/18.
//
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface ActivityRoughData : NSObject

@property (nonatomic) int _region;
@property (strong, nonatomic) NSString* _title;
@property (strong, nonatomic) NSURL* _imageURL;
@property (strong, nonatomic) NSDate* _startDate;
@property (strong, nonatomic) NSDate* _endDate;
@property (nonatomic) int _startTime;
@property (nonatomic) int _endTime;
@property (strong, nonatomic) NSString* _place;
@property (strong, nonatomic) CLLocation* _locate;

- (int) compare: (ActivityRoughData*) roughData;

@end