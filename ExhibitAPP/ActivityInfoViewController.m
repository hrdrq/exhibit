//
//  DetailExhibitTableViewController.m
//  ExhibitAPP
//
//  Created by eric on 12/9/26.
//
//

#import "ActivityInfoViewController.h"
#import "Exhibit.h"
#import "UIImageView+WebCache.h"
#import "WebViewController.h"
#import "RegexKitLite.h"
#import "SQLDefine.h"
#import "SQLConstraintMaker.h"

#import "NavigationMapViewController.h"
#import "CustomSelectedBackgroundView.h"

#import "MyFaviroteHandler/MyFavoriteHandler.h"

#import "QuartzCore/CALayer.h"

#define kTitleCell 0
#define kDetailCell 1
#define kInfoCell 2

#define kTitleCellHeight 80
#define kDetailCellHeight 80
//#define kInfoCellHeight 200

#define kCellIdentifierTitle @"titleCell"
#define kCellIdentifierDetail @"detailCell"
#define kCellIdentifierInfo @"infoCell"

#define kTitleCellImageTag 1
#define kTitleCellLableTitleTag 2
#define kTitleCellLablePlaceTag 3
#define kTitleCellLableDistanceTag 4

#define kDetailCellLableHeadingTag 11
#define kDetailCellLableTextTag 12
#define kDetailCellTopLine 13
#define kDetailCellButtonLine 14
#define kDetailCellAccessoryImage 15

#define kFontNumbersPerLine 16
#define kFontHeight 23

#define WEEK_TOTAL_DAY 7

#define ACTION_DIAL @"撥打"
#define ACTION_CANCEL @"取消"

@interface ActivityInfoViewController ()

@end

@implementation ActivityInfoViewController
@synthesize roughData;
@synthesize updateTableDelegate;

@synthesize week;
@synthesize price;
@synthesize page;
@synthesize tel;
@synthesize telNumberString;
@synthesize telExtString;
@synthesize info;
@synthesize address;

-(void) viewDidLoad
{
    //self.tableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Background.png"]];
    self.tableView.backgroundColor = [UIColor colorWithRed:0.121 green:0.121 blue:0.115 alpha:1.000];

    //Setup the name of button, add to my favorite, which is determined by whether this item is in my favorite array or not.
    UIBarButtonItem* buttonItem = [self InitialSetButton];
    CHECK_NIL(buttonItem);
    self.navigationItem.rightBarButtonItem = buttonItem;
}

- (BOOL) RoughDataSetup: (ActivityRoughData*)data title:(NSString*) strTitle
{
    CHECK_NIL(data);
    CHECK_NIL(strTitle);
    CHECK_STRING_NOT_EMPTY(strTitle);
    
    Updater* updateHandler = [Updater InstanceGet];
    CHECK_NIL(updateHandler);
    FMDatabase* db = [FMDatabase APPDatabaseGet:[updateHandler LastUpdateFilePathGet]];
    CHECK_NIL(db);
    NSString* dateSQL = [SQLConstraintMaker dateSQLConstraint];
    CHECK_NIL(dateSQL);
    //select * from expo where region = 28 and name = xxxxx and edate >= "2012-09-16"
    NSString* NSdetail = nil;
    if (self.roughData._region) {
        NSdetail = [[NSString alloc] initWithFormat:@"select %@, %@, %@, %@, %@, %@ from %@ where %@ = %i and %@ = \"%@\" and %@",EXPO_WEEK,EXPO_PRICE, EXPO_WEBURL,EXPO_TELEPHONE,EXPO_INFO,EXPO_ADDRESS,EXPO_TABLE_NAME, EXPO_REGION, self.roughData._region, EXPO_TITLE, self.roughData._title, dateSQL];
    } else {
        NSdetail = [[NSString alloc] initWithFormat:@"select %@, %@, %@, %@, %@, %@ from %@ where %@ = \"%@\" and %@",EXPO_WEEK,EXPO_PRICE,EXPO_WEBURL,EXPO_TELEPHONE,EXPO_INFO,EXPO_ADDRESS,EXPO_TABLE_NAME, EXPO_TITLE, self.roughData._title, dateSQL];
    }
    FMResultSet *dbResult = [db executeQuery:NSdetail];
    CHECK_NIL(dbResult);
    
    //TODO: Maybe cannot find detail information when the day change.
    while ([dbResult next]) {
        self.week = [dbResult intForColumn:EXPO_WEEK];
        self.price = [dbResult stringForColumn:EXPO_PRICE];
        self.page = [dbResult stringForColumn:EXPO_WEBURL];
        self.tel = [dbResult stringForColumn:EXPO_TELEPHONE];
        self.telNumberString = [self.tel stringByMatching:@"^[0-9\\-\\(\\)]+[0-9]" capture:0];
        self.telExtString = [self.tel stringByMatching:@"分機:([0-9]+)" capture:1L];
        self.info = [dbResult stringForColumn:EXPO_INFO];
        self.address = [dbResult stringForColumn:EXPO_ADDRESS];
    }
    
    return FALSE;
}

