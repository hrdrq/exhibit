//
//  MyFavoriteViewController.m
//  ExhibitAPP
//
//  Created by sfffaaa on 12/11/11.
//
//

#import "MyFavoriteViewController.h"

#import "NearbyViewController.h"
#import "ActivityInfoViewController.h"
#import "SQLDefine.h"
#import "MyFaviroteHandler/MyFavoriteHandler.h"

#define defaultDistanceInKM 10.0

@implementation MyFavoriteViewController
@synthesize alvc;

//[TODO] The situation needs to be handle, the data in my favorite is out of data, so it is deleted in normal data but doesn't delete in my favorite database. And some mechanism need to be activated when this situation happen.
- (void)viewDidLoad
{
    MyFavoriteHandler* myFavoiter = [MyFavoriteHandler InstanceGet];
    CHECK_NIL(myFavoiter);
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    self.alvc =[storyboard instantiateViewControllerWithIdentifier:@"FaviroteActivityViewController"];
    self.alvc._segueProtocol = self;
    self.alvc._dataSetupDelegate = [myFavoiter DataSetupProtocolGet];
    self.alvc._eachRoughExhibitData = [myFavoiter ItemSelect];
    [self.view addSubview:alvc.view];
    
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"toDetailExhibitTableViewController"]) {
        NSIndexPath *indexPath = sender;
        NSUInteger row = [indexPath row];
        ActivityRoughData *data = [self.alvc._eachRoughExhibitData objectAtIndex:row];
        ActivityInfoViewController *detvc = segue.destinationViewController;
        if ([detvc DetailDataSetup:data]) {
            DLog(@"error cannot get data");
            assert(0);
        }
        detvc.updateTableDelegate = self;
    }
}

#pragma mark - finish protocol which is used to segue from the super view controller, activity list view controller, to self.
-(void) SegueFromAttachVC2OtherVC:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"toDetailExhibitTableViewController" sender:indexPath];
}

#pragma mark - finish protocol which is used to update the view controller for removing the data in my favorite list.
- (void) UpdateActivityListTableFromOtherVC
{
    MyFavoriteHandler* favoriteHandler = [MyFavoriteHandler InstanceGet];
    CHECK_NIL(favoriteHandler);
    CHECK_NIL(self.alvc);
    self.alvc._eachRoughExhibitData = [favoriteHandler ItemSelect];
    [self.alvc.table reloadData];
}

@end