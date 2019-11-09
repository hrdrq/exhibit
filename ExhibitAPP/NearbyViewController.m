//
//  NearbyViewController.m
//  ExhibitAPP
//
//  Created by eric on 12/10/5.
//
//

#import "NearbyViewController.h"
#import "ActivityInfoViewController.h"
#import "SQLDefine.h"

#define defaultDistanceInKM 10.0

enum VIEW_TYPE
{
    MVC_TYPE = 0,
    ALVC_TYPE,
};

@interface NearbyViewController ()
{
    int _ViewType;
}

@end

@implementation NearbyViewController
@synthesize mvc;
@synthesize alvc;

- (void)viewDidLoad
{    
	UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    self.mvc = [storyboard instantiateViewControllerWithIdentifier:@"MapViewController"];
    self.mvc.calloutTableViewController = [[ActivityListViewController alloc]init];
    self.mvc.calloutTableViewController._segueProtocol = self;
    [self.view addSubview:self.mvc.view];
    _ViewType = MVC_TYPE;
    
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

- (IBAction)switchViews:(UIBarButtonItem*)sender {
    [UIView beginAnimations:@"View Flip" context:nil];
    [UIView setAnimationDuration:1.0];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    if (!self.alvc.view.superview) {
        if (self.alvc == nil) {
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
            self.alvc =[storyboard instantiateViewControllerWithIdentifier:@"NearbyActivityList"];
            self.alvc._segueProtocol = self;
            self.alvc._dataSetupDelegate = self.alvc;
            [self.alvc._SQLConstraintHandler distanceMutualSetAdd:DEFAULT_DISTANCE];
            [self.alvc dataSetupSelf];
        }
        [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:self.view cache:YES];
        [self.mvc.view removeFromSuperview];
        [self.view addSubview:alvc.view];
        _ViewType = ALVC_TYPE;
        sender.title = @"地圖";
    }
    else{
        assert(self.mvc);
        [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:self.view cache:YES];
        [self.alvc.view removeFromSuperview];
        [self.view addSubview:mvc.view];
        _ViewType = MVC_TYPE;
        sender.title = @"列表";
    }
    [UIView commitAnimations];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    if ([[segue identifier] isEqualToString:@"toDetailExhibitTableViewController"] || [[segue identifier] isEqualToString:@"mapToDetailExhibitTableViewController"]) {
        NSIndexPath *indexPath = sender;
        NSUInteger row = [indexPath row];
        ActivityRoughData *data;
        if (self.alvc.view.superview) {
            data = [self.alvc._eachRoughExhibitData objectAtIndex:row];
        } else {
            data = [self.mvc.calloutTableViewController._eachRoughExhibitData objectAtIndex:row];
        }
        ActivityInfoViewController *detvc = segue.destinationViewController;
        if ([detvc DetailDataSetup:data]) {
            DLog(@"error cannot get data");
            assert(0);
        }
    } /*else if ([[segue identifier] isEqualToString:@"FilteringModal"]) {
        if (((UIButtonAboveTable*)sender).tag == TAG_FILTERING_CITY) {
            DLog(@"should not enter here");
            assert(0);       
        } else {
            if (MVC_TYPE == _ViewType) {
                [self.mvc.sqlConstraintHandler categorySelectedSetAlloc];
                ((FilteringModalViewController*)segue.destinationViewController).SQLSet = self.mvc.sqlConstraintHandler._categorySelectedSet;
                ((FilteringModalViewController*)segue.destinationViewController).delegate = self.mvc;
            } else {
                [self.alvc._SQLConstraintHandler categorySelectedSetAlloc];
                ((FilteringModalViewController*)segue.destinationViewController).SQLSet = self.alvc._SQLConstraintHandler._categorySelectedSet;
                ((FilteringModalViewController*)segue.destinationViewController).delegate = self.alvc;
            }
            ((FilteringModalViewController*)segue.destinationViewController).filteringType = filteringTypeCategory;
        }
    }*/
}

#pragma mark - finish protocol which is used to segue from the super view controller, activity list view controller, to self.
-(void) SegueFromAttachVC2OtherVC:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"mapToDetailExhibitTableViewController" sender:indexPath];
}
@end
