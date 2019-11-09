//
//  ViewController.m
//  120827map
//
//  Created by eric on 12/8/27.
//  Copyright (c) 2012年 eric. All rights reserved.
//

#import "MapViewController.h"
#import "FMDatabase.h"
#import "Updater.h"
#import "DebugUtil.h"
#import "SQLDefine.h"
#import "SQLConstraintMaker.h"

#import "ActivityInfoViewController.h"

#import <QuartzCore/QuartzCore.h> 

#import <math.h>

#define kTYPE1 @"Expo"
#define kTYPE2 @"Show"
#define kDEFAULTCLUSTERSIZE 0.2

#define UTILITY_BUTTON_HEIGHT 37
#define CALLOUT_TABLE_VIEW_CELL_HEIGHT 100
#define CALLOUT_TABLE_VIEW_CELL_SHOWUP_NUMBER 1
#define CALLOUT_TABLE_VIEW_CELL_NUMBER_MAX_TO_SHOW 3
#define CALLOUT_TABLE_VIEW_SHOWUP_HEIGHT CALLOUT_TABLE_VIEW_CELL_HEIGHT * CALLOUT_TABLE_VIEW_CELL_SHOWUP_NUMBER
#define IPHONE_WIDTH 320
#define CALLOUT_TABLE_VIEW_SHOWUP_RECT CGRectMake(0, UTILITY_BUTTON_HEIGHT, IPHONE_WIDTH, CALLOUT_TABLE_VIEW_SHOWUP_HEIGHT)
#define PAGE_LINE_IMAGE_HEIGHT 5
#define PAGE_LINE_IMAGE_SHOWUP_RECT CGRectMake(0, UTILITY_BUTTON_HEIGHT+CALLOUT_TABLE_VIEW_SHOWUP_HEIGHT, IPHONE_WIDTH, PAGE_LINE_IMAGE_HEIGHT)
#define EXPAND_BUTTON_HEIGHT 20
#define EXPAND_BUTTON_WIDTH 50
#define EXPAND_BUTTON_SHOWUP_RECT CGRectMake(IPHONE_WIDTH - EXPAND_BUTTON_WIDTH, UTILITY_BUTTON_HEIGHT+PAGE_LINE_IMAGE_HEIGHT + CALLOUT_TABLE_VIEW_SHOWUP_HEIGHT, EXPAND_BUTTON_WIDTH, EXPAND_BUTTON_HEIGHT)

#define tableIdentifier @"TableIdentifier"

#define cTitle 31
#define cDate 32
#define cDistance 33
#define cDays 34

#define IMAGE_LOCATION @"Location.png"
#define IMAGE_LOCATION_HEADING @"LocationHeading.png"

//---tag of action sheet--
enum{
    tagStatus,
};

@interface MapViewController ()

@end

@implementation MapViewController
@synthesize map;
@synthesize calloutTableViewController;
@synthesize pageLineImage;
@synthesize expandButton;
@synthesize selectedAnnotations;
@synthesize userTrackingModeButton;
@synthesize sqlConstraintHandler;

- (void)viewDidLoad
{
    self.map.delegate = self;
    if (nil == sqlConstraintHandler) {
        sqlConstraintHandler = [[SQLConstraintMaker alloc] init];
    }
    CHECK_NIL(sqlConstraintHandler);
    [self showData];

    self.userTrackingModeButton.alpha = 0.8;
    self.userTrackingModeButton.layer.cornerRadius = 8;
    [self.userTrackingModeButton setBackgroundColor:[UIColor grayColor]];
    [self.userTrackingModeButton setImage:[UIImage imageNamed:IMAGE_LOCATION] forState:UIControlStateNormal];
    
    self.map.region = MKCoordinateRegionMakeWithDistance([CLLocationManagerSingleton sharedManager].location.coordinate, 5000, 5000);

    [super viewDidLoad];

}

