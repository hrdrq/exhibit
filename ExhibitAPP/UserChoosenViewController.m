//
//  UserChoosenTableViewController.m
//  ExhibitAPP
//
//  Created by sfffaaa sfffaaa on 12/8/26.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "UserChoosenViewController.h"
#import "PlaceTableViewController.h"
#import "NSDateHandler.h"
#import "FMDatabase.h"
#import "DebugUtil.h"
#import "Updater.h"

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

@interface UserChoosenViewController ()

@end

@implementation UserChoosenViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    CHECK_NIL(self);
    return self;
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
    [db executeUpdate:NSsql];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    Updater* updateHandler = [Updater InstanceGet];

    if ([updateHandler IsUpdateFolderEmpty]) {
        [updateHandler FileDownload];
        [self AddWaitingView];
        [updateHandler set_delegateViewController:self];
    } else {
        //[updateHandler CacheDueClear];
        [self DBUpdate];
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (IBAction)addButtonTouchedTint:(id)sender {
    UIView* buttonTouchedTint = [[UIView alloc] initWithFrame:((UIView*)sender).frame];
    buttonTouchedTint.backgroundColor = [UIColor grayColor];
    buttonTouchedTint.alpha = 0.5;
    buttonTouchedTint.tag = kButtonTouchedTint;
    [self.view addSubview:buttonTouchedTint];
                    }

- (IBAction)removeButtonTouchedTint:(id)sender {
    if ([self.view viewWithTag:kButtonTouchedTint]) {
        [[self.view viewWithTag:kButtonTouchedTint] removeFromSuperview];
    }
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
