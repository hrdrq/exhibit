//
//  SettingAndInfoTableViewController.m
//  ExhibitAPP
//
//  Created by eric on 12/9/25.
//
//

#import "SettingAndInfoTableViewController.h"
#import "Exhibit.h"
#import "CustomSelectedBackgroundView.h"
#import "CustomUISwitch.h"

#define kTotalSections 2
#define kUpdatingSetting 0
#define kAbout 1

#define kCellIdentifierStyleDefault @"styleDefault"
#define kCellIdentifierStyleValue1 @"styleValue1"

#define kVersion @"0.1"

@interface SettingAndInfoTableViewController ()

@end

@implementation SettingAndInfoTableViewController

- (IBAction)autoUpdatingSwitchChanged:(id)sender
{
    CustomUISwitch* updateSwitch = (CustomUISwitch*)sender;
    if (updateSwitch.on) {
        NSLog(@"updateSwitch is on");
    }else{
        NSLog(@"updateSwitch is off");
    }
    //todo
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
    self.tableView.backgroundColor = [UIColor colorWithRed:0.121 green:0.121 blue:0.115 alpha:1.000];
    self.tableView.rowHeight = 40;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    //self.tableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Background.png"]];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
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
    return kTotalSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case kUpdatingSetting:
            return 2;
            break;
        case kAbout:
            return 2;
            break;
            
        default:
            return 0;
            break;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSString *sectionTitle = [self tableView:tableView titleForHeaderInSection:section];
    if (sectionTitle == nil) {
        return nil;
    }
    
    // Create label with section title
    UILabel *label = [[UILabel alloc] init];
    label.frame = CGRectMake(20, 6, 300, 30);
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor whiteColor];//THEME_COLOR_DARK;
    label.shadowColor = [UIColor grayColor];
    label.shadowOffset = CGSizeMake(0.0, 1.0);
    label.font = [UIFont boldSystemFontOfSize:16];
    label.text = sectionTitle;
    
    // Create header view and add label as a subview
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320,tableView.sectionHeaderHeight)];
    [view addSubview:label];
    
    return view;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	switch (section) {
        case kUpdatingSetting:
            return @"更新設定";
            break;
        case kAbout:
            return @"關於「Exhibit App」";
            break;
            
        default:
            return nil;
            break;
    }
}

#define kTagTopLine 1
#define kTagButtonLine 2
#define kTagTitleLabel 3
#define kTagDetailLabel 4
#define kTagAccessoryImage 5
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"settingCell"];
    if (cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"SettingAndInfoCell" owner:self options:nil] objectAtIndex:0];
    }
    [cell setBackgroundView:[[UIView alloc] init]];
    UIView *selectedView = [[UIView alloc]initWithFrame:CGRectMake(cell.frame.origin.x, cell.frame.origin.y+3, cell.frame.size.width, cell.frame.size.height-5)];
    selectedView.backgroundColor = THEME_COLOR_3;
    cell.selectedBackgroundView = selectedView;
    cell.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"selectedGrouped.png"]];
    
    UIImageView *topLine = (UIImageView *)[cell viewWithTag:kTagTopLine];
    UILabel *titleLable = (UILabel *)[cell viewWithTag:kTagTitleLabel];
    UILabel *detatilLable = (UILabel *)[cell viewWithTag:kTagDetailLabel];
    
    if (indexPath.row != 0) {
        topLine.hidden = YES;
    }
    
    switch (indexPath.section) {
        case kUpdatingSetting:
        {
            switch (indexPath.row) {
                case 0:
                {
                    titleLable.text = @"自動更新";
                    
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    
                    CustomUISwitch *autoUpdatingSwitch = [[CustomUISwitch alloc] initWithFrame:CGRectMake(210, tableView.rowHeight/2 - 27/2, 79, 27)];
                    [autoUpdatingSwitch addTarget:self action:@selector(autoUpdatingSwitchChanged:) forControlEvents:UIControlEventValueChanged];
                    //autoUpdatingSwitch.onTintColor = [UIColor darkGrayColor];//THEME_COLOR_3;
                    [cell addSubview:autoUpdatingSwitch];
                }
                    break;
                case 1:
                {
                    titleLable.text = @"立即更新";
                    //cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    //cell.selectionStyle = UITableViewCellSelectionStyleGray;
                }
                    break;
            }
        }
            break;
        case kAbout:
        {
            switch (indexPath.row) {
                case 0:
                {
                    titleLable.text = @"版本";
                    detatilLable.text = kVersion;
                    //cell.detailTextLabel.textColor = THEME_COLOR_DARK;
                    cell.userInteractionEnabled = NO;
                }
                    break;
                case 1:
                {
                    titleLable.text = @"關於我們";
                    //cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    //cell.selectionStyle = UITableViewCellSelectionStyleGray;
                }
                    break;
            }
        }
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
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

@end