- (void)viewDidUnload
{
    [self setMap:nil];
    [self setCalloutTableViewController:nil];
    [self setPageLineImage:nil];
    [self setExpandButton:nil];
    [self setSelectedAnnotations:nil];
    [[CLLocationManagerSingleton sharedManager] stopUpdatingHeading];
    [self setUserTrackingModeButton:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (void)showData {
    
    NSMutableArray *mArray = [[NSMutableArray alloc] init];
    
    Updater* updateHandler = [Updater InstanceGet];
    CHECK_NIL(updateHandler);
    
    FMDatabase* db = [FMDatabase APPDatabaseGet:[updateHandler LastUpdateFilePathGet]];
    CHECK_NIL(db);
    NSString* dateSQL = [SQLConstraintMaker dateSQLConstraint];
    CHECK_NIL(dateSQL);
    
    /*
     *  SQL command
     */

    NSString* SQLCommand = [[NSString alloc] initWithFormat:@"select %@, %@, %@, %@ from %@ where %@", EXPO_LATITUDE, EXPO_LONGITUDE, EXPO_TITLE, EXPO_REGION, EXPO_TABLE_NAME, dateSQL];
    NSString* appendSQLConstraint = nil;
    if (nil != (appendSQLConstraint = [self.sqlConstraintHandler categorySQLConstraint])) {
        SQLCommand = [SQLCommand stringByAppendingFormat:@"%@", appendSQLConstraint];
    }
    if (nil != (appendSQLConstraint = [self.sqlConstraintHandler activitySQLConstraint])) {
        SQLCommand = [SQLCommand stringByAppendingFormat:@"%@", appendSQLConstraint];
    }

    FMResultSet *dbResult = [db executeQuery:SQLCommand];
    
    while ([dbResult next]) {
        
        REVClusterPin *annotation = [[REVClusterPin alloc] initWithCoordinate:(CLLocationCoordinate2D){.latitude = [dbResult doubleForColumn:EXPO_LATITUDE], .longitude = [dbResult doubleForColumn:EXPO_LONGITUDE]} title:[dbResult stringForColumn:EXPO_TITLE] region:[[dbResult stringForColumn:EXPO_REGION] floatValue]];
        
        [mArray addObject:annotation];
    }

    [self.map addAnnotations:mArray];

}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation{
    
    MKAnnotationView *annotationView;
    
    if([annotation isMemberOfClass: MKUserLocation.class]) {
		return annotationView;
	}

    REVClusterPin *pin = (REVClusterPin *)annotation;
    
    
    annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:@"annotationView"];
    
    if (!annotationView) {
        annotationView = [[MKAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:@"annotationView"];
        annotationView.canShowCallout = NO;
        annotationView.centerOffset = CGPointMake(0, 0); //圖片的中心點
        annotationView.image = [UIImage imageNamed:@"museum.png"];
        MKNumberBadgeView *badge = [[MKNumberBadgeView alloc] initWithFrame:CGRectMake(7,-27,50, 50)];
        badge.fillColor = THEME_COLOR_RED;
        badge.shine = NO;
        badge.hideWhenZero = YES;
        [annotationView addSubview:badge];
    }
    
    for (MKNumberBadgeView *badge in annotationView.subviews) {
        badge.value = [pin nodeCount];
    }

    return annotationView;
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    if([view.annotation isMemberOfClass: MKUserLocation.class]) {
		return ;
	}
    
    REVClusterPin *pin = (REVClusterPin *)view.annotation;

    if([pin nodeCount])
    {
        self.selectedAnnotations = pin.nodes;
    }
    else 
    {
        self.selectedAnnotations = [[NSArray alloc] initWithObjects:pin, nil];
    }
    
    self.centering = YES;
    [self.map setCenterCoordinate:view.annotation.coordinate animated:YES ];
    self.centering = NO;
    //[self.map selectAnnotation:pin animated:NO];
    
    /*if (self.calloutTableViewController) {
        [self.calloutTableViewController.tableView  setContentOffset:CGPointZero animated:NO];
    }else */{
        //self.calloutTableViewController = [[ActivityListViewController alloc]init];
        [self.calloutTableViewController.table  setContentOffset:CGPointZero animated:NO];
        self.calloutTableViewController.table = [[UITableView alloc]initWithFrame:CALLOUT_TABLE_VIEW_SHOWUP_RECT style:UITableViewStylePlain];
        self.calloutTableViewController.table.delegate = self.calloutTableViewController;
        self.calloutTableViewController.table.dataSource = self.calloutTableViewController;
        /*static int index = 1;
        if (index % 2) {
            self.calloutTableViewController._NSCellIdentifier = @"RoughExhibitWithNetworkTableViewCellIdentifier";
            _NSNibName = @"RoughExhibitWithNetworkTableViewCell";
        } else {
            _NSCellIdentifier = @"RoughExhibitWithoutNetworkTableViewCellIdentifier";
            _NSNibName = @"RoughExhibitWithoutNetworkTableViewCell";
        }*/
        [self.calloutTableViewController.table  setRowHeight:CALLOUT_TABLE_VIEW_CELL_HEIGHT];
        [self.calloutTableViewController.table setAlpha:0.8];
        //[tv setBackgroundColor:[UIColor lightGrayColor]];
        [self.calloutTableViewController.table setSeparatorColor:[UIColor blackColor]];
        self.calloutTableViewController.table.backgroundColor = [UIColor colorWithWhite:0.112 alpha:1.000];
    }
    //[self.calloutTableViewController.tableView setFrame:CALLOUT_TABLE_VIEW_SHOWUP_RECT];
    
    if (!self.calloutTableViewController._eachRoughExhibitData) {
        self.calloutTableViewController._eachRoughExhibitData = [[NSMutableArray alloc]init];
    }
    else {
        [self.calloutTableViewController._eachRoughExhibitData removeAllObjects];
    }
    
    //TODO: Need to revise
    Updater* updateHandler = [Updater InstanceGet];
    CHECK_NIL(updateHandler);
    
    FMDatabase* db = [FMDatabase APPDatabaseGet:[updateHandler LastUpdateFilePathGet]];
    CHECK_NIL(db);
    
    /*
     *  SQL command
     */
    NSString* dateSQL = [SQLConstraintMaker dateSQLConstraint];
    CHECK_NIL(dateSQL);
    
    
    for (REVClusterPin* annotation in self.selectedAnnotations) {
        
        NSString* NScity = [[NSString alloc] initWithFormat:@"select %@, %@ , %@ , %@ , %@ , %@ from %@ where %@ = %i and %@ = \"%@\" and %@",  EXPO_IMAGEURL, EXPO_START_DATE, EXPO_END_DATE, EXPO_START_TIME, EXPO_END_TIME, EXPO_PLACE, EXPO_TABLE_NAME , EXPO_REGION, annotation.region, EXPO_TITLE, annotation.title, dateSQL];
        FMResultSet *dbResult = [db executeQuery:NScity];
        
        while ([dbResult next]) {
            ActivityRoughData *exhibitdata = [[ActivityRoughData alloc] init];
            CHECK_NIL(exhibitdata);
            //TODO: store to activityroughdata
            exhibitdata._title = annotation.title;
            exhibitdata._place = [dbResult stringForColumn:EXPO_PLACE];
            exhibitdata._imageURL = [[NSURL alloc] initWithString:[dbResult stringForColumn:EXPO_IMAGEURL]];
            exhibitdata._locate = [[CLLocation alloc] initWithLatitude:annotation.coordinate.latitude longitude:annotation.coordinate.longitude];
            exhibitdata._region = annotation.region;
            
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            formatter.dateFormat = @"yyyy-MM-dd HH:mm zzzz";
            exhibitdata._startDate = [formatter dateFromString:[[dbResult stringForColumn:EXPO_START_DATE] stringByAppendingFormat:@" %01d:%01d +0800",[dbResult intForColumn:EXPO_START_TIME]/60,[dbResult intForColumn:EXPO_START_TIME]%60]];
            exhibitdata._endDate = [formatter dateFromString:[[dbResult stringForColumn:EXPO_END_DATE] stringByAppendingFormat:@" %01d:%01d +0800",[dbResult intForColumn:EXPO_END_TIME]/60,[dbResult intForColumn:EXPO_END_TIME]%60]];
            //TODO: Check valid
            exhibitdata._startTime = [dbResult intForColumn:EXPO_START_TIME];
            exhibitdata._endTime = [dbResult intForColumn:EXPO_END_TIME];
            
            CHECK_NIL(exhibitdata._title);
            CHECK_NIL(exhibitdata._imageURL);
            CHECK_NIL(exhibitdata._locate);
            [self.calloutTableViewController._eachRoughExhibitData addObject:exhibitdata];
        }        
    }
    //self.calloutTableViewController._topViewController = self;
    [self.calloutTableViewController.table  reloadData]; //不能在 _eachRoughExhibitData 建立完成前執行
    [self.view addSubview:self.calloutTableViewController.table];
    
    
    if (self.pageLineImage) {
        [self.pageLineImage setFrame:PAGE_LINE_IMAGE_SHOWUP_RECT];
        [self.view addSubview:self.pageLineImage];
    }
    else {
        UIImageView *img = [[UIImageView alloc]initWithFrame:PAGE_LINE_IMAGE_SHOWUP_RECT];
        img.image = [UIImage imageNamed:@"page_line.png"];
        self.pageLineImage = img;
        [self.view addSubview:self.pageLineImage];
    }
    
    if (self.selectedAnnotations.count > 1) {
        if (self.expandButton) {
            [self.expandButton setFrame:EXPAND_BUTTON_SHOWUP_RECT];
            [self.expandButton setImage:[UIImage imageNamed:@"expand_icon.png"] forState:UIControlStateNormal];
            [self.expandButton setTag:0];
            [self.view addSubview:self.expandButton];
        }
        else {
            UIButton *btn = [[UIButton alloc] initWithFrame:EXPAND_BUTTON_SHOWUP_RECT];
            [btn setImage:[UIImage imageNamed:@"expand_icon.png"] forState:UIControlStateNormal];
            [btn addTarget:self action:@selector(expandAndShrinkCalloutTable:) forControlEvents:UIControlEventTouchUpInside];
            self.expandButton = btn;
            [self.view addSubview:self.expandButton];
        }

    }

}

- (void)mapView:(MKMapView *)mapView //eric
didDeselectAnnotationView:(MKAnnotationView *)view
{
    [self.calloutTableViewController.table removeFromSuperview];
    [self.pageLineImage removeFromSuperview];
    [self.expandButton removeFromSuperview];
}

- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated
{
    if (self.centering) {
        return;
    }
    for (id<MKAnnotation> annotation in self.map.selectedAnnotations) {
        [self.map deselectAnnotation:annotation animated:NO];
    }
}

- (void) doExpandAndShrink: (CGFloat)targetCalloutTableViewHeight
{
    CGRect rect;
    
    rect = self.calloutTableViewController.table.frame;
    rect.size.height = targetCalloutTableViewHeight;
    self.calloutTableViewController.table.frame = rect;
    
    rect = self.pageLineImage.frame;
    rect.origin.y = UTILITY_BUTTON_HEIGHT + targetCalloutTableViewHeight;
    self.pageLineImage.frame = rect;
    
    rect = self.expandButton.frame;
    rect.origin.y = UTILITY_BUTTON_HEIGHT + PAGE_LINE_IMAGE_HEIGHT + targetCalloutTableViewHeight;
    self.expandButton.frame = rect;
}

- (void) expandAndShrinkCalloutTable: (id)sender
{
    [self.calloutTableViewController.table setContentOffset:CGPointZero animated:NO]; //若有捲過再按按鈕，會怪怪的，所以先讓它回到最上面
    
    if (self.expandButton.tag == 0) {
        [UIView animateWithDuration:0.6 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            [self doExpandAndShrink:self.selectedAnnotations.count > CALLOUT_TABLE_VIEW_CELL_NUMBER_MAX_TO_SHOW?CALLOUT_TABLE_VIEW_CELL_HEIGHT * CALLOUT_TABLE_VIEW_CELL_NUMBER_MAX_TO_SHOW : CALLOUT_TABLE_VIEW_CELL_HEIGHT * self.selectedAnnotations.count];
        } completion:^(BOOL finished){
            [self.expandButton setTag:1];
            [self.expandButton setImage:[UIImage imageNamed:@"shrink_icon.png"] forState:UIControlStateNormal];
            
        }];
    }
    else {
        [UIView animateWithDuration:0.6 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            [self doExpandAndShrink:CALLOUT_TABLE_VIEW_CELL_HEIGHT * CALLOUT_TABLE_VIEW_CELL_SHOWUP_NUMBER];
        } completion:^(BOOL finished){
            [self.expandButton setTag:0];
            [self.expandButton setImage:[UIImage imageNamed:@"expand_icon.png"] forState:UIControlStateNormal];
            
        }];
    }
}