- (BOOL) DetailDataSetup: (ActivityRoughData*) data
{
    self.roughData = data;
    self.title = @"活動資訊";
    
    Updater* updateHandler = [Updater InstanceGet];
    CHECK_NIL(updateHandler);
    FMDatabase* db = [FMDatabase APPDatabaseGet:[updateHandler LastUpdateFilePathGet]];
    CHECK_NIL(db);
    NSString* dateSQL = [SQLConstraintMaker dateSQLConstraint];
    CHECK_NIL(dateSQL);
    //select * from expo where region = 28 and name = xxxxx and edate >= "2012-09-16"
    NSString* NSdetail = nil;
    if (self.roughData._region) {
        NSdetail = [[NSString alloc] initWithFormat:@"select %@, %@, %@, %@, %@, %@ from %@ where %@ = %i and %@ = \"%@\" and %@",EXPO_WEEK,EXPO_PRICE,EXPO_WEBURL,EXPO_TELEPHONE,EXPO_INFO,EXPO_ADDRESS,EXPO_TABLE_NAME, EXPO_REGION, self.roughData._region, EXPO_TITLE, self.roughData._title, dateSQL];
    } else {
        NSdetail = [[NSString alloc] initWithFormat:@"select %@, %@, %@, %@, %@, %@ from %@ where %@ = \"%@\" and %@",EXPO_WEEK,EXPO_PRICE,EXPO_WEBURL,EXPO_TELEPHONE,EXPO_INFO,EXPO_ADDRESS,EXPO_TABLE_NAME, EXPO_TITLE, self.roughData._title, dateSQL];
    }
    FMResultSet *dbResult = [db executeQuery:NSdetail];
    CHECK_NIL(dbResult);
    
    //TODO: Maybe cannot find detail information when the day change.
    while ([dbResult next]) {
        self.week = [dbResult intForColumn:EXPO_WEEK];
        self.price = [dbResult stringForColumn:EXPO_PRICE];
        self.page = [dbResult stringForColumn:EXPO_WEBURL];
        self.tel = [dbResult stringForColumn:EXPO_TELEPHONE];
        self.telNumberString = [self.tel stringByMatching:@"^[0-9\\-\\(\\)]+[0-9]" capture:0];
        self.telExtString = [self.tel stringByMatching:@"分機:([0-9]+)" capture:1L];
        self.info = [dbResult stringForColumn:EXPO_INFO];
        self.address = [dbResult stringForColumn:EXPO_ADDRESS];
    }
    
    return FALSE;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case kTitleCell:
            return 1;
            break;
        case kDetailCell:
            return 8;
            break;
            
        default:
            return 0;
            break;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case kTitleCell:
            return kTitleCellHeight;
            break;
        case kDetailCell:
            if (indexPath.row==7) {
                return [self.info sizeWithFont:[UIFont systemFontOfSize:15]
                             constrainedToSize:CGSizeMake(200, 1000)
                                 lineBreakMode:UILineBreakModeWordWrap].height+20;
            }
            else{
                return tableView.rowHeight;
            }
            break;
            
        default:
            return tableView.rowHeight;
            break;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    
    switch (indexPath.section) {
        case kTitleCell:
        {
            cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifierTitle];
            if (cell == nil) {
                cell = [[[NSBundle mainBundle] loadNibNamed:@"TitleCell" owner:self options:nil] objectAtIndex:0];
            }
            [cell setBackgroundView:[[UIView alloc] init]];
            //[cell setBackgroundColor:[UIColor clearColor]];
            UIImageView *imageView = (UIImageView*)[cell viewWithTag:kTitleCellImageTag];
            [imageView setImageWithURL:self.roughData._imageURL placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
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
            
            ((UILabel*)[cell viewWithTag:kTitleCellLableTitleTag]).text = self.roughData._title;
            ((UILabel*)[cell viewWithTag:kTitleCellLablePlaceTag]).text = self.roughData._place;
            /*
            CLLocationDistance distance = [[CLLocationManagerSingleton sharedManager].location distanceFromLocation:self.roughData._locate];
            if (distance < 1000) {
                ((UILabel*)[cell viewWithTag:kTitleCellLableDistanceTag]).text = [NSString stringWithFormat:@"%d M",(int)distance];
            }
            else{
                ((UILabel*)[cell viewWithTag:kTitleCellLableDistanceTag]).text = [NSString stringWithFormat:@"%.1f KM",distance/1000];
            }*/
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
            break;
        case kDetailCell:
        {
            cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifierDetail];
            if (cell == nil) {
                cell = [[[NSBundle mainBundle] loadNibNamed:@"DetailCell" owner:self options:nil] objectAtIndex:0];
            }
            [cell setBackgroundView:[[UIView alloc] init]];
            if (indexPath.row!=0) {
                ((UIImageView*)[cell viewWithTag:kDetailCellTopLine]).hidden = YES;
            }
            switch (indexPath.row) {
                case 0:
                {
                    ((UILabel*)[cell viewWithTag:kDetailCellLableHeadingTag]).text = @"展場地址";
                    ((UILabel*)[cell viewWithTag:kDetailCellLableTextTag]).text = self.address;
                    //cell.selectionStyle = UITableViewCellSelectionStyleGray;
                    UIImageView *selectedView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"selectedGrouped.png"]];
                    cell.selectedBackgroundView = selectedView;
                    //cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    ((UIImageView*)[cell viewWithTag:kDetailCellAccessoryImage]).hidden = NO;
                }
                    break;
                case 1:
                {
                    ((UILabel*)[cell viewWithTag:kDetailCellLableHeadingTag]).text = @"展出日期";
                    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                    formatter.dateFormat = @"yyyy/MM/dd";
                    ((UILabel*)[cell viewWithTag:kDetailCellLableTextTag]).text = [NSString stringWithFormat:@"%@~%@",[formatter stringFromDate:self.roughData._startDate],[formatter stringFromDate:self.roughData._endDate]];
                    cell.userInteractionEnabled = NO;
                }
                    break;
                case 2:
                {
                    ((UILabel*)[cell viewWithTag:kDetailCellLableHeadingTag]).text = @"展出星期";
                    
                    NSString *weekString;
                    if (self.week == 0) {
                        weekString = [NSString stringWithFormat:@"每天"];
                    } else if (self.week != 0xff) {
                        weekString = [[NSString alloc]init];
                        for (NSString *day in [GlobalVariable weekDay]) {
                            if (week & 1 << [[GlobalVariable weekDay]indexOfObject:day]) {
                                weekString = [weekString stringByAppendingString:day];
                            }
                        }
                    } else {
                        weekString = [NSString stringWithFormat:@"查無資料"];
                    }
                    ((UILabel*)[cell viewWithTag:kDetailCellLableTextTag]).text = weekString;
                    cell.userInteractionEnabled = NO;
                }
                    break;
                case 3:
                {
                    ((UILabel*)[cell viewWithTag:kDetailCellLableHeadingTag]).text = @"展出時間";
                    ((UILabel*)[cell viewWithTag:kDetailCellLableTextTag]).text = [NSString stringWithFormat:@"%02d:%02d ~ %02d:%02d",self.roughData._startTime/60,self.roughData._startTime%60,self.roughData._endTime/60,self.roughData._endTime%60];
                    cell.userInteractionEnabled = NO;
                }
                    break;
                case 4:
                {
                    ((UILabel*)[cell viewWithTag:kDetailCellLableHeadingTag]).text = @"展覽票價";
                    ((UILabel*)[cell viewWithTag:kDetailCellLableTextTag]).text = self.price;
                    cell.userInteractionEnabled = NO;
                }
                    break;
                case 5:
                {
                    ((UILabel*)[cell viewWithTag:kDetailCellLableHeadingTag]).text = @"官方網頁";
                    ((UILabel*)[cell viewWithTag:kDetailCellLableTextTag]).text = self.page;
                    //cell.selectionStyle = UITableViewCellSelectionStyleGray;
                    UIImageView *selectedView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"selectedGrouped.png"]];
                    cell.selectedBackgroundView = selectedView;
                    //cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    ((UIImageView*)[cell viewWithTag:kDetailCellAccessoryImage]).hidden = NO;
                }
                    break;
                case 6:
                {
                    ((UILabel*)[cell viewWithTag:kDetailCellLableHeadingTag]).text = @"連絡電話";
                    ((UILabel*)[cell viewWithTag:kDetailCellLableTextTag]).text = self.tel;
                    if (self.telNumberString) {
                        //cell.selectionStyle = UITableViewCellSelectionStyleGray;
                        UIImageView *selectedView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"selectedGrouped.png"]];
                        cell.selectedBackgroundView = selectedView;
                        //cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                        ((UIImageView*)[cell viewWithTag:kDetailCellAccessoryImage]).hidden = NO;
                    }else{
                        cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    }
                    
                }
                    break;
                case 7:
                {
                    ((UILabel*)[cell viewWithTag:kDetailCellLableHeadingTag]).text = @"展覽簡介";
                    UILabel * label = (UILabel*)[cell viewWithTag:kDetailCellLableTextTag];
                    CGSize size = [self.info sizeWithFont:[UIFont systemFontOfSize:15]
                                        constrainedToSize:CGSizeMake(200, 1000)
                                            lineBreakMode:UILineBreakModeWordWrap];
                    label.frame = CGRectMake(label.frame.origin.x, 8, size.width, size.height);
                    label.text = self.info;
                    label.numberOfLines = 0;
                    UIImageView *buttonLine = (UIImageView*)[cell viewWithTag:kDetailCellButtonLine];
                    buttonLine.frame = CGRectMake(buttonLine.frame.origin.x, size.height+20-1, buttonLine.frame.size.width, buttonLine.frame.size.height);
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                }
                    break;
                    
                default:
                    break;
            }
        }
            break;
            
        default:
            break;
    }
    //cell.backgroundColor = THEME_COLOR_WHITE;
    
    ////////selectedBackgroundView///////////
    /*
    CustomSelectedBackgroundViewPosition pos;
    if ([self tableView:tableView numberOfRowsInSection:indexPath.section]==1) {
        pos = CustomSelectedBackgroundViewPositionSingle;
    }else{
        if (indexPath.row==0) {
            pos = CustomSelectedBackgroundViewPositionTop;
        }else if (indexPath.row == [self tableView:tableView numberOfRowsInSection:indexPath.section]-1){
            pos = CustomSelectedBackgroundViewPositionBottom;
        }else {
            pos = CustomSelectedBackgroundViewPositionMiddle;
        }
    }
    CustomSelectedBackgroundView *sbView = [[CustomSelectedBackgroundView alloc] initWithFrame:cell.frame];
	sbView.fillColor = THEME_COLOR_4;
	sbView.borderColor = [UIColor clearColor];
	sbView.position = pos;
    
    cell.selectedBackgroundView = sbView;
     */
    ////////selectedBackgroundView///////////
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == kDetailCell && indexPath.row == 0) {
        [self performSegueWithIdentifier:@"PushNavigation" sender:nil];

    }else if (indexPath.section == kDetailCell && indexPath.row == 5) {
        [self performSegueWithIdentifier:@"toWebViewController" sender:indexPath];
    }else if (indexPath.section == kDetailCell && indexPath.row == 6){
        if (!self.telNumberString) {
            return;
        }
        NSString* actionSheetTitle = (self.telExtString)?[NSString stringWithFormat:@"撥打電話：%@分機%@",self.telNumberString,self.telExtString]:[NSString stringWithFormat:@"撥打電話：%@",self.telNumberString];
        UIActionSheet *uias = [[UIActionSheet alloc] initWithTitle:actionSheetTitle
                                                          delegate:self
                                                 cancelButtonTitle:ACTION_CANCEL
                                            destructiveButtonTitle:ACTION_DIAL
                                                 otherButtonTitles: nil];
        
        [uias showInView:self.view];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

#pragma mark - UIActionSheet Delegate

- (void)actionSheet:(UIActionSheet *)uias clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == [uias cancelButtonIndex]) return;
    
    if([[uias buttonTitleAtIndex:buttonIndex] compare:ACTION_DIAL] == NSOrderedSame)
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:(self.telExtString)?[NSString stringWithFormat:@"tel://%@,%@",self.telNumberString,self.telExtString]:[NSString stringWithFormat:@"tel://%@",self.telNumberString]]];
    }
    
}

