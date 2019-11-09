//
//  RoughViewController.m
//  ExhibitAPP
//
//  Created by eric on 12/10/4.
//
//

#import "RoughViewController.h"
#import "RoughExhibitData.h"
#import "RoughExhibitWithNetworkTableViewCell.h"
#import "RoughExhibitWithoutNetworkTableViewCell.h"
#import "DetailExhibitTableViewController.h"
#import "GlobalVariable.h"
#import "FMDatabase.h"
#import "Updater.h"
#import "DebugUtil.h"

#define DISTANCE_FILTER 3000.f

static CLLocation* gCurrLocation = nil;

@interface RoughViewController ()
{
    BOOL _nibsRegistered;
    NSString* _NSCellIdentifier;
    NSString* _NSNibName;
    CLLocationManager* _LocateManager;
}
@property (strong, nonatomic) DetailExhibitTableViewController* _viewController;
@end

@implementation RoughViewController
@synthesize _eachRoughExhibitData;
@synthesize _viewController;
@synthesize _topViewController;
@synthesize tableView;

- (id)init
{
    self = [super init];
    if (self) {
        static int index = 1;
        if (index % 2) {
            _NSCellIdentifier = @"RoughExhibitWithNetworkTableViewCellIdentifier";
            _NSNibName = @"RoughExhibitWithNetworkTableViewCell";
        } else {
            _NSCellIdentifier = @"RoughExhibitWithoutNetworkTableViewCellIdentifier";
            _NSNibName = @"RoughExhibitWithoutNetworkTableViewCell";
        }
    }
    return self;
}

-(void)awakeFromNib
{
    static int index = 1;
    if (index % 2) {
        _NSCellIdentifier = @"RoughExhibitWithNetworkTableViewCellIdentifier";
        _NSNibName = @"RoughExhibitWithNetworkTableViewCell";
    } else {
        _NSCellIdentifier = @"RoughExhibitWithoutNetworkTableViewCellIdentifier";
        _NSNibName = @"RoughExhibitWithoutNetworkTableViewCell";
    }
    
    _LocateManager = [[CLLocationManager alloc] init];
    CHECK_NIL(_LocateManager);
    _LocateManager.Delegate = self;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"距離排序" style:UIBarButtonItemStylePlain target:self action:@selector(DistanceSort:)];
    _LocateManager.distanceFilter = DISTANCE_FILTER;
    _LocateManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers;
    [_LocateManager startUpdatingLocation];
    if (nil == _LocateManager.location) {
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
    _nibsRegistered = NO;
    
    _viewController = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
   
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    _eachRoughExhibitData = nil;
    _viewController = nil;
    _topViewController = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Customize

- (BOOL) DataSetup: (int)cityindex
{
    if (0 > cityindex) {
        return TRUE;
    }
    _eachRoughExhibitData = [[NSMutableArray alloc] init];
    CHECK_NIL(_eachRoughExhibitData);
    Updater* updateHandler = [Updater InstanceGet];
    CHECK_NIL(updateHandler);
    
    FMDatabase* db = [FMDatabase APPDatabaseGet:[updateHandler LastUpdateFilePathGet]];
    CHECK_NIL(db);
    
    /*
     *  SQL command
     *  select name, pic, time, latitude, longtitudefrom expo where region = 28 and edate >= "2012-12-10"
     */
    NSString* dateSQL = [FMDatabase APPDateSQLConstraint];
    CHECK_NIL(dateSQL);
    NSString* NScity = [[NSString alloc] initWithFormat:@"select %@, %@, %@, %@, %@ from %@ where %@ = %i and %@", EXPO_TITLE, EXPO_IMAGEURL, EXPO_TIME, EXPO_LATITUDE, EXPO_LONGITUDE, EXPO_TABLE_NAME , EXPO_REGION, cityindex, dateSQL];
    FMResultSet *dbResult = [db executeQuery:NScity];
    
    while ([dbResult next]) {
        RoughExhibitData *exhibitdata = [[RoughExhibitData alloc] init];
        CHECK_NIL(exhibitdata);
        exhibitdata._title = [dbResult stringForColumn:EXPO_TITLE];
        exhibitdata._date = [dbResult stringForColumn:EXPO_TIME];
        exhibitdata._imageURL = [dbResult stringForColumn:EXPO_IMAGEURL];
        exhibitdata._locate = [[CLLocation alloc] initWithLatitude:[[dbResult stringForColumn:EXPO_LATITUDE] floatValue] longitude:[[dbResult stringForColumn:EXPO_LONGITUDE] floatValue]];
        [exhibitdata setRegion: cityindex];
        
        CHECK_NIL(exhibitdata._title);
        CHECK_NIL(exhibitdata._date);
        CHECK_NIL(exhibitdata._imageURL);
        CHECK_NIL(exhibitdata._locate);
        [_eachRoughExhibitData addObject:exhibitdata];
    }
    return FALSE;
}


#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (nil == _eachRoughExhibitData ||
        0 == [_eachRoughExhibitData count]) {
        DLog(@"Error: wrong parameter");
        return 0;
    }
    return [_eachRoughExhibitData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CHECK_NIL(tableView);
    CHECK_NIL(indexPath);
    CHECK_NIL(_NSNibName);
    CHECK_NIL(_NSCellIdentifier);
    
    if (NO == _nibsRegistered) {
        UINib *nib = [UINib nibWithNibName:_NSNibName bundle:nil];
        CHECK_NIL(nib);
        [tableView registerNib:nib forCellReuseIdentifier:_NSCellIdentifier];
        _nibsRegistered = YES;
    }
    id<RoughExhibitTableViewCellProtocol> cell = [tableView dequeueReusableCellWithIdentifier:_NSCellIdentifier];
    
    CHECK_NIL(cell);
    NSUInteger row = [indexPath row];
    RoughExhibitData* data = [_eachRoughExhibitData objectAtIndex:row];
    CHECK_NIL(data);
    [cell setNameLabelinProctocol:data._title];
    [cell setDateLableinProctocol:data._date];
    [cell setImageinProctocol:data._imageURL];
    return (UITableViewCell*) cell;
}