- (IBAction)setUserTrackingMode {
    switch (self.map.userTrackingMode) {
        case MKUserTrackingModeNone:
            [self.map setUserTrackingMode:MKUserTrackingModeFollow animated:YES];
            //self.mapView.userTrackingMode = MKUserTrackingModeFollow;
            //self.userTrackingModeButton.backgroundColor = THEME_COLOR;
            break;
        case MKUserTrackingModeFollow:
            [self.map setUserTrackingMode:MKUserTrackingModeFollowWithHeading animated:YES];
            //self.mapView.userTrackingMode = MKUserTrackingModeFollowWithHeading;
            //[self.userTrackingModeButton setImage:[UIImage imageNamed: IMAGE_LOCATION_HEADING] forState:UIControlStateNormal];
            break;
        case MKUserTrackingModeFollowWithHeading:
            [self.map setUserTrackingMode:MKUserTrackingModeNone animated:YES];
            //self.mapView.userTrackingMode = MKUserTrackingModeNone;
            //self.userTrackingModeButton.backgroundColor = [UIColor grayColor];
            //[self.userTrackingModeButton setImage:[UIImage imageNamed:IMAGE_LOCATION] forState:UIControlStateNormal];
            break;
            
        default:
            break;
    }
}

-(void)mapView:(MKMapView *)mapView didChangeUserTrackingMode:(MKUserTrackingMode)mode animated:(BOOL)animated
{
    switch (mode) {
        case MKUserTrackingModeNone:
            self.userTrackingModeButton.backgroundColor = [UIColor grayColor];
            [self.userTrackingModeButton setImage:[UIImage imageNamed:IMAGE_LOCATION] forState:UIControlStateNormal];
            break;
        case MKUserTrackingModeFollow:
            self.userTrackingModeButton.backgroundColor = THEME_COLOR;
            [self.userTrackingModeButton setImage:[UIImage imageNamed:IMAGE_LOCATION] forState:UIControlStateNormal];
            break;
        case MKUserTrackingModeFollowWithHeading:
            self.userTrackingModeButton.backgroundColor = THEME_COLOR;
            [self.userTrackingModeButton setImage:[UIImage imageNamed:IMAGE_LOCATION_HEADING] forState:UIControlStateNormal];
            break;
            
        default:
            break;
    }
}

