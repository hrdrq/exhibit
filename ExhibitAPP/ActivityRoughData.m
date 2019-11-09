//
//  ActivityRoughData.m
//  ExhibitAPP
//
//  Created by sfffaaa on 12/11/18.
//
//

#import "ActivityRoughData.h"
#import "DebugUtil.h"

@implementation ActivityRoughData

@synthesize _region;
@synthesize _startDate;
@synthesize _endDate;
@synthesize _startTime;
@synthesize _endTime;
@synthesize _place;
@synthesize _title;
@synthesize _imageURL;
@synthesize _locate;

/*
 *  Return 0: the same
 *         1: different
 *        -1: error
 *
 */
- (int) compare: (ActivityRoughData*) roughData
{
    int ret = -1;
    CHECK_NIL(roughData);
    CHECK_NIL(roughData._title);
    CHECK_NIL(roughData._place);
    CHECK_NIL(_title);
    CHECK_NIL(_place);
    
    if (nil == roughData ||
        nil == roughData._title ||
        nil == roughData._place ||
        nil == _title ||
        nil == _place) {
        DLog(@"Error: wrong parameter");
        goto End;
    }
    if (0 != [_title compare:roughData._title]) {
        ret = 1;
        goto End;
    }
    if (0 != [_place compare:roughData._place]) {
        ret = 1;
        goto End;
    }
    ret = 0;
End:
    return ret;
}

@end
