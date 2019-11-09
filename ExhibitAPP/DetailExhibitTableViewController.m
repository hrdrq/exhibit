//
//  DetailExhibitTableViewController.m
//  ExhibitAPP
//
//  Created by eric on 12/9/26.
//
//

#import "DetailExhibitTableViewController.h"
#import "GlobalVariable.h"
#import "FMDatabase.h"
#import "SDImageCache.h"
#import "DebugUtil.h"
#import "Updater.h"
#import "WebViewController.h"
#import "RegexKitLite.h"

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

#define kDetailCellLableHeadingTag 11
#define kDetailCellLableTextTag 12

#define kFontNumbersPerLine 16
#define kFontHeight 23

#define WEEK_TOTAL_DAY 7

#define ACTION_DIAL @"撥打"
#define ACTION_CANCEL @"取消"

static const NSString const *gWeekDay[] = {
  @"一 ", @"二 ", @"三 ", @"四 ", @"五 ",
  @"六 ", @"日 "
};

@interface DetailExhibitTableViewController ()

@end

@implementation DetailExhibitTableViewController
@synthesize titleString;
@synthesize timeString;
@synthesize dateString;
@synthesize weekString;
@synthesize placeString;
@synthesize priceString;
@synthesize pageString;
@synthesize telString;
@synthesize telNumberString;
@synthesize telExtString;
@synthesize infoString;
@synthesize addressString;
@synthesize _imageView;

- (BOOL) DetailDataSetup: (NSString*) title regionID:(int) region
{
    if (nil == title || 0 > region) {
        DLog(@"wrong parameter");
        assert(0);
    }
    Updater* updateHandler = [Updater InstanceGet];
    CHECK_NIL(updateHandler);
    FMDatabase* db = [FMDatabase APPDatabaseGet:[updateHandler LastUpdateFilePathGet]];
    CHECK_NIL(db);
    NSString* dateSQL = [FMDatabase APPDateSQLConstraint];
    CHECK_NIL(dateSQL);
    //select * from expo where region = 28 and name = xxxxx and edate >= "2012-09-16"
    NSString* NSdetail = [[NSString alloc] initWithFormat:@"select * from %@ where %@ = %i and %@ = \"%@\" and %@",EXPO_TABLE_NAME, EXPO_REGION, region, EXPO_TITLE, title, dateSQL];
    FMResultSet *dbResult = [db executeQuery:NSdetail];
    CHECK_NIL(dbResult);
    NSString *NSurl = nil;
    //TODO: Maybe cannot find detail information when the day change.
    while ([dbResult next]) {
        self.addressString = [dbResult stringForColumn:EXPO_ADDRESS];
        self.titleString = [dbResult stringForColumn:EXPO_TITLE];
        self.dateString = [NSString stringWithFormat:@"%@ ~ %@",[dbResult stringForColumn:EXPO_START_DATE],[dbResult stringForColumn:EXPO_END_DATE]];
        self.timeString = [NSString stringWithFormat:@"%02d:%02d ~ %02d:%02d",[dbResult intForColumn:EXPO_START_TIME]/60,[dbResult intForColumn:EXPO_START_TIME]%60,[dbResult intForColumn:EXPO_END_TIME]/60,[dbResult intForColumn:EXPO_END_TIME]%60] ;
        int week = [dbResult intForColumn:EXPO_WEEK];
        if (week == 0) {
            self.weekString = [NSString stringWithFormat:@"每天"];
        } else if (week != 0xff) {
            self.weekString = [[NSString alloc]init];
            for (int i = 0; i < WEEK_TOTAL_DAY; i++) {
                if (week & 1 << i) {
                    self.weekString = [self.weekString stringByAppendingFormat:@"%@", gWeekDay[i]];
                }
            }
        } else {
            self.weekString = [NSString stringWithFormat:@"查無資料"];
        }
        self.priceString = [dbResult stringForColumn:EXPO_PRICE];
        self.placeString = [dbResult stringForColumn:EXPO_PLACE];
        self.pageString = [dbResult stringForColumn:EXPO_WEBURL];
        self.telString = [dbResult stringForColumn:EXPO_TELEPHONE];
        
        self.telNumberString = [self.telString stringByMatching:@"^[0-9\\-\\(\\)]+[0-9]" capture:0];
        self.telExtString = [self.telString stringByMatching:@"分機:([0-9]+)" capture:1L];

        self.infoString = [dbResult stringForColumn:EXPO_INFO];
        
        NSurl = [dbResult stringForColumn:EXPO_IMAGEURL];
    }
    if (nil == self.pageString) {
        self.pageString = @"沒有參考網頁";
    }
    if (nil == self.addressString ||
        nil == self.titleString ||
        nil == self.timeString  ||
        nil == self.priceString ||
        nil == self.placeString ||
        nil == self.pageString  ||
        nil == self.dateString  ||
        nil == self.weekString  ||
        nil == self.infoString  ||
        nil == self.telString   ||
        nil == NSurl) {
        DLog(@"%@, %@, %@, %@, %@, %@, %@, %@, %@, %@, %@", self.addressString, self.titleString , self.timeString, self.priceString, self.placeString, self.pageString, self.dateString, self.infoString , self.weekString, self.telString, NSurl)
        DLog(@"wrong data in the label");
        assert(0);
    }
    if ([self setImage:NSurl]) {
        DLog(@"Cannot set the image url");
        assert(0);
    }
    return FALSE;
}