#pragma mark - Segue
- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    if ([[segue identifier] isEqualToString:@"toWebViewController"]) {
        WebViewController *detvc = segue.destinationViewController;
        [detvc setUrl:[NSURL URLWithString:self.page]];
    }else if([[segue identifier] isEqualToString:@"PushNavigation"]){
        NavigationMapViewController *nvc = segue.destinationViewController;

        
        nvc.startLocation = [CLLocationManagerSingleton sharedManager].location;
        nvc.endLocation = self.roughData._locate;
        
        nvc.endPoint = self.address;
        
        CLGeocoder *geocoder = [[CLGeocoder alloc]init];
        [geocoder reverseGeocodeLocation:[CLLocationManagerSingleton sharedManager].location completionHandler:^(NSArray *placemarks, NSError *error){
            if (!error && [placemarks count]) {
                CLPlacemark *placeMark = [placemarks objectAtIndex:0];
                NSArray *addressArray = [placeMark.addressDictionary objectForKey:@"FormattedAddressLines"];
                nvc.startPoint = [addressArray objectAtIndex:0];
            }
        }];
      
        nvc.travelMode	= UICGTravelModeDriving;
    }
}


- (UIBarButtonItem*) InitialSetButton
{
    CHECK_NIL(roughData);
    MyFavoriteHandler* myFavoriter = [MyFavoriteHandler InstanceGet];
    CHECK_NIL(myFavoriter);
    UIBarButtonItem* buttonItem = nil;
    if (0 == [myFavoriter ItemIsExist:roughData]) {
        buttonItem = [[UIBarButtonItem alloc] initWithTitle:MYFAVORITE_STR_ADD style:UIBarButtonItemStylePlain target:self action:@selector(MyFavoriteAdd:)];
    } else {
        buttonItem = [[UIBarButtonItem alloc] initWithTitle:MYFAVORITE_STR_CANCEL style:UIBarButtonItemStylePlain target:self action:@selector(MyFavoriteRemove:)];
    }
    CHECK_NIL(buttonItem);
    return buttonItem;
}