#pragma mark - Table view delegate

- (NSIndexPath*)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_topViewController) {
        [_topViewController performSegueWithIdentifier:@"mapToDetailExhibitTableViewController" sender:indexPath];
    }else{
        [self performSegueWithIdentifier:@"toDetailExhibitTableViewController" sender:indexPath];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    return indexPath;
}

#pragma mark - Segue

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    if ([[segue identifier] isEqualToString:@"toDetailExhibitTableViewController"]) {
        NSIndexPath *indexPath = sender;
        NSUInteger row = [indexPath row];
        RoughExhibitData *data = [_eachRoughExhibitData objectAtIndex:row];
        DetailExhibitTableViewController *detvc = segue.destinationViewController;
        detvc.title = data._title;
        if ([detvc DetailDataSetup:data._title regionID: [data getRegion]]) {
            DLog(@"error cannot get data");
            assert(0);
        }
    }
}

#pragma mark - CLLocation methods

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    self.navigationItem.rightBarButtonItem.enabled = YES;
    gCurrLocation = newLocation;
    //[_LocateManager stopUpdatingLocation];
}

#pragma mark - Sorting action for location

//Implement in the delegate.
- (void) DistanceSort:(UIBarButtonItem *)sender
{
    [_LocateManager startUpdatingLocation];
    NSSortDescriptor *distanceSorter = [[NSSortDescriptor alloc] initWithKey:@"_locate" ascending:YES selector:@selector(distanceCompare:)];
    if (nil == gCurrLocation && nil != _LocateManager.location) {
        gCurrLocation = _LocateManager.location;
    }
    if ([self DataSort:distanceSorter]) {
        DLog(@"cannot sort");
        assert(0);
    }
    [self.tableView reloadData];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"時間排序" style:UIBarButtonItemStylePlain target:self action:@selector(TimeSort:)];
}

- (IBAction)statusPressed:(id)sender {
}

- (IBAction)sortingPressed:(id)sender {
}

- (IBAction)cityPressed:(id)sender {
}

- (IBAction)categoryPressed:(id)sender {
}

- (IBAction)zoomPressed:(id)sender {
}

- (IBAction)distancePressed:(id)sender {
}

#pragma mark - sorting action 2 time sorting

//Implement in the delegate.
- (void) TimeSort:(UIBarButtonItem *)sender
{
    NSSortDescriptor *timeSortor = [[NSSortDescriptor alloc] initWithKey:@"_date" ascending:YES selector:@selector(localizedCompare:)];
    if ([self DataSort:timeSortor]) {
        DLog(@"cannot sort");
        assert(0);
    }
    [self.tableView reloadData];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"地點排序" style:UIBarButtonItemStylePlain target:self action:@selector(DistanceSort:)];
    
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

@end

@interface CLLocation (distanceCompare) <CLLocationManagerDelegate>
- (NSComparisonResult)distanceCompare:(NSNumber*)other;
@end

@implementation CLLocation (distanceCompare)

- (NSComparisonResult)distanceCompare:(CLLocation*)other {
    NSAssert([other isKindOfClass:[CLLocation class]], @"Must be a clloaction");
    CLLocationDistance left = [gCurrLocation distanceFromLocation:self];
    CLLocationDistance right = [gCurrLocation distanceFromLocation:other];
    
    if (left < right) {
        return NSOrderedAscending;
    } else if (left == right){
        return NSOrderedSame;
    } else {
        return NSOrderedDescending;
    }
}


@end
