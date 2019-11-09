//
//  SearchViewController.m
//  ExhibitAPP
//
//  Created by sfffaaa sfffaaa on 12/9/7.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

/*
 * [TODO] Maybe need to solve the trim of space and strange character.
 */
#import "SearchViewController.h"
#import "Exhibit.h"
#import "ActivityListViewController.h"
#import "ActivityInfoViewController.h"
#import "SQLConstraintMaker.h"
#import "SQLDefine.h"

#define SEARCH_ALL @"全部搜尋"
#define SEARCH_TITLE @"名稱"
#define SEARCH_KEYWORD @"關鍵字"
#define SEARCH_NONSETUP @"尚未設定"

#define SEARCH_ALL_KEY @"SEARCH_FOR_ALL_DB_ITEM"

#define kTimeTag 1
#define KCalendarTag 3

#define kSearchTitleTableViewCellType @"0"
#define kSearchTitleTableViewCellIndex 0
#define kSearchTitleTableViewCellHeight 44

#define kSearchTitleInfoTableViewCellType @"1"
#define kSearchTitleInfoTableViewCellIndex 1
#define kSearchTitleInfoTableViewCellHeight 44

@interface SearchDataElement : NSObject

@property (strong, nonatomic) NSString* _title;
@property (strong, nonatomic) NSString* _info;

@end

@implementation SearchDataElement

@synthesize _title;
@synthesize _info;

@end


@interface SearchViewController ()
{
    int _searchType;
    int _tableViewCellType;
}
@property (strong, nonatomic) NSString* _constraintText;
@property (strong, nonatomic) NSMutableArray* _exhibitArray;
@property (strong, nonatomic) PMCalendarController *_pmCC;
@property (strong, nonatomic) PMPeriod* _timePeriod;

@end

@implementation SearchViewController
@synthesize _constraintText;
@synthesize _exhibitArray;
@synthesize _pmCC;
@synthesize _timePeriod;

#pragma mark : get the name array in scope bar (only execute for once)
+ (NSArray*) scopeItemPair
{
    static NSArray* pairArray = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        pairArray = @[ @[SEARCH_ALL, @[EXPO_TITLE, EXPO_INFO], kSearchTitleInfoTableViewCellType],
        @[SEARCH_TITLE, @[EXPO_TITLE], kSearchTitleTableViewCellType],
        @[SEARCH_KEYWORD, @[EXPO_INFO], kSearchTitleInfoTableViewCellType]
        ];
    });
    return pairArray;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    CHECK_NIL(self);
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    _searchType = 0;
    _tableViewCellType = 1;
    _exhibitArray = [[NSMutableArray alloc] init];
    CHECK_NIL(_exhibitArray);
    
    _pmCC = [[PMCalendarController alloc] init];
    CHECK_NIL(_pmCC);
    _pmCC.delegate = self;
    _pmCC.mondayFirstDayOfWeek = YES;
        
    [_pmCC presentCalendarFromRect:CGRectZero
                           inView:[self.view viewWithTag:KCalendarTag]
         permittedArrowDirections:PMCalendarArrowDirectionUp
                         animated:YES];

    UILabel* timeLabel = (UILabel*)[self.view viewWithTag:kTimeTag];
    CHECK_NIL(timeLabel);
    timeLabel.text = [NSString stringWithFormat:SEARCH_NONSETUP];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    _constraintText = nil;
    _exhibitArray = nil;
    _pmCC = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)setConstraintText:(NSString*) searchBarText
{
    CHECK_NIL(searchBarText);
    _constraintText = [SQLConstraintMaker searchTextSQLConstraintGenerate:self->_searchType searchText:searchBarText];
    if (_timePeriod) {
        NSString* timeText = [SQLConstraintMaker searchTimeSQLConstraintGenerate:_timePeriod.startDate endDate:_timePeriod.endDate];
        CHECK_NIL(timeText);
        _constraintText = [_constraintText stringByAppendingFormat:@"%@", timeText];
    }
}

- (BOOL) generateSearchDataArray: (NSString*) userSearchText
{
    [_exhibitArray removeAllObjects];
    CHECK_NIL(_exhibitArray);
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
    NSString* SQLCommand = [[NSString alloc] initWithFormat:@"select %@, %@ from %@ where %@", EXPO_TITLE, EXPO_INFO, EXPO_TABLE_NAME , dateSQL];
    SQLCommand = [SQLCommand stringByAppendingFormat:@"%@", userSearchText];
    FMResultSet *dbResult = [db executeQuery:SQLCommand];
    
    while ([dbResult next]) {
        SearchDataElement* exhibitdata = [[SearchDataElement alloc] init];
        CHECK_NIL(exhibitdata);
        exhibitdata._title = [dbResult stringForColumn:EXPO_TITLE];
        exhibitdata._info = [dbResult stringForColumn:EXPO_INFO];
        CHECK_NIL(exhibitdata._title);
        [_exhibitArray addObject:exhibitdata];
    }
    return FALSE;
}

