//
//  NSDateHandler.h
//  ExhibitAPP
//
//  Created by sfffaaa sfffaaa on 12/9/16.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#define OUTPUT_DATE_FORMATTER @"yyyy-MM-dd"
#define FILE_DATE_FORMATTER @"yyMMdd"

@interface NSDateHandler : NSObject

+ (NSDate*) LocalDateGet: (NSString*) strDate dateFormat:(NSString*) strDateFormat;
+ (NSString*) LocalDateStringGet: (NSString*) strDateFormat;
+ (NSString*) ConvertDate2NSStr: (NSDate*)date dateFormat:(NSString*) strDateFormat;

@end
