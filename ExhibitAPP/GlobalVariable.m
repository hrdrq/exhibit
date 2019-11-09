//
//  GlobalVariable.m
//  ExhibitAPP
//
//  Created by eric on 12/10/7.
//
//

#import "GlobalVariable.h"

@implementation GlobalVariable

+ (NSArray *)cityName {
    static NSArray *city = nil;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"cityName" ofType:@"plist"];
        city = [[NSArray alloc]initWithContentsOfFile:plistPath];
    });
    return city;
}

+ (NSArray *)activityCategory {
    static NSArray *activity = nil;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"ActivityCategory" ofType:@"plist"];
        activity = [[NSArray alloc]initWithContentsOfFile:plistPath];
    });
    return activity;
}

+ (NSArray *)weekDay{
    static NSArray *week = nil;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        week = [[NSArray alloc]initWithObjects:@"一 ", @"二 ", @"三 ", @"四 ", @"五 ",
                @"六 ", @"日 ", nil];
    });
    return week;
}

@end
