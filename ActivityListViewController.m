//
//  RoughViewController.m
//  ExhibitAPP
//
//  Created by eric on 12/10/4.
//
//

#import "ActivityListViewController.h"
#import "ActivityInfoViewController.h"
#import "UIImageView+WebCache.h"
#import "NSDateHandler.h"
#import "SQLDefine.h"
#import "SQLConstraintMaker.h"

#import "QuartzCore/CALayer.h"

#define DISTANCE_FILTER 3000.f

#define DISTANCE_5KM 5.
#define DISTANCE_10KM 10.
#define DISTANCE_20KM 20.

//---tag of table cell's lable--
#define TAG_IMAGE 1
#define TAG_TITLE 2
#define TAG_PLACE 3
#define TAG_DATE 4
#define TAG_TIME 5
#define TAG_DISTANCE 6
#define TAG_COUNTDOWN 7
/*
//---tag of action sheet--
enum {
    tagStatus,
    tagSort,
    tagDistance
};
 */

//---tag of block alert view---
enum {
    tagStatus,
    tagSort,
    tagDistance,
    tagCity,
    tagCategory
};


@interface ActivityListViewController ()

@property (strong, nonatomic) ActivityInfoViewController* _viewController;

- (void) StartTimeSort;
- (void) EndTimeSort;
- (void) DistanceSort;

@end

@implementation ActivityListViewController
@synthesize _eachRoughExhibitData;
@synthesize _viewController;
@synthesize _segueProtocol;
@synthesize _dataSetupDelegate;
@synthesize table;
@synthesize _SQLConstraintHandler;