- (ActivityRoughData*) generateRoughData: (NSString*)titleStr
{
    CHECK_NIL(titleStr);
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
    NSString* SQLCommand = [[NSString alloc] initWithFormat:@"select %@, %@, %@, %@, %@, %@, %@, %@, %@, %@ from %@ where %@ and %@ = \"%@\"", EXPO_TITLE, EXPO_REGION, EXPO_IMAGEURL,  EXPO_START_DATE, EXPO_END_DATE, EXPO_START_TIME, EXPO_END_TIME, EXPO_PLACE,  EXPO_LATITUDE, EXPO_LONGITUDE, EXPO_TABLE_NAME , dateSQL, EXPO_TITLE, titleStr];
    DLog(@"%@", SQLCommand);
    FMResultSet *dbResult = [db executeQuery:SQLCommand];
    
    while ([dbResult next]) {
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
        return exhibitdata;
    }
    CHECK_NOT_ENTER_HERE;
    return nil;
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"toRoughExhibitTableViewController"]) {
        ActivityListViewController *retvc = segue.destinationViewController;
        retvc.title = @"搜尋結果";
        retvc._SQLConstraintHandler = [[SQLConstraintMaker alloc] init];
        retvc._SQLConstraintHandler._searchText = _constraintText;
        retvc._dataSetupDelegate = retvc;
        [retvc dataSetupSelf];
    } else if ([[segue identifier] isEqualToString:@"toDetailExhibitTableViewController"]) {
        NSUInteger row = [(NSIndexPath*)sender row];
        ActivityInfoViewController *detvc = segue.destinationViewController;
        SearchDataElement* check = [_exhibitArray objectAtIndex:row];
        if ([detvc DetailDataSetup:[self generateRoughData:check._title]]) {
            DLog(@"error cannot get data");
            assert(0);
        }
    }
}

#pragma mark - UISearchBarDelegate
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    NSMutableArray* nameArray = [[NSMutableArray alloc] init];
    NSArray* pairArray = [SearchViewController scopeItemPair];

    for (NSArray* pair in pairArray) {
        [nameArray addObject:[pair objectAtIndex:0]];
    }
    searchBar.scopeButtonTitles = nameArray;
    [searchBar sizeToFit];
    searchBar.showsCancelButton = YES;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [self setConstraintText:searchBar.text];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self setConstraintText:searchBar.text];
    [self performSegueWithIdentifier:@"toRoughExhibitTableViewController" sender:nil];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar {

    searchBar.showsScopeBar = FALSE;
    [searchBar sizeToFit];
}

- (void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope
{
    _searchType = selectedScope;
    static NSArray* pairArray = nil;
    if (nil == pairArray) {
        pairArray = [SearchViewController scopeItemPair];
        CHECK_NIL(pairArray);
    }
    _tableViewCellType = [[[pairArray objectAtIndex:selectedScope] objectAtIndex:2] intValue];
    
    [self setConstraintText:searchBar.text];
}

#pragma mark -
#pragma mark UITableView data source and delegate methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if (tableView == self.searchDisplayController.searchResultsTableView)
	{
        return [_exhibitArray count];
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView != self.searchDisplayController.searchResultsTableView) {
        CHECK_NOT_ENTER_HERE;
    }
    UITableViewCell *cell = nil;
    SearchDataElement* data = nil;
    switch (_tableViewCellType) {
        case kSearchTitleTableViewCellIndex:
            cell = [tableView dequeueReusableCellWithIdentifier:@"SearchTitleTableViewCell"];
            if (!cell) {
                cell = [[[NSBundle mainBundle] loadNibNamed:@"SearchListCell" owner:self options:nil] objectAtIndex:kSearchTitleTableViewCellIndex];
            }
            data = [_exhibitArray objectAtIndex:indexPath.row];
            ((UILabel*)[cell viewWithTag:1]).text = data._title;
            break;
        case kSearchTitleInfoTableViewCellIndex:
            cell = [tableView dequeueReusableCellWithIdentifier:@"SearchTitleInfoTableViewCell"];
            if (!cell) {
                cell = [[[NSBundle mainBundle] loadNibNamed:@"SearchListCell" owner:self options:nil] objectAtIndex:kSearchTitleInfoTableViewCellIndex];
            }
            data = [_exhibitArray objectAtIndex:indexPath.row];
            ((UILabel*)[cell viewWithTag:1]).text = data._title;
            ((UILabel*)[cell viewWithTag:2]).text = data._info;
            ((UILabel*)[cell viewWithTag:2]).textColor = [UIColor blueColor];
            break;
        default:
            CHECK_NOT_ENTER_HERE;
            break;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"toDetailExhibitTableViewController" sender:indexPath];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (_tableViewCellType) {
        case kSearchTitleTableViewCellIndex:
            return kSearchTitleTableViewCellHeight;
        case kSearchTitleInfoTableViewCellIndex:
            return kSearchTitleInfoTableViewCellHeight;
        default:
            CHECK_NOT_ENTER_HERE;
            break;
    }
    CHECK_NOT_ENTER_HERE;
    return kSearchTitleInfoTableViewCellIndex;
}

#pragma mark -
#pragma mark UISearchDisplayController Delegate Methods

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    if ([self generateSearchDataArray:_constraintText]) {
        CHECK_NOT_ENTER_HERE;
    }
    return YES;
}


- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption
{
    if ([self generateSearchDataArray:_constraintText]) {
        CHECK_NOT_ENTER_HERE;
    }
    return YES;
}

#pragma mark PMCalendarControllerDelegate methods

- (void)calendarController:(PMCalendarController *)calendarController didChangePeriod:(PMPeriod *)newPeriod
{
    UILabel* timeLabel = (UILabel*)[self.view viewWithTag:kTimeTag];
    CHECK_NIL(timeLabel);
    timeLabel.text = [NSString stringWithFormat:@"%@ - %@"
                      , [newPeriod.startDate dateStringWithFormat:@"yyyy-MM-dd"]
                      , [newPeriod.endDate dateStringWithFormat:@"yyyy-MM-dd"]];
    _timePeriod = newPeriod;
}

#pragma mark : show the scroll bar when user click the search result table view
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    
    if (FALSE == self.searchDisplayController.searchBar.showsScopeBar) {
        self.searchDisplayController.searchBar.showsScopeBar = TRUE;
        [self.searchDisplayController.searchBar sizeToFit];
    }
}

@end