- (BOOL) setImage:(NSString *)NSImageURL
{
    _imageView = [[UIImageView alloc] init];
    if (nil == NSImageURL || nil == _imageView) {
        DLog(@"Error: wrong parameter setImageinProtocol");
        return TRUE;
    }
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    if (nil == manager) {
        DLog(@"Cannot get the manager");
        return TRUE;
    }
    UIImage *cachedImage = [[SDImageCache sharedImageCache] imageFromKey:NSImageURL];
    if (nil == cachedImage) {
        [manager downloadWithURL:[NSURL URLWithString:NSImageURL] delegate:self];
        _imageView.image = [UIImage imageNamed:WAIT_PICTURE_PATH];
    } else {
        _imageView.image = cachedImage;
    }
    return FALSE;
}

- (void)webImageManager:(SDWebImageManager *)imageManager didFinishWithImage:(UIImage *)image
{
    CHECK_NIL(_imageView);
    CHECK_NIL(image);
    _imageView.image = image;
    [_imageView setNeedsLayout];
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.titleString = nil;
    self.timeString = nil;
    self.dateString = nil;
    self.weekString = nil;
    self.placeString = nil;
    self.priceString = nil;
    self.pageString = nil;
    self.telString = nil;
    self.infoString = nil;
    self.addressString = nil;
    _imageView = nil;
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case kTitleCell:
            return 1;
            break;
        case kDetailCell:
            return 7;
            break;
        case kInfoCell:
            return 1;
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
        case kInfoCell:
            return 10+ceil((float)[self.infoString length]/kFontNumbersPerLine)*kFontHeight;
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
            [cell setBackgroundColor:[UIColor clearColor]];
            ((UIImageView*)[cell viewWithTag:kTitleCellImageTag]).image = _imageView.image;
            ((UILabel*)[cell viewWithTag:kTitleCellLableTitleTag]).text = self.titleString;
            ((UILabel*)[cell viewWithTag:kTitleCellLablePlaceTag]).text = self.placeString;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
            break;
        case kDetailCell:
        {
            cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifierDetail];
            if (cell == nil) {
                cell = [[[NSBundle mainBundle] loadNibNamed:@"DetailCell" owner:self options:nil] objectAtIndex:0];
            }
            switch (indexPath.row) {
                case 0:
                {
                    ((UILabel*)[cell viewWithTag:kDetailCellLableHeadingTag]).text = @"展場地址";
                    ((UILabel*)[cell viewWithTag:kDetailCellLableTextTag]).text = self.addressString;
                    cell.selectionStyle = UITableViewCellSelectionStyleGray;
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                }
                    break;
                case 1:
                {
                    ((UILabel*)[cell viewWithTag:kDetailCellLableHeadingTag]).text = @"展出日期";
                    ((UILabel*)[cell viewWithTag:kDetailCellLableTextTag]).text = self.dateString;
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                }
                    break;
                case 2:
                {
                    ((UILabel*)[cell viewWithTag:kDetailCellLableHeadingTag]).text = @"展出星期";
                    ((UILabel*)[cell viewWithTag:kDetailCellLableTextTag]).text = self.weekString;
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                }
                    break;
                case 3:
                {
                    ((UILabel*)[cell viewWithTag:kDetailCellLableHeadingTag]).text = @"展出時間";
                    ((UILabel*)[cell viewWithTag:kDetailCellLableTextTag]).text = self.timeString;
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                }
                    break;
                case 4:
                {
                    ((UILabel*)[cell viewWithTag:kDetailCellLableHeadingTag]).text = @"展覽票價";
                    ((UILabel*)[cell viewWithTag:kDetailCellLableTextTag]).text = self.priceString;
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                }
                    break;
                case 5:
                {
                    ((UILabel*)[cell viewWithTag:kDetailCellLableHeadingTag]).text = @"官方網頁";
                    ((UILabel*)[cell viewWithTag:kDetailCellLableTextTag]).text = self.pageString;
                    cell.selectionStyle = UITableViewCellSelectionStyleGray;
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                }
                    break;
                case 6:
                {
                    ((UILabel*)[cell viewWithTag:kDetailCellLableHeadingTag]).text = @"連絡電話";
                    ((UILabel*)[cell viewWithTag:kDetailCellLableTextTag]).text = self.telString;
                    if (self.telNumberString) {
                        cell.selectionStyle = UITableViewCellSelectionStyleGray;
                        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    }else{
                        cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    }
                    
                }
                    break;
                    
                default:
                    break;
            }
        }
            break;
        case kInfoCell:
        {
            cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifierInfo];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellIdentifierInfo];
            }
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.textLabel.numberOfLines = 0;
            cell.textLabel.text = self.infoString;
        }
            
        default:
            break;
    }
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == kDetailCell && indexPath.row == 5) {
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
        [detvc setUrl:[NSURL URLWithString:self.pageString]];
    }
}

@end
