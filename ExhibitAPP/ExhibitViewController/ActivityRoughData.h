//
//  RoughExhibitData.h
//  ExhibitAPP
//
//  Created by sfffaaa sfffaaa on 12/9/2.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h> 

@interface ActivityRoughData : NSObject
{
    int _region;
}

@property (strong, nonatomic) NSString* _title;
@property (strong, nonatomic) NSString* _imageURL;
@property (strong, nonatomic) NSString* _date;
@property (strong, nonatomic) CLLocation* _locate;

- (void) setRegion: (int)input;
- (int) getRegion;

@end