- (IBAction)categoryPressed:(UIButtonAboveTable *)sender {
    NSMutableArray *rowsSelected = [[NSMutableArray alloc]init];
    [sqlConstraintHandler categorySelectedSetAlloc];
    for (NSArray *category in [GlobalVariable activityCategory])
    {
        NSMutableArray *items = [[NSMutableArray alloc]init];
        for (NSArray *item in [category objectAtIndex:1])
        {
            if ([sqlConstraintHandler._categorySelectedSet containsObject:[item objectAtIndex:0]]) {
                [items addObject:[NSNumber numberWithBool:YES]];
            } else {
                [items addObject:[NSNumber numberWithBool:NO]];
            }
        }
        [rowsSelected addObject:items];
    }
    
    BlockAlertView *alert = [BlockAlertView alertWithTitle:@"依類別篩選" message:@"請選擇一種以上的類別進行篩選"];
    //using this for 
    __unsafe_unretained BlockAlertView* alertweak = alert;
    
    [alert addUtilityButtonWithTitle:@"選擇全部" fullWidth:NO block:^{ [self selectallInBlockAlert:alertweak tableView:alertweak.table]; }];
    [alert addUtilityButtonWithTitle:@"取消全部" fullWidth:NO block:^{ [self deselectallInBlockAlert:alertweak tableView:alertweak.table]; }];
    [alert addTableWithRowsNumberToShow:5 rowHeight:40.0 tag:1 style:UITableViewStylePlain data:rowsSelected];
    [alert setCancelButtonWithTitle:@"取消" fullWidth:NO block:nil];
    [alert setDestructiveButtonWithTitle:@"篩選" fullWidth:NO block:^{ [self doFilterInBlockAlert:alertweak]; }];
    [alert setDelegate:self];
    [alert setDataSource:self];
    
    [alert show];
    [sender setSelected:NO];
}

