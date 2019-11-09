//
//  UserChoosenTableViewController.m
//  ExhibitAPP
//
//  Created by sfffaaa sfffaaa on 12/8/26.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "MainPageViewController.h"
#import "CityViewController.h"
#import "Exhibit.h"
#import "SDImageCache.h"
#import "SQLDefine.h"

#define kButtonTouchedTint 1
#define kWaitingViewTag 999

#define ACTIVE_VIEW_X 90
#define ACTIVE_VIEW_Y 190
#define ACTIVE_VIEW_WIDTH 32
#define ACTIVE_VIEW_HEIGHT 32

#define ACTIVE_LABLE_X 130
#define ACTIVE_LABLE_Y 193
#define ACTIVE_LABLE_WIDTH 140
#define ACTIVE_LABLE_HEIGHT 30

@interface MainPageViewController ()

@end

@implementation MainPageViewController

- (void) CacheClearDueTime
{
    Updater* updateHandler = [Updater InstanceGet];
    CHECK_NIL(updateHandler);
    FMDatabase* db = [FMDatabase APPDatabaseGet:[updateHandler LastUpdateFilePathGet]];
    CHECK_NIL(db);
    NSString* dateSQL = [[NSString alloc] initWithFormat:@"%@ < \"%@\"", EXPO_EDATE, [NSDateHandler LocalDateStringGet:EXPO_DATE_FORMATTER]];
    CHECK_NIL(dateSQL)
    /*
     *  SQL command
     *  delet from expo where edate < "2012-09-16"
     */
    NSString* sql = [[NSString alloc] initWithFormat:@"select %@ from %@ where %@", EXPO_IMAGEURL, EXPO_TABLE_NAME, dateSQL];
    FMResultSet *dbResult = [db executeQuery:sql];
    SDImageCache* ImageCache = [SDImageCache sharedImageCache];
    while ([dbResult next]) {
        [ImageCache removeImageForKey:[dbResult stringForColumnIndex:0]];
    }
}
                     
- (void) DBUpdate
{
    Updater* updateHandler = [Updater InstanceGet];
    CHECK_NIL(updateHandler);
    FMDatabase* db = [FMDatabase APPDatabaseGet:[updateHandler LastUpdateFilePathGet]];
    CHECK_NIL(db);
    NSString* dateSQL = [[NSString alloc] initWithFormat:@"%@ < \"%@\"", EXPO_EDATE, [NSDateHandler LocalDateStringGet:EXPO_DATE_FORMATTER]];
    CHECK_NIL(dateSQL)
    /*
     *  SQL command
     *  delet from expo where edate < "2012-09-16"
     */
    NSString* NSsql = [[NSString alloc] initWithFormat:@"delete from %@ where %@", EXPO_TABLE_NAME, dateSQL];
    //[db executeUpdate:NSsql];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    Updater* updateHandler = [Updater InstanceGet];
    switch ([updateHandler FileDownload]) {
        case FILEDL_UPDATE:
            [self AddWaitingView];
            //Do CacheClearDueTime and DBUpdate by using delegate.
            [updateHandler set_delegateViewController:self];
        break;
        case FILEDL_FILEEXIST:
        case FILEDL_NONETWORK:
            [self CacheClearDueTime];
            [self DBUpdate];
        break;
        case FILEDL_NOFILE:
        default:
            DLog(@"File Download is no file here");
            break;
    }
    
    CLLocationManagerSingleton *locationManager = [CLLocationManagerSingleton sharedManager];
    [locationManager startUpdatingLocation];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark - waiting view
-(void) AddWaitingView
{
     CGRect frame = CGRectMake(ACTIVE_VIEW_X, ACTIVE_VIEW_Y, ACTIVE_VIEW_WIDTH, ACTIVE_VIEW_HEIGHT);

     UIActivityIndicatorView* progressInd = [[UIActivityIndicatorView alloc] initWithFrame:frame];
     [progressInd startAnimating];
     progressInd.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
 
     frame = CGRectMake(ACTIVE_LABLE_X, ACTIVE_LABLE_Y, ACTIVE_LABLE_WIDTH, ACTIVE_LABLE_HEIGHT);
     UILabel *waitingLable = [[UILabel alloc] initWithFrame:frame];
     waitingLable.text = @"Wait for DB";
     waitingLable.textColor = [UIColor whiteColor];
     waitingLable.font = [UIFont systemFontOfSize:20];;
     waitingLable.backgroundColor = [UIColor clearColor];
 
     frame = [[UIScreen mainScreen] bounds];
     UIView *theView = [[UIView alloc] initWithFrame:frame];
     theView.backgroundColor = [UIColor blackColor];
     theView.alpha = 0.7;
     [theView setTag:kWaitingViewTag];
     [theView addSubview:progressInd];
     [theView addSubview:waitingLable];
 
     [self.view addSubview: theView];
}
 
-(void)HideWaitingView
{
     [[self.view viewWithTag:kWaitingViewTag] removeFromSuperview];
}


@end