#pragma mark - my favorite protocal
- (void) MyFavoriteAdd:(ActivityRoughData *) favoriteData
{
    favoriteData = roughData;
    CHECK_NIL(favoriteData);
    MyFavoriteHandler* favoriteHandler = [MyFavoriteHandler InstanceGet];
    CHECK_NIL(favoriteHandler);
    if ([favoriteHandler ItemAdd:roughData]) {
        CHECK_NOT_ENTER_HERE;
    }
    [self.navigationItem.rightBarButtonItem setTitle:MYFAVORITE_STR_CANCEL];
    [self.navigationItem.rightBarButtonItem setAction:@selector(MyFavoriteRemove:)];
    return;
}

- (void) MyFavoriteRemove:(ActivityRoughData *) favoriteData
{
    favoriteData = roughData;
    CHECK_NIL(favoriteData);
    MyFavoriteHandler* favoriteHandler = [MyFavoriteHandler InstanceGet];
    CHECK_NIL(favoriteHandler);
    if ([favoriteHandler ItemRemove:roughData]) {
        CHECK_NOT_ENTER_HERE;
    }
    [self.navigationItem.rightBarButtonItem setTitle:MYFAVORITE_STR_ADD];
    [self.navigationItem.rightBarButtonItem setAction:@selector(MyFavoriteAdd:)];
    if (updateTableDelegate) {
        [updateTableDelegate UpdateActivityListTableFromOtherVC];
    }
    return;
}

@end