- (IBAction)statusPressed:(UIButtonAboveTable *)sender{

    BlockAlertView *alert = [BlockAlertView alertWithTitle:@"活動進行狀態篩選" message:nil];
    [alert addButtonWithTitle:ACTIONSHEET_ALL_ACTIVITY fullWidth:YES block:^{
        [self.sqlConstraintHandler activitySelectedSetAlloc];
        [self.sqlConstraintHandler._activitySelectedSet removeAllObjects];
        [self.sqlConstraintHandler._activitySelectedSet addObject: [NSNumber numberWithInt:ALL_ACTIVITY]];
        [self DataReload];
    }];
    [alert addButtonWithTitle:ACTIONSHEET_START_ACTIVITY fullWidth:YES block:^{
        [self.sqlConstraintHandler activitySelectedSetAlloc];
        [self.sqlConstraintHandler._activitySelectedSet removeAllObjects];
        [self.sqlConstraintHandler._activitySelectedSet addObject: [NSNumber numberWithInt:START_ACTIVITY]];
        [self DataReload];
    }];
    [alert addButtonWithTitle:ACTIONSHEET_NONSTART_ACTIVITY fullWidth:YES block:^{
        [self.sqlConstraintHandler activitySelectedSetAlloc];
        [self.sqlConstraintHandler._activitySelectedSet removeAllObjects];
        [self.sqlConstraintHandler._activitySelectedSet addObject: [NSNumber numberWithInt:NONSTART_ACTIVITY]];
        [self DataReload];
    }];
    [alert setCancelButtonWithTitle:ACTIONSHEET_CANCEL fullWidth:YES block:nil];
    
    [alert setTag:tagStatus];
    
    [alert show];
    [sender setSelected:NO];
}

