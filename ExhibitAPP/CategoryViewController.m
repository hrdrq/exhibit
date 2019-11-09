//
//  CategoryViewController.m
//  ExhibitAPP
//
//  Created by eric on 12/10/7.
//
//

#import "CategoryViewController.h"
#import "../ActivityListViewController.h"
#import "SQLDefine.h"
#import "ImageNumberBadgeView.h"

@interface CategoryViewController ()

@end

@implementation CategoryViewController

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
    self.tableView.separatorColor = [UIColor colorWithWhite:0.200 alpha:1.000];

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
    return [[GlobalVariable activityCategory] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    return [[[GlobalVariable activityCategory]objectAtIndex:section]objectAtIndex:0];
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 30)];
    
    [headerView setBackgroundColor:[UIColor colorWithWhite:0.098 alpha:0.800]];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 3, tableView.bounds.size.width - 10, 18)];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor whiteColor];
    //label.text = [[[GlobalVariable cityName]objectAtIndex:section]objectAtIndex:0];
    label.text = [self tableView:tableView titleForHeaderInSection:section];
    [headerView addSubview:label];
    
    return headerView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[[[GlobalVariable activityCategory]objectAtIndex:section]objectAtIndex:1]count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"categoryCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"categoryCell"];
    }
    NSUInteger row = [indexPath row];
    NSUInteger section = [indexPath section];
    
    cell.textLabel.text = [[[[[GlobalVariable activityCategory]objectAtIndex:section]objectAtIndex:1]objectAtIndex:row]objectAtIndex:0];
    cell.textLabel.textColor = [UIColor whiteColor];
    
    UIImageView *selectedView = [[UIImageView alloc]initWithImage:[[UIImage imageNamed:@"selected.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(19, 149, 19, 149)]];
    cell.selectedBackgroundView = selectedView;

    
    Updater* updateHandler = [Updater InstanceGet];
    CHECK_NIL(updateHandler);
    FMDatabase* db = [FMDatabase APPDatabaseGet:[updateHandler LastUpdateFilePathGet]];
    CHECK_NIL(db);
    //select distinct region from expo
    NSString* sql = [[NSString alloc] initWithFormat:@"select count(%@) from %@ where %@ like \"%%%@%%\";", EXPO_TITLE, EXPO_TABLE_NAME, EXPO_CATEGORY, [[[[[GlobalVariable activityCategory]objectAtIndex:section]objectAtIndex:1]objectAtIndex:row]objectAtIndex:0]];
    FMResultSet *dbResult = [db executeQuery:sql];
    int exhibitNumber;
    while ([dbResult next]) {
        exhibitNumber = [dbResult intForColumnIndex:0];
    }
    
    [db close];
    
    if (exhibitNumber) {
        //cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"accessory.png"]];
        cell.userInteractionEnabled = YES;
    }else{
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.accessoryView = nil;
        cell.userInteractionEnabled = NO;
    }
    
    ImageNumberBadgeView *badge;
    for (UIView *view in cell.subviews) {
        if ([view isMemberOfClass:[ImageNumberBadgeView class]]) {
            badge = (ImageNumberBadgeView *)view;
        }
    }
    if(!badge){
        badge =[[ImageNumberBadgeView alloc] initWithFrame:CGRectMake(234, [tableView rowHeight]/2 - 28/2, 55, 28)];
    }
    badge.value = exhibitNumber;
    //badge.shadow = NO;
    //badge.shine = NO;
    //badge.strokeColor = [UIColor clearColor];
    //badge.fillColor = [MKNumberBadgeView defaultBadgeColor];//THEME_COLOR_4;
    badge.hideWhenZero = YES;
    [cell addSubview:badge];
    
    return cell;
}

#pragma mark - Table view delegate

- (NSIndexPath*)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"toRoughExhibitTableViewController" sender:indexPath];
    
    return indexPath;
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"toRoughExhibitTableViewController"]) {
        NSIndexPath *indexPath = sender;
        NSUInteger row = [indexPath row];
        NSUInteger section = [indexPath section];
        
        ActivityListViewController*retvc = segue.destinationViewController;
        NSString* categoryString = [[[[[GlobalVariable activityCategory]objectAtIndex:section]objectAtIndex:1]objectAtIndex:row]objectAtIndex:0];
        CHECK_NIL(categoryString);
        retvc.title = categoryString;
        
        retvc._SQLConstraintHandler = [[SQLConstraintMaker alloc] init];
        [retvc._SQLConstraintHandler categoryMutualSetAdd:categoryString];

        retvc._dataSetupDelegate = retvc;
        CHECK_NIL(retvc._dataSetupDelegate);
        [retvc dataSetupSelf];
    }
}

@end
