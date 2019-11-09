//
//  PlaceTableViewController.m
//  ExhibitAPP
//
//  Created by sfffaaa sfffaaa on 12/8/26.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "PlaceTableViewController.h"
#import "FMDatabase.h"
#import "GlobalVariable.h"
#import "Updater.h"
#import "DebugUtil.h"
#import "MKNumberBadgeView.h"
#import "ActivityListViewController.h"

@interface PlaceTableViewController ()

@property (strong, nonatomic) NSMutableArray *_eachPlaceIndex;

@end

@implementation PlaceTableViewController
@synthesize _eachPlaceIndex;


//InitWithStyle, doesn't call by segue
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    CHECK_NIL(self);
    _eachPlaceIndex = [[NSMutableArray alloc] init];
    CHECK_NIL(_eachPlaceIndex);
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    Updater* updateHandler = [Updater InstanceGet];
    CHECK_NIL(updateHandler);
    FMDatabase* db = [FMDatabase APPDatabaseGet:[updateHandler LastUpdateFilePathGet]];
    CHECK_NIL(db);
    //select distinct region from expo
    NSString* sql = [[NSString alloc] initWithFormat:@"select distinct %@ from %@;", EXPO_REGION, EXPO_TABLE_NAME];
    FMResultSet *dbResult = [db executeQuery:sql];
    _eachPlaceIndex = [[NSMutableArray alloc] init];
    CHECK_NIL(_eachPlaceIndex);
    
    while ([dbResult next]) {
        int city_idx = [dbResult intForColumn:EXPO_REGION];
        [_eachPlaceIndex addObject:[NSNumber numberWithInt:city_idx - CITY_INDEX_OFFSET]];
    }

    [db close];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    _eachPlaceIndex = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (0 == [_eachPlaceIndex count]) {
        DLog(@"wrong parameter");
//        assert(0);
    }
    return [self._eachPlaceIndex count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (nil == cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    NSUInteger row = [indexPath row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@",gCityNameArray[[[_eachPlaceIndex objectAtIndex:row] intValue]]];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    Updater* updateHandler = [Updater InstanceGet];
    CHECK_NIL(updateHandler);
    FMDatabase* db = [FMDatabase APPDatabaseGet:[updateHandler LastUpdateFilePathGet]];
    CHECK_NIL(db);
    //select distinct region from expo
    NSString* sql = [[NSString alloc] initWithFormat:@"select count(%@) from %@ where %@ = %i;", EXPO_TITLE, EXPO_TABLE_NAME, EXPO_REGION, [[_eachPlaceIndex objectAtIndex:row] intValue]+CITY_INDEX_OFFSET];
    FMResultSet *dbResult = [db executeQuery:sql];
    int exhibitNumber;
    while ([dbResult next]) {
        exhibitNumber = [dbResult intForColumnIndex:0];
    }
    
    [db close];

    MKNumberBadgeView *badge;
    for (UIView *view in cell.subviews) {
        if ([view isMemberOfClass:[MKNumberBadgeView class]]) {
            badge = (MKNumberBadgeView *)view;
        }
    }
    if(!badge){
        badge =[[MKNumberBadgeView alloc] initWithFrame:CGRectMake(240, [tableView rowHeight]/2 - 50/2, 55, 50)];
    }
    badge.value = exhibitNumber;
    badge.shadow = NO;
    badge.shine = NO;
    badge.strokeColor = [UIColor clearColor];
    badge.fillColor = [UIColor colorWithRed:71.0/255 green:2.0/255 blue:9.0/255 alpha:0.8];
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
        ActivityListViewController *retvc = segue.destinationViewController;
        retvc.title = [NSString stringWithFormat:@"%@",gCityNameArray[[[_eachPlaceIndex objectAtIndex:row] intValue]]];
        if (TRUE == [retvc DataSetup:[[_eachPlaceIndex objectAtIndex:row] intValue] + CITY_INDEX_OFFSET]) {
            DLog(@"Error : cannot setup data");
            assert(0);
        }
    }
}

@end