#pragma mark - Methods for BlockAlertView

- (void)selectallInBlockAlert:(BlockAlertView *)blockAlert tableView:(UITableView *)tableView
{

    for (NSArray *category in [GlobalVariable activityCategory]) {
        for (NSArray *item in [category objectAtIndex:1]) {
            [[blockAlert.tableData objectAtIndex:[[GlobalVariable activityCategory] indexOfObject:category]] replaceObjectAtIndex:[[category objectAtIndex:1] indexOfObject:item] withObject:[NSNumber numberWithBool:YES]];
        }
    }

    [blockAlert.table reloadData];
}

- (void)deselectallInBlockAlert:(BlockAlertView *)blockAlert tableView:(UITableView *)tableView
{

    for (NSArray *category in [GlobalVariable activityCategory]) {
        for (NSArray *item in [category objectAtIndex:1]) {
            [[blockAlert.tableData objectAtIndex:[[GlobalVariable activityCategory] indexOfObject:category]] replaceObjectAtIndex:[[category objectAtIndex:1] indexOfObject:item] withObject:[NSNumber numberWithBool:NO]];
        }
    }
    
    [blockAlert.table reloadData];
}

- (void)doFilterInBlockAlert:(BlockAlertView *)blockAlert
{
    [sqlConstraintHandler._categorySelectedSet removeAllObjects];
    for (NSArray *category in [GlobalVariable activityCategory]) {
        for (NSArray *item in [category objectAtIndex:1]) {
            if([[[blockAlert.tableData objectAtIndex:[[GlobalVariable activityCategory] indexOfObject:category]] objectAtIndex:[[category objectAtIndex:1] indexOfObject:item]] boolValue]) {
                [sqlConstraintHandler._categorySelectedSet addObject:[item objectAtIndex:0]];
            }
        }
    }
    
    [self DataReload];
}

