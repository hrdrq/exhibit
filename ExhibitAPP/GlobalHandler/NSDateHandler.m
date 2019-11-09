//
//  NSDateHandler.m
//  ExhibitAPP
//
//  Created by sfffaaa sfffaaa on 12/9/16.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "NSDateHandler.h"
#import "DebugUtil.h"

@implementation NSDateHandler

+ (NSDate*) LocalDateGet: (NSString*) strDate dateFormat:(NSString*) strDateFormat
{
    CHECK_NIL(strDate);
    CHECK_NIL(strDateFormat);
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:strDateFormat];
    NSDate* oriDate = [dateFormatter dateFromString:strDate];
    NSTimeZone *timeZone = [NSTimeZone localTimeZone];
    NSInteger addTimeInterval = [timeZone secondsFromGMTForDate: oriDate];
    return [oriDate dateByAddingTimeInterval: addTimeInterval];    
}

+ (NSString*) ConvertDate2NSStr: (NSDate*)date dateFormat:(NSString*) strDateFormat
{
    CHECK_NIL(date);
    CHECK_NIL(strDateFormat);
    NSDateFormatter* dateForamtter = [[NSDateFormatter alloc] init];
    CHECK_NIL(dateForamtter);
    [dateForamtter setDateFormat:strDateFormat];
    return [dateForamtter stringFromDate:date];
}

+ (NSString*) LocalDateStringGet: (NSString*) strDateFormat
{
    CHECK_NIL(strDateFormat);
    return [self ConvertDate2NSStr:[NSDate date] dateFormat:strDateFormat];
}

@end
