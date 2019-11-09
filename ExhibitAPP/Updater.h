//
//  Updater.h
//  ExhibitAPP
//
//  Created by sfffaaa sfffaaa on 12/9/13.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MainPageViewController.h"

@interface Updater : NSObject
{
    NSString *_fileName;
}

@property (nonatomic, weak) MainPageViewController* _delegateViewController;

+ (Updater*) InstanceGet;
- (int) FileDownload;
- (NSString*) LastUpdateFilePathGet;
- (NSString*) MyFavoriteFilePathGet;
- (BOOL) IsUpdateFolderEmpty;

@end

typedef enum {
    FILEDL_UPDATE = 0,
    FILEDL_NONETWORK,
    FILEDL_FILEEXIST,
    FILEDL_NOFILE
} UPDATER_FILEDOWNLOAD;
