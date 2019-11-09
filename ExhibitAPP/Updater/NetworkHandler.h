//
//  NetworkHandler.h
//  ExhibitAPP
//
//  Created by sfffaaa sfffaaa on 12/9/15.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NetworkHandler : NSObject

+ (NetworkHandler*) InstanceGet;
- (BOOL) networkAvailable;

@end
