//
//  FileHandler.h
//  ExhibitAPP
//
//  Created by sfffaaa sfffaaa on 12/9/15.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FileHandler : NSObject

+ (FileHandler*) InstanceGet;
- (NSString*) DirPathGet;
- (NSString*) LastUpdateFileNameGet: (NSMutableArray*) exclusiveFileNameArray;
- (BOOL) FileRemove: (NSMutableArray*) exclusiveFileNameArray;
- (BOOL) IsFileExist: (NSString*) fileName;
- (BOOL) IsUpdateFolderEmpty: (NSMutableArray*) exclusiveFileNameArray;


@end
