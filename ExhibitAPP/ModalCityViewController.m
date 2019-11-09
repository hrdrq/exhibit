//
//  ModalCityViewController.m
//  ExhibitAPP
//
//  Created by eric on 12/10/7.
//
//

#import "ModalCityViewController.h"

//--tag of tabBarItem--
#define TAG_CANCEL 1
#define TAG_FILTER 2

@interface ModalCityViewController ()
@property NSMutableArray *rowsSelected;

@end

@implementation ModalCityViewController
@synthesize table;
@synthesize rowsSelected;

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
    self.table.dataSource = self;
    self.table.delegate = self;
    self.rowsSelected = [[NSMutableArray alloc]init];
    for (int i=0; i<[[GlobalVariable cityName]count]; i++) {
        NSMutableArray *citys = [[NSMutableArray alloc]init];
        for (int j=0; j<[[[GlobalVariable cityName] objectForKey:[[[[GlobalVariable cityName] allKeys] sortedArrayUsingSelector:@selector(compare:)] objectAtIndex:i]] count]; j++) {
            [citys addObject:[NSNumber numberWithBool:YES]];
        }
        [self.rowsSelected addObject:citys];
    }
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [self setTable:nil];
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
}

- (IBAction)deselectAll {
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[GlobalVariable cityName] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    return [[[[[GlobalVariable cityName] allKeys] sortedArrayUsingSelector:@selector(compare:)] objectAtIndex:section] substringFromIndex:3];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[[GlobalVariable cityName] objectForKey:[[[[GlobalVariable cityName] allKeys] sortedArrayUsingSelector:@selector(compare:)] objectAtIndex:section]] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"modalCityCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"modalCityCell"];
    }
    NSUInteger row = [indexPath row];
    NSUInteger section = [indexPath section];
    
    NSDictionary *regionDictionary = [[GlobalVariable cityName] objectForKey:[[[[GlobalVariable cityName] allKeys] sortedArrayUsingSelector:@selector(compare:)] objectAtIndex:section]];
    
    NSString *cityKey = [[[regionDictionary allKeys] sortedArrayUsingSelector:@selector(compare:)] objectAtIndex:row];
    
    cell.textLabel.text = [cityKey substringFromIndex:3];
    
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
        cell.accessoryType = UITableViewCellAccessoryNone;
    }else{
        [[self.rowsSelected objectAtIndex:section] replaceObjectAtIndex:row withObject:[NSNumber numberWithBool:YES]];
        cell.accessoryType = UITableViewCellAccessoryCheckmark  ;
    }
    
    /*if ([tableView cellForRowAtIndexPath:indexPath].selected) {
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
        [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryNone;
    }else{
        [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
        [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryCheckmark;
    }
    [tableView reloadData];*/
    
    /*if (cell.accessoryType == UITableViewCellAccessoryCheckmark) {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }else{
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }*/
    
    
    return indexPath;
}

@end