- (id)init
{
    self = [super init];
    if (!self) {
        return nil;
    }
    if (nil == _SQLConstraintHandler) {
        _SQLConstraintHandler = [[SQLConstraintMaker alloc] init];
    }
    CHECK_NIL(_SQLConstraintHandler);
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    self.table.delegate = self;
    self.table.dataSource = self;
    self.table.separatorColor = [UIColor colorWithWhite:0.200 alpha:1.000];
    self.table.backgroundColor = [UIColor colorWithWhite:0.112 alpha:1.000];
    if (nil == _SQLConstraintHandler) {
        _SQLConstraintHandler = [[SQLConstraintMaker alloc] init];
    }
    CHECK_NIL(_SQLConstraintHandler);
   
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    _eachRoughExhibitData = nil;
    _viewController = nil;
    _segueProtocol = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (BOOL) SQLAppendActivityConstraint: (int)enumActivity output: (NSString**) outStr
{
    BOOL ret = true;
    NSString* compareDate = nil;
    CHECK_NIL(outStr);
    if (0 > enumActivity || ERROR_ACTIVITY <= enumActivity) {
        DLog(@"error");
    }
    if (ALL_ACTIVITY == enumActivity) {
        ret = false;
        goto Err;
    }
    if (START_ACTIVITY == enumActivity) {
        compareDate = [[NSString alloc] initWithFormat:@"%s", "<="];
    } else {
        compareDate = [[NSString alloc] initWithFormat:@"%s", ">"];
    }
    *outStr = [[NSString alloc] initWithFormat:@" and %@ %@ \"%@\"", EXPO_START_DATE, compareDate,[NSDateHandler LocalDateStringGet:OUTPUT_DATE_FORMATTER]];
    ret = false;
Err:
    return ret;
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (nil == _eachRoughExhibitData) {
        DLog(@"Error: wrong parameter");
        return 0;
    }else if(![_eachRoughExhibitData count]){
        return 1;
    }else{
        return [_eachRoughExhibitData count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([_eachRoughExhibitData count]) {
        
        NSUInteger row = [indexPath row];
        ActivityRoughData* data = [_eachRoughExhibitData objectAtIndex:row];

        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"listCell"];
        if (cell == nil) {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"ListCell" owner:self options:nil] objectAtIndex:0];
        }
        
        /*
        UIView *selectedView = [[UIView alloc]initWithFrame:cell.frame];
        selectedView.backgroundColor = THEME_COLOR_4;
        cell.selectedBackgroundView = selectedView;
        */
        UIImageView *selectedView = [[UIImageView alloc]initWithImage:[[UIImage imageNamed:@"selected.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(19, 149, 19, 149)]];
        cell.selectedBackgroundView = selectedView;
        cell.selectionStyle = UITableViewCellSelectionStyleGray;

        ((UILabel*)[cell viewWithTag:TAG_TITLE]).text = data._title;
        ((UILabel*)[cell viewWithTag:TAG_PLACE]).text = data._place;
        ((UILabel*)[cell viewWithTag:TAG_TIME]).text = [NSString stringWithFormat:@"%02d:%02d ~ %02d:%02d",data._startTime/60,data._startTime%60,data._endTime/60,data._endTime%60];

        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"yy.MM.dd";
        ((UILabel*)[cell viewWithTag:TAG_DATE]).text = [NSString stringWithFormat:@"%@ ~ %@",[formatter stringFromDate:data._startDate],[formatter stringFromDate:data._endDate]];

        CLLocationDistance distance = [[CLLocationManagerSingleton sharedManager].location distanceFromLocation:data._locate];
        if (distance < 1000) {
            ((UILabel*)[cell viewWithTag:TAG_DISTANCE]).text = [NSString stringWithFormat:@"%d 公尺",(int)distance];
        }
        else{
            ((UILabel*)[cell viewWithTag:TAG_DISTANCE]).text = [NSString stringWithFormat:@"%.1f 公里",distance/1000];
        }
        
        UILabel *labelCountdown = (UILabel*)[cell viewWithTag:TAG_COUNTDOWN];
        
        NSCalendar *calendar = [NSCalendar currentCalendar];
        
        NSUInteger unitFlags = NSMonthCalendarUnit | NSDayCalendarUnit;
        NSDate *now = [NSDate date];
        if ([now compare:data._endDate] == NSOrderedDescending)
        {
            labelCountdown.text = @"已結束";
            /*NSDateComponents *components = [calendar components:unitFlags fromDate:now toDate:data._startDate options:0];
            if ([components month]) {
                labelCountdown.text = [NSString stringWithFormat:@"於%d月%d天前結束",-[components month],-[components day]];
            } else {
                if ([components day]){
                    labelCountdown.text = [NSString stringWithFormat:@"已於%d天前結束",-[components day]];
                } else {
                    labelCountdown.text = [NSString stringWithFormat:@"即將結束"];
                }
                
            }*/
        }else{
            if ([now compare:data._startDate] == NSOrderedAscending) {
                NSDateComponents *components = [calendar components:unitFlags fromDate:now toDate:data._startDate options:0];
                if ([components month]) {
                    labelCountdown.text = [NSString stringWithFormat:@"還有%d月%d天開始",[components month],[components day]];
                } else {
                    if ([components day]){
                        labelCountdown.text = [NSString stringWithFormat:@"還有%d天開始",[components day]];
                    } else {
                        labelCountdown.text = [NSString stringWithFormat:@"即將開始"];
                    }
                    
                }
                
                //還有
            }
            else{
                NSDateComponents *components = [calendar components:unitFlags fromDate:now toDate:data._endDate options:0];
                //NSLog(@"%d %d",[components month],[components day]);
                if ([components month]) {
                    labelCountdown.text = [NSString stringWithFormat:@"還剩%d月%d天結束",[components month],[components day]];
                } else {
                    if([components day]){
                        labelCountdown.text = [NSString stringWithFormat:@"還剩%d天結束",[components day]];
                    } else {
                        labelCountdown.text = [NSString stringWithFormat:@"即將結束"];
                    }
                }
                
            }
        }
        
        UIImageView *imageView = (UIImageView *)[cell viewWithTag:TAG_IMAGE];
        
        [imageView setImageWithURL:data._imageURL placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
        /*imageView.layer.shadowColor = [UIColor grayColor].CGColor;
        //imageView.layer.shadowOffset = CGSizeMake(2.5, 2.5);
        imageView.layer.shadowOpacity = 1.0;
        imageView.layer.shadowRadius = 2.0;
        CGMutablePathRef shadowPath = CGPathCreateMutable();
        CGPathMoveToPoint(shadowPath, NULL, -4.0, -2.0);
        CGPathAddLineToPoint(shadowPath, NULL, -4.0, 86.0);
        CGPathAddLineToPoint(shadowPath, NULL, 84.0, 86.0);
        CGPathAddLineToPoint(shadowPath, NULL, 84.0, -2.0);
        CGPathAddLineToPoint(shadowPath, NULL, -2.0, -2.0);
        imageView.layer.shadowPath = shadowPath;*/
        
        //imageView.layer.cornerRadius = 1.5;
        imageView.layer.borderWidth = 1.5;
        imageView.layer.borderColor = [[UIColor whiteColor] CGColor];
        
        imageView.clipsToBounds = NO;
        
        return cell;

    } else {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"noDataCell"];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"noDataCell"];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.text = @"很抱歉，沒有找到符合條件的活動";
        cell.textLabel.textColor = [UIColor whiteColor];
        return cell;
    }
}

#pragma mark - Table view delegate

- (NSIndexPath*)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([_eachRoughExhibitData count]){
        if (_segueProtocol) {
            [_segueProtocol SegueFromAttachVC2OtherVC:indexPath];
        } else {
            [self performSegueWithIdentifier:@"toDetailExhibitTableViewController" sender:indexPath];
        }
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
    
    return indexPath;
}

#pragma mark - Segue

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    if ([[segue identifier] isEqualToString:@"toDetailExhibitTableViewController"]) {
        NSIndexPath *indexPath = sender;
        NSUInteger row = [indexPath row];
        ActivityInfoViewController *detvc = segue.destinationViewController;

        if ([detvc DetailDataSetup:[_eachRoughExhibitData objectAtIndex:row]]) {
            CHECK_NOT_ENTER_HERE
        }
    }
}

#pragma mark - methods of sorting and filtering buttons 

- (IBAction)statusPressed:(UIButtonAboveTable*)sender
{
    BlockAlertView *alert = [BlockAlertView alertWithTitle:@"活動進行狀態篩選" message:nil];
    [alert addButtonWithTitle:ACTIONSHEET_ALL_ACTIVITY fullWidth:YES block:^{
        [_eachRoughExhibitData removeAllObjects];
        [_SQLConstraintHandler activitySelectedSetAlloc];
        [_SQLConstraintHandler._activitySelectedSet removeAllObjects];
        [_SQLConstraintHandler._activitySelectedSet addObject: [NSNumber numberWithInt:ALL_ACTIVITY]];
        CHECK_NIL(_dataSetupDelegate);
        _eachRoughExhibitData = [_dataSetupDelegate dataSetup:_SQLConstraintHandler];
        [self.table reloadData];
    }];
    [alert addButtonWithTitle:ACTIONSHEET_START_ACTIVITY fullWidth:YES block:^{
        [_eachRoughExhibitData removeAllObjects];
        [_SQLConstraintHandler activitySelectedSetAlloc];
        [_SQLConstraintHandler._activitySelectedSet removeAllObjects];
        [_SQLConstraintHandler._activitySelectedSet addObject: [NSNumber numberWithInt:START_ACTIVITY]];
        CHECK_NIL(_dataSetupDelegate);
        _eachRoughExhibitData = [_dataSetupDelegate dataSetup:_SQLConstraintHandler];
        [self.table reloadData];
    }];
    [alert addButtonWithTitle:ACTIONSHEET_NONSTART_ACTIVITY fullWidth:YES block:^{
        [_eachRoughExhibitData removeAllObjects];
        [_SQLConstraintHandler activitySelectedSetAlloc];
        [_SQLConstraintHandler._activitySelectedSet removeAllObjects];
        [_SQLConstraintHandler._activitySelectedSet addObject: [NSNumber numberWithInt:NONSTART_ACTIVITY]];
        CHECK_NIL(_dataSetupDelegate);
        _eachRoughExhibitData = [_dataSetupDelegate dataSetup:_SQLConstraintHandler];
        [self.table reloadData];
    }];
    [alert setCancelButtonWithTitle:ACTIONSHEET_CANCEL fullWidth:YES block:nil];
    
    [alert setTag:tagStatus];
    
    [alert show];
    [sender setSelected:NO];
}


- (IBAction)sortingPressed:(UIButtonAboveTable*)sender
{
    BlockAlertView *alert = [BlockAlertView alertWithTitle:@"排序" message:nil];
    [alert addButtonWithTitle:ACTIONSHEET_SORT_BY_DISTANCE fullWidth:YES block:^{[self DistanceSort];}];
    [alert addButtonWithTitle:ACTIONSHEET_SORT_BY_STARTDATE fullWidth:YES block:^{[self StartTimeSort];}];
    [alert addButtonWithTitle:ACTIONSHEET_SORT_BY_ENDDATE fullWidth:YES block:^{[self EndTimeSort];}];
    [alert setCancelButtonWithTitle:ACTIONSHEET_CANCEL fullWidth:YES block:nil];

    [alert setTag:tagSort];
    
    [alert show];
    [sender setSelected:NO];
}

- (IBAction)distancePressed:(UIButtonAboveTable*)sender
{
    BlockAlertView *alert = [BlockAlertView alertWithTitle:@"與目前位置距離篩選" message:nil];
    [alert addButtonWithTitle:ACTIONSHEET_DISTANCE_5KM fullWidth:YES block:^{
        [_eachRoughExhibitData removeAllObjects];
        [_SQLConstraintHandler distSelectedSetAlloc];
        [_SQLConstraintHandler._distSelectedSet removeAllObjects];
        [_SQLConstraintHandler._distSelectedSet addObject: [NSNumber numberWithInt:MIN_DISTANCE]];
        CHECK_NIL(_dataSetupDelegate);
        _eachRoughExhibitData = [_dataSetupDelegate dataSetup:_SQLConstraintHandler];
        [self.table reloadData];
    }];
    [alert addButtonWithTitle:ACTIONSHEET_DISTANCE_10KM fullWidth:YES block:^{
        [_eachRoughExhibitData removeAllObjects];
        [_SQLConstraintHandler distSelectedSetAlloc];
        [_SQLConstraintHandler._distSelectedSet removeAllObjects];
        [_SQLConstraintHandler._distSelectedSet addObject: [NSNumber numberWithInt:DEFAULT_DISTANCE]];
        CHECK_NIL(_dataSetupDelegate);
        _eachRoughExhibitData = [_dataSetupDelegate dataSetup:_SQLConstraintHandler];
        [self.table reloadData];
    }];
    [alert addButtonWithTitle:ACTIONSHEET_DISTANCE_20KM fullWidth:YES block:^{
        [_eachRoughExhibitData removeAllObjects];
        [_SQLConstraintHandler distSelectedSetAlloc];
        [_SQLConstraintHandler._distSelectedSet removeAllObjects];
        [_SQLConstraintHandler._distSelectedSet addObject: [NSNumber numberWithInt:MAX_DISTANCE]];
        CHECK_NIL(_dataSetupDelegate);
        _eachRoughExhibitData = [_dataSetupDelegate dataSetup:_SQLConstraintHandler];
        [self.table reloadData];
    }];
    [alert setCancelButtonWithTitle:ACTIONSHEET_CANCEL fullWidth:YES block:nil];
    
    [alert setTag:tagDistance];
    
    [alert show];
    [sender setSelected:NO];
}

- (IBAction)cityPressed:(UIButtonAboveTable*)sender
{
    NSMutableArray *rowsSelected = [[NSMutableArray alloc]init];
    [_SQLConstraintHandler citySelectedSetAlloc];
    for (NSArray *region in [GlobalVariable cityName])
    {
        NSMutableArray *citys = [[NSMutableArray alloc]init];
        for (NSArray *city in [region objectAtIndex:1])
        {
            if ([_SQLConstraintHandler._citySelectedSet containsObject:[city objectAtIndex:1]]) {
                [citys addObject:[NSNumber numberWithBool:YES]];
            } else {
                [citys addObject:[NSNumber numberWithBool:NO]];
            }
        }
        [rowsSelected addObject:citys];
    }
    
    BlockAlertView *alert = [BlockAlertView alertWithTitle:@"依縣市篩選" message:@"請選擇一個以上的縣市進行篩選"];
    __unsafe_unretained BlockAlertView *alertweak = alert;
    
    [alert addUtilityButtonWithTitle:@"選擇全部" fullWidth:NO block:^{ [self selectallInBlockAlert:alertweak tableView:alertweak.table]; }];
    [alert addUtilityButtonWithTitle:@"取消全部" fullWidth:NO block:^{ [self deselectallInBlockAlert:alertweak tableView:alertweak.table]; }];
    [alert addTableWithRowsNumberToShow:5 rowHeight:40.0 tag:1 style:UITableViewStylePlain data:rowsSelected];
    [alert setCancelButtonWithTitle:@"取消" fullWidth:NO block:nil];
    [alert setDestructiveButtonWithTitle:@"篩選" fullWidth:NO block:^{ [self doFilterInBlockAlert:alertweak]; }];
    [alert setDelegate:self];
    [alert setDataSource:self];
    [alert setTag:tagCity];
    
    [alert show];
    [sender setSelected:NO];
}

- (IBAction)categoryPressed:(UIButtonAboveTable*)sender
{
    NSMutableArray *rowsSelected = [[NSMutableArray alloc]init];
    [_SQLConstraintHandler categorySelectedSetAlloc];
    for (NSArray *category in [GlobalVariable activityCategory])
    {
        NSMutableArray *items = [[NSMutableArray alloc]init];
        for (NSArray *item in [category objectAtIndex:1])
        {
            if ([_SQLConstraintHandler._categorySelectedSet containsObject:[item objectAtIndex:0]]) {
                [items addObject:[NSNumber numberWithBool:YES]];
            } else {
                [items addObject:[NSNumber numberWithBool:NO]];
            }
        }
        [rowsSelected addObject:items];
    }

    BlockAlertView *alert = [BlockAlertView alertWithTitle:@"依類別篩選" message:@"請選擇一種以上的類別進行篩選"];
    __unsafe_unretained BlockAlertView* alertBlock = alert;
    
    [alert addUtilityButtonWithTitle:@"選擇全部" fullWidth:NO block:^{ [self selectallInBlockAlert:alertBlock tableView:alertBlock.table]; }];
    [alert addUtilityButtonWithTitle:@"取消全部" fullWidth:NO block:^{ [self deselectallInBlockAlert:alertBlock tableView:alertBlock.table]; }];
    [alert addTableWithRowsNumberToShow:5 rowHeight:40.0 tag:1 style:UITableViewStylePlain data:rowsSelected];
    [alert setCancelButtonWithTitle:@"取消" fullWidth:NO block:nil];
    [alert setDestructiveButtonWithTitle:@"篩選" fullWidth:NO block:^{ [self doFilterInBlockAlert:alertBlock]; }];
    [alert setDelegate:self];
    [alert setDataSource:self];
    [alert setTag:tagCategory];
    
    [alert show];
    [sender setSelected:NO];
    
}

- (void) dataSetupSelf
{
    CHECK_NIL(self._dataSetupDelegate);
    self._eachRoughExhibitData = [self._dataSetupDelegate dataSetup:self._SQLConstraintHandler];
}

#pragma mark - sorting action 2 time sorting

- (void) StartTimeSort
{
    NSSortDescriptor *timeSortor = [[NSSortDescriptor alloc] initWithKey:@"_startDate" ascending:YES selector:@selector(compare:)];
    [_eachRoughExhibitData sortUsingDescriptors:[NSMutableArray arrayWithObject:timeSortor]];
    [self.table reloadData];
}

- (void) EndTimeSort
{
    NSSortDescriptor *timeSortor = [[NSSortDescriptor alloc] initWithKey:@"_endDate" ascending:YES selector:@selector(compare:)];
    [_eachRoughExhibitData sortUsingDescriptors:[NSMutableArray arrayWithObject:timeSortor]];
    [self.table reloadData];
}

- (BOOL) DataSort:(NSSortDescriptor*) SortDescriptor
{
    if (nil == SortDescriptor) {
        DLog(@"error");
        return TRUE;
    }
    [_eachRoughExhibitData sortUsingDescriptors:[NSMutableArray arrayWithObject:SortDescriptor]];
    return FALSE;
}

#pragma mark - Sorting action for location

//Implement in the delegate.
- (void) DistanceSort
{
    NSSortDescriptor *distanceSorter = [[NSSortDescriptor alloc] initWithKey:@"_locate" ascending:YES selector:@selector(distanceCompare:)];
    
    [_eachRoughExhibitData sortUsingDescriptors:[NSMutableArray arrayWithObject:distanceSorter]];
    [self.table reloadData];
}

#pragma mark - Methods for BlockAlertView

- (void)selectallInBlockAlert:(BlockAlertView *)blockAlert tableView:(UITableView *)tableView
{
    if (blockAlert.tag == tagCategory) {
        for (NSArray *category in [GlobalVariable activityCategory]) {
            for (NSArray *item in [category objectAtIndex:1]) {
                [[blockAlert.tableData objectAtIndex:[[GlobalVariable activityCategory] indexOfObject:category]] replaceObjectAtIndex:[[category objectAtIndex:1] indexOfObject:item] withObject:[NSNumber numberWithBool:YES]];
            }
        }
    }else if (blockAlert.tag == tagCity) {
        for (NSArray *region in [GlobalVariable cityName]) {
            for (NSArray *city in [region objectAtIndex:1]) {
                [[blockAlert.tableData objectAtIndex:[[GlobalVariable cityName] indexOfObject:region]] replaceObjectAtIndex:[[region objectAtIndex:1] indexOfObject:city] withObject:[NSNumber numberWithBool:YES]];
            }
        }
    }
    [blockAlert.table reloadData];
}

- (void)deselectallInBlockAlert:(BlockAlertView *)blockAlert tableView:(UITableView *)tableView
{
    if (blockAlert.tag == tagCategory) {
        for (NSArray *category in [GlobalVariable activityCategory]) {
            for (NSArray *item in [category objectAtIndex:1]) {
                [[blockAlert.tableData objectAtIndex:[[GlobalVariable activityCategory] indexOfObject:category]] replaceObjectAtIndex:[[category objectAtIndex:1] indexOfObject:item] withObject:[NSNumber numberWithBool:NO]];
            }
        }
    }else if (blockAlert.tag == tagCity) {
        for (NSArray *region in [GlobalVariable cityName]) {
            for (NSArray *city in [region objectAtIndex:1]) {
                [[blockAlert.tableData objectAtIndex:[[GlobalVariable cityName] indexOfObject:region]] replaceObjectAtIndex:[[region objectAtIndex:1] indexOfObject:city] withObject:[NSNumber numberWithBool:NO]];
            }
        }
    }
    [blockAlert.table reloadData];
}

- (void)doFilterInBlockAlert:(BlockAlertView *)blockAlert
{
    if (blockAlert.tag == tagCategory) {
        [_SQLConstraintHandler._categorySelectedSet removeAllObjects];
        for (NSArray *category in [GlobalVariable activityCategory]) {
            for (NSArray *item in [category objectAtIndex:1]) {
                if([[[blockAlert.tableData objectAtIndex:[[GlobalVariable activityCategory] indexOfObject:category]] objectAtIndex:[[category objectAtIndex:1] indexOfObject:item]] boolValue]) {
                    [_SQLConstraintHandler._categorySelectedSet addObject:[item objectAtIndex:0]];
                }
            }
        }
    } else if (blockAlert.tag == tagCity) {
        [_SQLConstraintHandler._citySelectedSet removeAllObjects];
        for (NSArray *region in [GlobalVariable cityName]) {
            for (NSArray *city in [region objectAtIndex:1]) {
                if([[[blockAlert.tableData objectAtIndex:[[GlobalVariable cityName] indexOfObject:region]] objectAtIndex:[[region objectAtIndex:1] indexOfObject:city]] boolValue]) {
                    [_SQLConstraintHandler._citySelectedSet addObject:[city objectAtIndex:1]];
                }
            }
        }
    }
    CHECK_NIL(_dataSetupDelegate);
    _eachRoughExhibitData = [_dataSetupDelegate dataSetup:_SQLConstraintHandler];
    [self.table reloadData];
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
/*
- (void)blockAlert:(BlockAlertView *)blockAlert buttonPressedAtIndex:(NSInteger)index
{
    if (blockAlert.tag == tagCategory) {
        for (NSArray *category in [GlobalVariable activityCategory]) {
            for (NSArray *item in [category objectAtIndex:1]) {
                [[blockAlert.tableData objectAtIndex:[[GlobalVariable activityCategory] indexOfObject:category]] replaceObjectAtIndex:[[category objectAtIndex:1] indexOfObject:item] withObject:[NSNumber numberWithBool:YES]];
            }
        }
        [self.table reloadData];
    }
}
*/
#pragma mark - BlockAlertViewDatasource

- (UITableViewCell *)blockAlert:(BlockAlertView *)blockAlert tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"blockAlertViewTable"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"blockAlertViewTable"];
    }
    NSUInteger row = [indexPath row];
    NSUInteger section = [indexPath section];
    if (blockAlert.tag == tagCategory) {
        cell.textLabel.text = [[[[[GlobalVariable activityCategory] objectAtIndex:section]objectAtIndex:1]objectAtIndex:row]objectAtIndex:0];
    }else if (blockAlert.tag == tagCity) {
        cell.textLabel.text = [[[[[GlobalVariable cityName] objectAtIndex:section]objectAtIndex:1]objectAtIndex:row]objectAtIndex:0];
    }
    
    
    
    
    
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
    if (blockAlert.tag == tagCategory) {
        return [[[[GlobalVariable activityCategory] objectAtIndex:section]objectAtIndex:1] count];
	}else if (blockAlert.tag == tagCity) {
        return [[[[GlobalVariable cityName] objectAtIndex:section]objectAtIndex:1] count];
    }
    return 0;
}

