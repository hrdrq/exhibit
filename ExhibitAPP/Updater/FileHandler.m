//
//  FileHandler.m
//  ExhibitAPP
//
//  Created by sfffaaa sfffaaa on 12/9/15.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "FileHandler.h"
#import "DebugUtil.h"
#import "../SQLDefine.h"

#define DS_STORE_FILE @".DS_Store"
#define DB_DIR @"DbStore"

NSMutableArray* gExclusiveFileNameArray = nil;

@interface FileHandler()
{
    NSFileManager *_FileManager;
    NSString *_DirPath;
}
@end

@implementation FileHandler

+ (FileHandler*) InstanceGet
{
    static FileHandler* instance = nil;
    if (nil == instance) {
        instance = [[FileHandler alloc] init];
    }
    CHECK_NIL(instance);
    return instance;
}

- (id)init
{
    self = [super init];
    CHECK_NIL(self);
    _FileManager = [NSFileManager defaultManager];
    CHECK_NIL(_FileManager);
    if (nil == gExclusiveFileNameArray) {
        gExclusiveFileNameArray = [[NSMutableArray alloc] initWithObjects:MY_FAVORITE_FILE, DS_STORE_FILE, nil];
    }
    CHECK_NIL(gExclusiveFileNameArray);
    return self;
}


//return false: ok
//return true:  error
- (BOOL) CreateDir: (NSString*) DirPath
{
    CHECK_NIL(DirPath);
    BOOL isDir = TRUE;
    NSError *error = nil;
    if (TRUE == [_FileManager fileExistsAtPath:DirPath isDirectory:&isDir]) {
        return FALSE;
    }
    if (FALSE == [_FileManager createDirectoryAtPath:DirPath withIntermediateDirectories:YES attributes:nil error:&error]) {
        DLog(@"cannot create the dir, %@", [error localizedFailureReason]);
        assert(0);
    }
    return false;
}

- (void) DirPathSet
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    if (nil == _DirPath) {
        _DirPath = [paths objectAtIndex:0];
        _DirPath = [_DirPath stringByAppendingFormat:@"/%@", DB_DIR];
        if (TRUE == [self CreateDir:_DirPath]) {
            DLog(@"cannot create paths");
            assert(0);
        }
    } else {
        NSString *nowpath = [paths objectAtIndex:0];
        nowpath = [nowpath stringByAppendingFormat:@"/%@", DB_DIR];
        if (NSOrderedSame != [_DirPath compare:nowpath]) {
            DLog(@"%@ != %@", _DirPath, [paths objectAtIndex:0]);
            assert(0);
        }
    }
}

- (NSString*) DirPathGet
{
    return _DirPath;    
}

- (BOOL) IsUpdateFolderEmpty: (NSMutableArray*) exclusiveFileNameArray
{
    NSError * error = nil;
    
    CHECK_NIL(_FileManager);
    if (nil == _DirPath) {
        [self DirPathSet];
    }
    NSArray *fileContents = [_FileManager contentsOfDirectoryAtPath:_DirPath error:&error];
    if (nil == fileContents) {
        DLog(@"%@", [error localizedDescription]);
        assert(0);
    }
    
    NSMutableArray* checkArray = [[NSMutableArray alloc] initWithArray:gExclusiveFileNameArray];
    if (nil == exclusiveFileNameArray) {
        [checkArray addObjectsFromArray:exclusiveFileNameArray];
    }
    CHECK_NIL(checkArray);
    
    for (NSString* fileName in fileContents) {
        BOOL comparePass = FALSE;
        for (int i = 0; i < [checkArray count]; i++) {
            if (NSOrderedSame == [fileName compare:[checkArray objectAtIndex:i]]) {
                [checkArray removeObjectAtIndex:i];
                comparePass = TRUE;
                break;
            }
        }
        if (TRUE == comparePass) {
            continue;
        }
        return FALSE;
    }
    return TRUE;
}

- (NSString*) LastUpdateFileNameGet: (NSMutableArray*) exclusiveFileNameArray
{
    NSString* LastUpdateFileName = nil;
    NSError * error = nil;
    int check_count = 0;
    
    CHECK_NIL(_FileManager);
    if (nil == _DirPath) {
        [self DirPathSet];
    }
    NSArray *fileContents = [_FileManager contentsOfDirectoryAtPath:_DirPath error:&error];
    if (nil == fileContents) {
        DLog(@"%@", [error localizedDescription]);
        assert(0);
    }
    NSMutableArray* checkArray = [[NSMutableArray alloc] initWithArray:gExclusiveFileNameArray];
    if (nil == exclusiveFileNameArray) {
        [checkArray addObjectsFromArray:exclusiveFileNameArray];
    }
    CHECK_NIL(checkArray);
    
    for (NSString* fileName in fileContents) {
        BOOL comparePass = FALSE;
        for (int i = 0; i < [checkArray count]; i++) {
            if (NSOrderedSame == [fileName compare:[checkArray objectAtIndex:i]]) {
                [checkArray removeObjectAtIndex:i];
                comparePass = TRUE;
                break;
            }
        }
        if (TRUE == comparePass) {
            continue;
        }
        LastUpdateFileName = fileName;
        check_count++;
    }
    if (1 != check_count) {
        DLog(@"wrong number");
        DLog(@"%@", LastUpdateFileName);        
        assert(0);
    }
    return LastUpdateFileName;
}

- (BOOL) FileRemove: (NSMutableArray*) exclusiveFileNameArray
{
    NSError *error = nil;
    NSMutableArray* checkArray = [[NSMutableArray alloc] initWithArray:gExclusiveFileNameArray];
    if (nil != exclusiveFileNameArray) {
        [checkArray addObjectsFromArray:exclusiveFileNameArray];
    }
    
    CHECK_NIL(_FileManager);
    CHECK_NIL(checkArray);
    
    if (nil == _DirPath) {
        [self DirPathSet];
    }
    NSArray* fileArray = [_FileManager contentsOfDirectoryAtPath:_DirPath error:&error];
    if (nil == fileArray) {
        DLog(@"%@", [error localizedFailureReason]);
        assert(0);
    }
    
    for (NSString *file in fileArray) {
        BOOL comparePass = FALSE;
        for (int i = 0; i < [checkArray count]; i++) {
            if (NSOrderedSame == [file compare:[checkArray objectAtIndex:i]]) {
                [checkArray removeObjectAtIndex:i];
                comparePass = TRUE;
                break;
            }
        }
        if (TRUE == comparePass) {
            continue;
        }

        BOOL success = [_FileManager removeItemAtPath:[NSString stringWithFormat:@"%@/%@", _DirPath, file] error:&error];
        if (!success || error) {
            DLog(@"%@", [error localizedFailureReason]);
            assert(0);
            return TRUE;
        }
    }
    return FALSE;
}


// return 0 : doesn't Exist
// return 1 : exist
- (BOOL) IsFileExist: (NSString*) fileName
{
    CHECK_NIL(_FileManager)
    CHECK_NIL(fileName);
    
    if (nil == _DirPath) {
        [self DirPathSet];
    }
    if (YES == [_FileManager fileExistsAtPath:[NSString stringWithFormat:@"%@/%@", _DirPath, fileName]]) {
        return TRUE;
    } else {
        return FALSE;
    }
    
    
}


@end
