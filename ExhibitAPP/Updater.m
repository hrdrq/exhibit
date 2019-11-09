//
//  Updater.m
//  ExhibitAPP
//
//  Created by sfffaaa sfffaaa on 12/9/13.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//


#import "FileHandler.h"
#import "NetworkHandler.h"
#import "Updater.h"
#import "DebugUtil.h"
#import "NSDateHandler.h"
#import "SQLDefine.h"

#define SERVER_HTML @"http://exhibitapp2012.appspot.com/db/"
#define SERVER_FILE @"expo.db"
#define UPDATE_FILE @"test"
#define UPDATE_SUFFIX @".db"

@interface Updater ()
{
    NSURLConnection *_ConnectionURL;    
    FileHandler *_FileHandler;
    NetworkHandler *_NetworkHandler;
}

@property (strong, nonatomic) NSMutableData *_UpdateData;
@end

@implementation Updater

@synthesize _delegateViewController;
@synthesize _UpdateData;


+ (Updater*) InstanceGet
{
    static Updater* updateHandler = nil;
    if (nil == updateHandler) {
        updateHandler = [[Updater alloc] init];
        CHECK_NIL(updateHandler);
    }
    return updateHandler;
}

- (id)init
{
    self = [super init];
    CHECK_NIL(self);
    [self FileHandlerSet];
    [self NetworkHandlerSet];
    return self;
}

- (void) FileHandlerSet
{
    _FileHandler = [FileHandler InstanceGet];
    CHECK_NIL(_FileHandler);
}

- (void) NetworkHandlerSet
{
    _NetworkHandler = [NetworkHandler InstanceGet];
    CHECK_NIL(_NetworkHandler);
}

- (NSDate*) FileName2Date: (NSString*) StrName
{
    CHECK_NIL(StrName);
    if ([UPDATE_FILE length] + 6 + [UPDATE_SUFFIX length] != [StrName length]) {
        DLog(@"wrong length");
        assert(0);
    }
    NSString* rawDateStr = [[NSString alloc] initWithFormat:@"%@", [StrName substringWithRange:NSMakeRange([UPDATE_FILE length], 6)]];
    CHECK_NIL(rawDateStr);
    return [NSDateHandler LocalDateGet:rawDateStr dateFormat:FILE_DATE_FORMATTER];
}


- (BOOL)NewUpdateNameGet
{
    NSString *strDate = [NSDateHandler LocalDateStringGet:FILE_DATE_FORMATTER];
    _fileName = [[NSString alloc] initWithFormat:@"%@%@%@", UPDATE_FILE, strDate, UPDATE_SUFFIX];
    CHECK_NIL(_fileName);
    
    return FALSE;
}

- (NSString*) LastUpdateFileNameGet
{
    CHECK_NIL(_FileHandler);
    NSString* name = [[NSString alloc] initWithFormat:@"%@", [_FileHandler LastUpdateFileNameGet:nil]];
    CHECK_NIL(name);
    return name;
}

- (NSString*) LastUpdateFilePathGet
{
    NSString* name = [self LastUpdateFileNameGet];
    CHECK_NIL(name);
    NSString* fullPath = [[NSString alloc] initWithFormat:@"%@/%@",[_FileHandler DirPathGet], name];
    CHECK_NIL(fullPath);
    return fullPath;
}

- (NSString*) MyFavoriteFilePathGet
{
    CHECK_NIL(_FileHandler);
    NSString* fullPath = [[NSString alloc] initWithFormat:@"%@/%@",
                          [_FileHandler DirPathGet], MY_FAVORITE_FILE];
    CHECK_NIL(fullPath);
    return fullPath;
}

- (BOOL) IsUpdateFolderEmpty;
{
    CHECK_NIL(_FileHandler);
    return [_FileHandler IsUpdateFolderEmpty:nil];
}

- (NSDate*) LastUpdateDate
{
    NSString* name = [self LastUpdateFileNameGet];
    CHECK_NIL(name);
    return [self FileName2Date:name];
}

- (int)FileDownload
{   
    CHECK_NIL(_NetworkHandler);
    CHECK_NIL(_FileHandler);
    
    [self NewUpdateNameGet];
    if (TRUE == [_FileHandler IsFileExist:_fileName]) {
        return FILEDL_FILEEXIST;
    }
    if (FALSE == [_NetworkHandler networkAvailable]) {
            if ([self IsUpdateFolderEmpty]) {
                return FILEDL_NOFILE;
            }
        DLog(@"cannot connect the network");
        return FILEDL_NONETWORK;
    }

    NSURL *fileURL = [NSURL URLWithString:[SERVER_HTML stringByAppendingFormat:@"%@", SERVER_FILE]];

    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:fileURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
    
    _ConnectionURL = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
    CHECK_NIL(_ConnectionURL);
    _UpdateData = [[NSMutableData alloc] init];
    CHECK_NIL(_UpdateData);
    return FILEDL_UPDATE;
}

///////////////////////////////////////////////////////////////
#pragma mark - Delegate
///////////////////////////////////////////////////////////////

-(void) connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
    int responseStatusCode = [httpResponse statusCode];
    if (404 == responseStatusCode) {
        DLog(@"wrong url");
        [connection cancel];
        return;
    }
    [_UpdateData setLength:0];
}

-(void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [_UpdateData appendData:data];
}

-(void) connectionDidFinishLoading:(NSURLConnection *)connection
{
    
    NSString *filePath = [[_FileHandler DirPathGet] stringByAppendingFormat:@"/%@", _fileName];
    [[NSFileManager defaultManager] createFileAtPath:filePath contents:_UpdateData attributes:nil];
#ifdef DEBUG
    sleep(3);
    DLog(@"save data over");
#endif

    NSMutableArray* exclusiveNameArray = [[NSMutableArray alloc] initWithObjects:_fileName, nil];
    CHECK_NIL(exclusiveNameArray);
    [_FileHandler FileRemove:exclusiveNameArray];
    CHECK_NIL(_delegateViewController);
    [_delegateViewController HideWaitingView];
    [_delegateViewController CacheClearDueTime];
    [_delegateViewController DBUpdate];
    _delegateViewController = nil;

}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error 
{  
    NSLog(@"Connection failed! Error - %@ %@", [error localizedFailureReason],  
    [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
    if (_delegateViewController) {
        [_delegateViewController HideWaitingView];
        _delegateViewController = nil;
    }
}  

@end