- (NSInteger)numberOfSectionsInBlockAlert:(BlockAlertView *)blockAlert tableView:(UITableView *)tableView
{
    if (blockAlert.tag == tagCategory) {
		return [[GlobalVariable activityCategory] count];
    }else if (blockAlert.tag == tagCity) {
        return [[GlobalVariable cityName] count];
    }
    return 0;
}
- (NSString *)blockAlert:(BlockAlertView *)blockAlert tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (blockAlert.tag == tagCategory) {
        return [[[GlobalVariable activityCategory] objectAtIndex:section]objectAtIndex:0];
	}else if (blockAlert.tag == tagCity) {
        return [[[GlobalVariable cityName] objectAtIndex:section]objectAtIndex:0];
    }
    return 0;
}

#pragma mark - ActivityListDataSetupDelegate

- (NSMutableArray*) dataSetup: (SQLConstraintMaker*) sqlHandler
{
    NSMutableArray* dataArray = [[NSMutableArray alloc] init];
    CHECK_NIL(dataArray);
    Updater* updateHandler = [Updater InstanceGet];
    CHECK_NIL(updateHandler);
    
    FMDatabase* db = [FMDatabase APPDatabaseGet:[updateHandler LastUpdateFilePathGet]];
    CHECK_NIL(db);
    
    /*
     *  SQL command
     *  select name, pic, time, latitude, longtitudefrom expo where edate >= "2012-12-10"
     */
    NSString* dateSQL = [SQLConstraintMaker dateSQLConstraint];
    CHECK_NIL(dateSQL);
    NSString* SQLCommand = [[NSString alloc] initWithFormat:@"select %@, %@, %@, %@, %@, %@, %@, %@, %@, %@ from %@ where %@", EXPO_TITLE, EXPO_REGION, EXPO_IMAGEURL,  EXPO_START_DATE, EXPO_END_DATE, EXPO_START_TIME, EXPO_END_TIME, EXPO_PLACE,  EXPO_LATITUDE, EXPO_LONGITUDE, EXPO_TABLE_NAME , dateSQL];
    NSString* appendSQLConstraint = nil;
    float distance = 0;
    
    if (nil != sqlHandler) {
        if (nil != (appendSQLConstraint = [sqlHandler citySQLConstraint])) {
            SQLCommand = [SQLCommand stringByAppendingFormat:@"%@", appendSQLConstraint];
        }
        if (nil != (appendSQLConstraint = [sqlHandler categorySQLConstraint])) {
            SQLCommand = [SQLCommand stringByAppendingFormat:@"%@", appendSQLConstraint];
        }
        if (nil != (appendSQLConstraint = [sqlHandler activitySQLConstraint])) {
            SQLCommand = [SQLCommand stringByAppendingFormat:@"%@", appendSQLConstraint];
        }
        if (nil != (appendSQLConstraint = [sqlHandler searchSQLConstraint])) {
            SQLCommand = [SQLCommand stringByAppendingFormat:@"%@", appendSQLConstraint];
        }
        distance = [sqlHandler distanceConstraint];
    }
    
    FMResultSet *dbResult = [db executeQuery:SQLCommand];
    
    while ([dbResult next]) {
        if (distance != 0) {
            CLLocation* location = [[CLLocation alloc] initWithLatitude:[[dbResult stringForColumn:EXPO_LATITUDE] floatValue] longitude:[[dbResult stringForColumn:EXPO_LONGITUDE] floatValue]];
            if ([location distanceFromLocation:[CLLocationManagerSingleton sharedManager].location] > distance *1000) {
                continue;
            }
        }
        
        ActivityRoughData *exhibitdata = [[ActivityRoughData alloc] init];
        CHECK_NIL(exhibitdata);
        exhibitdata._title = [dbResult stringForColumn:EXPO_TITLE];
        exhibitdata._region = [dbResult intForColumn:EXPO_REGION];
        exhibitdata._place = [dbResult stringForColumn:EXPO_PLACE];
        exhibitdata._imageURL = [NSURL URLWithString:[dbResult stringForColumn:EXPO_IMAGEURL]];
        exhibitdata._locate = [[CLLocation alloc] initWithLatitude:[[dbResult stringForColumn:EXPO_LATITUDE] floatValue] longitude:[[dbResult stringForColumn:EXPO_LONGITUDE] floatValue]];
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"yyyy-MM-dd HH:mm zzzz";
        exhibitdata._startDate = [formatter dateFromString:[[dbResult stringForColumn:EXPO_START_DATE] stringByAppendingFormat:@" %01d:%01d +0800",[dbResult intForColumn:EXPO_START_TIME]/60,[dbResult intForColumn:EXPO_START_TIME]%60]];
        exhibitdata._endDate = [formatter dateFromString:[[dbResult stringForColumn:EXPO_END_DATE] stringByAppendingFormat:@" %01d:%01d +0800",[dbResult intForColumn:EXPO_END_TIME]/60,[dbResult intForColumn:EXPO_END_TIME]%60]];
        
        exhibitdata._startTime = [dbResult intForColumn:EXPO_START_TIME];
        exhibitdata._endTime = [dbResult intForColumn:EXPO_END_TIME];
        
        CHECK_NIL(exhibitdata._title);
        CHECK_NIL(exhibitdata._imageURL);
        CHECK_NIL(exhibitdata._locate);
        [dataArray addObject:exhibitdata];
    }
    return dataArray;
}

@end


#pragma mark - for distance sorting use.

@interface CLLocation (distanceCompare) <CLLocationManagerDelegate>
- (NSComparisonResult)distanceCompare:(NSNumber*)other;
@end

@implementation CLLocation (distanceCompare)

- (NSComparisonResult)distanceCompare:(CLLocation*)other {
    NSAssert([other isKindOfClass:[CLLocation class]], @"Must be a clloaction");
    CLLocationDistance left = [[CLLocationManagerSingleton sharedManager].location distanceFromLocation:self];
    CLLocationDistance right = [[CLLocationManagerSingleton sharedManager].location distanceFromLocation:other];
    
    if (left < right) {
        return NSOrderedAscending;
    } else if (left == right){
        return NSOrderedSame;
    } else {
        return NSOrderedDescending;
    }
}

@end
