//
//  ModalCategoryViewController.m
//  ExhibitAPP
//
//  Created by eric on 12/10/7.
//
//

#import "ModalCategoryViewController.h"

//--tag of tabBarItem--
#define TAG_CANCEL 1
#define TAG_FILTER 2

@interface ModalCategoryViewController ()
@property NSArray *filteringArray;
@property NSMutableArray *rowsSelected;
@property NSMutableSet *dataSelected;

@end

@implementation ModalCategoryViewController
@synthesize table;
@synthesize filteringArray;
@synthesize rowsSelected;
@synthesize dataSelected;
@synthesize filteringType;
@synthesize titleLabel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (self.filteringType = filteringTypeCity) {
        self.filteringArray = [GlobalVariable cityName];
        self.titleLabel.text = @"請選擇要篩選的類別";
    }else{
        self.filteringArray = [GlobalVariable activityCategory];
        self.titleLabel.text = @"請選擇要篩選的類別";
    }
    
    self.table.dataSource = self;
    self.table.delegate = self;
    self.rowsSelected = [[NSMutableArray alloc]init];
    self.dataSelected = [[NSMutableSet alloc]init];
    
    for (NSArray *category in self.filteringArray)
    {
        NSMutableArray *items = [[NSMutableArray alloc]init];
        for (NSArray *item in [category objectAtIndex:1])
        {
            [items addObject:[NSNumber numberWithBool:YES]];
            [self.dataSelected addObject:[item objectAtIndex:1]];
        }
         [self.rowsSelected addObject:items];
    }
    
    
  /*  for (int i=0; i<[[GlobalVariable activityCategory]count]; i++) {
        NSMutableArray *citys = [[NSMutableArray alloc]init];
        for (int j=0; j<[[[GlobalVariable activityCategory] objectForKey:[[[[GlobalVariable activityCategory] allKeys] sortedArrayUsingSelector:@selector(compare:)] objectAtIndex:i]] count]; j++) {
            [citys addObject:[NSNumber numberWithBool:YES]];
        }
        [self.rowsSelected addObject:citys];
    }*/
    /*
    for (int i=0; i<[[GlobalVariable activityCategory]count]; i++){
        NSDictionary *regionDictionary = [[GlobalVariable activityCategory] objectForKey:[[[[GlobalVariable activityCategory] allKeys] sortedArrayUsingSelector:@selector(compare:)] objectAtIndex:i]];
        NSMutableArray *citys = [[NSMutableArray alloc]init];
        for (int j=0; j<[regionDictionary count]; j++) {
            NSNumber *cityKey = [regionDictionary objectForKey:[[[regionDictionary allKeys] sortedArrayUsingSelector:@selector(compare:)] objectAtIndex:j]];
            [citys addObject:[NSNumber numberWithBool:YES]];
             [self.dataSelected addObject:cityKey];
        }
        [self.rowsSelected addObject:citys];
    }*/
    
    
    /*NSDictionary *regionDictionary = [[GlobalVariable activityCategory] objectForKey:[[[[GlobalVariable activityCategory] allKeys] sortedArrayUsingSelector:@selector(compare:)] objectAtIndex:section]];
    

    for (NSString *regionKey in [[[GlobalVariable activityCategory]allKeys]sortedArrayUsingSelector:@selector(compare:)]) {
        NSMutableArray *citys = [[NSMutableArray alloc]init];
        for (NSString *cityKey in [[region allValues]sortedArrayUsingSelector:@selector(compare:)]) {
            [citys addObject:[NSNumber numberWithBool:YES]];
            [self.dataSelected addObject:[region valueForKey:cityKey]];
        }
        [self.rowsSelected addObject:citys];
    }*/
    
    //for (NSNumber *number in self.dataSelected) {
        NSLog(@"%@",self.dataSelected);
    //}
    
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [self setTable:nil];
    [self setTitleLabel:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)barButtonItemPressed:(UIBarButtonItem *)sender {
    if (sender.tag == TAG_FILTER) {
        //todo
    }
    
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)selectAll {
    for (int i=0; i<[self.filteringArray count]; i++)
    {
        for (int j=0; j<[[[self.filteringArray objectAtIndex:i]objectAtIndex:1]count]; j++)
        {
            [[self.rowsSelected objectAtIndex:i] replaceObjectAtIndex:j withObject:[NSNumber numberWithBool:YES]];
            [self.dataSelected addObject:[[[[self.filteringArray objectAtIndex:i]objectAtIndex:1]objectAtIndex:j]objectAtIndex:1]];
        }
    }
    [self.table reloadData];
    NSLog(@"%@",self.dataSelected);
}

- (IBAction)deselectAll {
    for (int i=0; i<[self.filteringArray count]; i++)
    {
        for (int j=0; j<[[[self.filteringArray objectAtIndex:i]objectAtIndex:1]count]; j++)
        {
            [[self.rowsSelected objectAtIndex:i] replaceObjectAtIndex:j withObject:[NSNumber numberWithBool:NO]];
        }
    }
    [self.dataSelected removeAllObjects];
    /*
    for (NSMutableArray *region in self.rowsSelected) {
        for (int i=0;i<[region count];i++) {
            [region replaceObjectAtIndex:i withObject:[NSNumber numberWithBool:NO]];
        }
    }*/
    [self.table reloadData];
    NSLog(@"%@",self.dataSelected);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.filteringArray count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    return [[self.filteringArray objectAtIndex:section]objectAtIndex:0];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[[self.filteringArray objectAtIndex:section]objectAtIndex:1]count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"modalCityCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"modalCityCell"];
    }
    NSUInteger row = [indexPath row];
    NSUInteger section = [indexPath section];
    
    cell.textLabel.text = [[[[self.filteringArray objectAtIndex:section]objectAtIndex:1]objectAtIndex:row]objectAtIndex:0];
    
    if ([[[self.rowsSelected objectAtIndex:section] objectAtIndex:row] boolValue]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }else{
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    /*if (cell.selected) {
     cell.accessoryType = UITableViewCellAccessoryCheckmark;
     }else{
     cell.accessoryType = UITableViewCellAccessoryNone;
     }*/
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    
    return cell;
}


#pragma mark - Table view delegate

- (NSIndexPath*)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger row = [indexPath row];
    NSUInteger section = [indexPath section];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if ([[[self.rowsSelected objectAtIndex:section] objectAtIndex:row] boolValue]) {
        [[self.rowsSelected objectAtIndex:section] replaceObjectAtIndex:row withObject:[NSNumber numberWithBool:NO]];
        [self.dataSelected removeObject:[[[[self.filteringArray objectAtIndex:section]objectAtIndex:1]objectAtIndex:row]objectAtIndex:1]];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }else{
        [[self.rowsSelected objectAtIndex:section] replaceObjectAtIndex:row withObject:[NSNumber numberWithBool:YES]];
        [self.dataSelected addObject:[[[[self.filteringArray objectAtIndex:section]objectAtIndex:1]objectAtIndex:row]objectAtIndex:1]];
        cell.accessoryType = UITableViewCellAccessoryCheckmark  ;
    }
    
    NSLog(@"%@",self.dataSelected);
    
    return indexPath;
}


@end