#pragma mark - delegate the action of sheet

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (actionSheet.tag) {
        case tagStatus:
            if (3 == buttonIndex) {
                assert(![[actionSheet buttonTitleAtIndex:buttonIndex] compare:ACTIONSHEET_CANCEL]);
                return;
            }
            [self.sqlConstraintHandler activitySelectedSetAlloc];
            [self.sqlConstraintHandler._activitySelectedSet removeAllObjects];
            if (0 == buttonIndex) {
                assert(![[actionSheet buttonTitleAtIndex:buttonIndex] compare:ACTIONSHEET_ALL_ACTIVITY]);
                [self.sqlConstraintHandler._activitySelectedSet addObject: [NSNumber numberWithInt:ALL_ACTIVITY]];
            } else if (1 == buttonIndex) {
                assert(![[actionSheet buttonTitleAtIndex:buttonIndex] compare:ACTIONSHEET_START_ACTIVITY]);
                [self.sqlConstraintHandler._activitySelectedSet addObject: [NSNumber numberWithInt:START_ACTIVITY]];
            } else if (2 == buttonIndex) {
                assert(![[actionSheet buttonTitleAtIndex:buttonIndex] compare:ACTIONSHEET_NONSTART_ACTIVITY]);
                [self.sqlConstraintHandler._activitySelectedSet addObject: [NSNumber numberWithInt:NONSTART_ACTIVITY]];
            } else {
                DLog(@"should not enter here");
                assert(0);
            }
            [self DataReload];
            break;
            break;
        default:
            DLog(@"error: shouldn't enter this");
            assert(0);
            break;
    }
}

- (void) DataReload
{
    //[self.map APPGOremoveAllAnnotation];
    //[self.map removeAnnotations:self.map.annotations];
    for (id<MKAnnotation>annotation in self.map.annotations) {
        if (![annotation isMemberOfClass:MKUserLocation.class]) {
            [self.map removeAnnotation:annotation];
        }
    }
    self.map.annotationsCopy = nil;
    [self showData];
}

#pragma mark - BlockAlertViewDelegate

- (void)blockAlert:(BlockAlertView *)blockAlert tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger row = [indexPath row];
    NSUInteger section = [indexPath section];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if ([[[blockAlert.tableData objectAtIndex:section] objectAtIndex:row] boolValue]) {
        [[blockAlert.tableData objectAtIndex:section] replaceObjectAtIndex:row withObject:[NSNumber numberWithBool:NO]];
        cell.accessoryType = UITableViewCellAccessoryNone;
    } else {
        [[blockAlert.tableData objectAtIndex:section] replaceObjectAtIndex:row withObject:[NSNumber numberWithBool:YES]];
        cell.accessoryType = UITableViewCellAccessoryCheckmark  ;
    }
    
}

#pragma mark - BlockAlertViewDatasource

- (UITableViewCell *)blockAlert:(BlockAlertView *)blockAlert tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"blockAlertViewTable"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"blockAlertViewTable"];
    }
    NSUInteger row = [indexPath row];
    NSUInteger section = [indexPath section];
    cell.textLabel.text = [[[[[GlobalVariable activityCategory] objectAtIndex:section]objectAtIndex:1]objectAtIndex:row]objectAtIndex:0];
    
    if ([[[blockAlert.tableData objectAtIndex:section] objectAtIndex:row] boolValue]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}
- (NSInteger)blockAlert:(BlockAlertView *)blockAlert tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[[[GlobalVariable activityCategory] objectAtIndex:section]objectAtIndex:1] count];
}

- (NSInteger)numberOfSectionsInBlockAlert:(BlockAlertView *)blockAlert tableView:(UITableView *)tableView
{
    return [[GlobalVariable activityCategory] count];
}
- (NSString *)blockAlert:(BlockAlertView *)blockAlert tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [[[GlobalVariable activityCategory] objectAtIndex:section]objectAtIndex:0];

}


@end
