//
//  NavigationViewController.m
//  ExhibitAPP
//
//  Created by eric on 12/10/10.
//
//

#import "NavigationMapViewController.h"
#import "UICGRoutes.h"

#define IMAGE_TO_SELF_LOCATION @"barItemSelf.png"
#define IMAGE_TO_TARGET_LOCATION @"barItemTarget.png"
#define IMAGE_TO_CHECK_POINT_TABLE @"barItemList.png"
#define IMAGE_SHOW_ROUTE_ANNOTATIONS @"barItemShowRouteAnnotations.png"
#define IMAGE_REMOVE_ROUTE_ANNOTATIONS @"barItemRemoveRouteAnnotations.png"

#define STRING_OPEN_IN_MAP @"使用「地圖」打開"

@interface NavigationMapViewController ()

@end

@implementation NavigationMapViewController
@synthesize toolBar;
@synthesize userTracking;
@synthesize toTargetLocation;
@synthesize toCheckPointTable;
@synthesize openMapApp;
@synthesize activityIndicator;

@synthesize map;
@synthesize Directions;
@synthesize startLocation;
@synthesize endLocation;
@synthesize startPoint;
@synthesize endPoint;
@synthesize BetweenAnnotation;
@synthesize annotationArray;
@synthesize travelMode;
@synthesize destination;
@synthesize routes;
@synthesize Annotations;
@synthesize RouteArray;
@synthesize RouteDetail;
@synthesize checkPointsTable;

-(void)toTargetLocationPressed
{
    [self.map setCenterCoordinate:self.endLocation.coordinate animated:YES ];
}
-(void)openMapAppPressed
{
    UIActionSheet *uias = [[UIActionSheet alloc] initWithTitle:nil
                                                      delegate:self
                                             cancelButtonTitle:@"取消"
                                        destructiveButtonTitle:nil
                                             otherButtonTitles:STRING_OPEN_IN_MAP, nil];
    
    [uias showInView:self.view];
}
#pragma mark - UIActionSheet Delegate

- (void)actionSheet:(UIActionSheet *)uias clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == [uias cancelButtonIndex]) return;
    
    if([[uias buttonTitleAtIndex:buttonIndex] compare:STRING_OPEN_IN_MAP] == NSOrderedSame)
    {
        NSString *theString = [NSString
                               stringWithFormat:@"http://maps.google.com/maps?saddr=%f,%f&daddr= %f,%f",self.startLocation.coordinate.latitude,self.startLocation.coordinate.longitude,self.endLocation.coordinate.latitude,self.endLocation.coordinate.longitude];
        theString = [theString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSURL *url = [[NSURL alloc] initWithString:theString];
        [[UIApplication sharedApplication] openURL:url];
    }
    
}

#pragma mark - main

-(void)setupToolBarItems
{
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    
    self.userTracking = [[MKUserTrackingBarButtonItem alloc] initWithMapView:map];
    self.userTracking.style = UIBarButtonItemStylePlain;

    self.toTargetLocation = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:IMAGE_TO_TARGET_LOCATION]
                                                       style:UIBarButtonItemStylePlain
                                                      target:self
                                                      action:@selector(toTargetLocationPressed)];
    
    self.showRouteAnnotations = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:IMAGE_SHOW_ROUTE_ANNOTATIONS]
                                                              style:UIBarButtonItemStylePlain
                                                             target:self
                                                             action:@selector(loadRouteAnnotations)];
    
    self.toCheckPointTable = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:IMAGE_TO_CHECK_POINT_TABLE]
                                                             style:UIBarButtonItemStylePlain
                                                            target:self
                                                            action:@selector(showCheckpoints)];

    self.openMapApp = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                                                                      target:self
                                                                      action:@selector(openMapAppPressed)];
    
    // Hide tab bars / toolbars etc
    self.hidesBottomBarWhenPushed = YES;

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:activityIndicator];
    
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    NSMutableArray *toolbarButtons = [[NSMutableArray alloc] initWithObjects:self.userTracking, flexibleSpace, self.toTargetLocation, flexibleSpace, self.showRouteAnnotations, flexibleSpace, self.toCheckPointTable,flexibleSpace, self.openMapApp, nil];

    [self.toolBar setItems:toolbarButtons animated:YES];

}

- (void)setToolBarItemsEnabled:(BOOL)enabled
{
    self.userTracking.enabled = enabled;
    self.toTargetLocation.enabled = enabled;
    self.showRouteAnnotations.enabled = enabled;
    self.toCheckPointTable.enabled = enabled;
    self.openMapApp.enabled = enabled;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	self.title = @"導航";
	
	self.annotationArray = [[NSMutableArray alloc]init];
	self.routes			 = [[UICGRoutes alloc]init];
    
    self.Directions			 = [UICGDirections sharedDirections];
	self.Directions.delegate = self;
    [self.Directions.routeArray removeAllObjects];
    
	
	if (self.Directions.isInitialized) {
		[self updateRoute];
	}
    
    self.map.delegate = self;
    if (nil != self.routeLine) {
        [self.map addOverlay:self.routeLine];
    }
    
    if (self.navigationController) {
        self.toolBar.barStyle = self.navigationController.navigationBar.barStyle;
        self.toolBar.tintColor = self.navigationController.navigationBar.tintColor;
        
        // iOS5 specific part
        if ([self.navigationController.navigationBar respondsToSelector:@selector(backgroundImageForBarMetrics:)]) {
            if ([self.navigationController.navigationBar backgroundImageForBarMetrics:UIBarMetricsDefault]) {
                [self.toolBar setBackgroundImage:[self.navigationController.navigationBar backgroundImageForBarMetrics:UIBarMetricsDefault]
                              forToolbarPosition:UIToolbarPositionAny
                                      barMetrics:UIBarMetricsDefault];
                
            }
            
            if ([self.navigationController.navigationBar backgroundImageForBarMetrics:UIBarMetricsLandscapePhone]) {
                [self.toolBar setBackgroundImage:[self.navigationController.navigationBar backgroundImageForBarMetrics:UIBarMetricsLandscapePhone]
                              forToolbarPosition:UIToolbarPositionAny
                                      barMetrics:UIBarMetricsLandscapePhone];
                
            }
            
        }
        
        
        
        
    }
    

    //self.openMapApp.style = UIBarButtonSystemItemAction;
    [self setupToolBarItems];
    [self setToolBarItemsEnabled:NO];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [self setMap:nil];
    [self setUserTracking:nil];
    [self setToTargetLocation:nil];
    [self setToCheckPointTable:nil];
    [self setOpenMapApp:nil];
    [self setToolBar:nil];
    [super viewDidUnload];
}

- (void)updateRoute
{
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
	UICGDirectionsOptions *options = [[UICGDirectionsOptions alloc] init];
	options.travelMode = self.travelMode;

    NSString *start = [NSString stringWithFormat:@"%f,%f",self.startLocation.coordinate.latitude,self.startLocation.coordinate.longitude];
    NSMutableArray *end = [NSArray arrayWithObject:[NSString stringWithFormat:@"%f,%f",self.endLocation.coordinate.latitude,self.endLocation.coordinate.longitude]];

	[self.Directions loadWithStartPoint:start endPoint:end options:options];
}

-(void)loadRouteAnnotations
{
	self.RouteArray = [self.Directions routeArray];
    NSLog(@"RouteArray %@",self.RouteArray);
	self.Annotations = [[NSMutableArray alloc]init];
	for (int idx = 0; idx < [self.RouteArray count]; idx++) {
		NSArray *_routeWayPoints1 = [[self.RouteArray objectAtIndex:idx] wayPoints];
		NSArray *mPlacetitles = [[self.RouteArray objectAtIndex:idx] mPlaceTitle];
		self.annotationArray = [NSMutableArray arrayWithCapacity:[_routeWayPoints1 count]-2];

		
		for(int idx = 0; idx < [_routeWayPoints1 count]-1; idx++)
		{
			self.BetweenAnnotation = [[SingleAnnotation alloc] initWithCoordinate:[[_routeWayPoints1 objectAtIndex:idx]coordinate]
																		  title:[mPlacetitles objectAtIndex:idx]
												
                                                                          subtitle:nil groupTag:NAVIGATION_ANNOTATION_TYPE_WAY_POINT];                                              
			[self.annotationArray addObject:self.BetweenAnnotation];
		}
		[self.Annotations addObject:self.annotationArray];
		[self.map addAnnotations:[self.Annotations objectAtIndex:idx]];
        [self.activityIndicator stopAnimating];
        
        self.showRouteAnnotations.action = @selector(removeRouteAnnotations);
        self.showRouteAnnotations.image = [UIImage imageNamed:IMAGE_REMOVE_ROUTE_ANNOTATIONS];
	}
}

-(void)removeRouteAnnotations
{
	NSMutableArray *TempAnnotation = self.Annotations;
	for (int idx = 0; idx < [TempAnnotation count]; idx++) {
		[self.map removeAnnotations:[TempAnnotation objectAtIndex:idx] ];
	}
	self.showRouteAnnotations.action = @selector(loadRouteAnnotations);
    self.showRouteAnnotations.image = [UIImage imageNamed:IMAGE_SHOW_ROUTE_ANNOTATIONS];

}

-(void)showCheckpoints
{
    if (!self.checkPointsTable) {
        self.checkPointsTable = [[UITableViewController alloc]initWithStyle:UITableViewStylePlain];
        self.checkPointsTable.tableView.dataSource = self;
        self.checkPointsTable.tableView.delegate = self;
    }
	[self.navigationController pushViewController:self.checkPointsTable animated:YES];
}


#pragma mark <UICGDirectionsDelegate> Methods

- (void)directionsDidFinishInitialize:(UICGDirections *)directions {
	[self updateRoute];
}

- (void)directions:(UICGDirections *)directions didFailInitializeWithError:(NSError *)error {
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Map Directions" message:[error localizedFailureReason] delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
	[alertView show];
}

- (void)directionsDidUpdateDirections:(UICGDirections *)indirections {
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	
	UICGPolyline *polyline = [indirections polyline];
	NSArray *routePoints = [polyline routePoints];
	
	[self loadRoutes:routePoints]; // Loads route by getting the array of all coordinates in the route.

	
	//Add annotations of different colors based on initial and final places.
	SingleAnnotation *startAnnotation = [[SingleAnnotation alloc] initWithCoordinate:[[routePoints objectAtIndex:0] coordinate]
                                                                               title:self.startPoint subtitle:nil groupTag:NAVIGATION_ANNOTATION_TYPE_START];
                                                                         
	SingleAnnotation *endAnnotation = [[SingleAnnotation alloc] initWithCoordinate:[[routePoints lastObject] coordinate]
                                                                              title:self.endPoint subtitle:nil groupTag:NAVIGATION_ANNOTATION_TYPE_END];

	//[self loadRouteAnnotations];
	[self.map addAnnotations:[NSArray arrayWithObjects:startAnnotation, endAnnotation,nil]];
    [self setToolBarItemsEnabled:YES];
}

- (void)directions:(UICGDirections *)directions didFailWithMessage:(NSString *)message {
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Map Directions" message:message delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
	[alertView show];
}


#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    return 1;
	
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
	return [[[self.Directions checkPoint] mPlaceTitle] count];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
	{
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    // Configure the cell...
	cell.textLabel.text = [NSString stringWithFormat:@"%@",[[[self.Directions checkPoint] mPlaceTitle] objectAtIndex:indexPath.row]];
	cell.textLabel.numberOfLines = 3;
	cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:14.0f];
	return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
	return 55.0f;
}

-(void)loadRoutes:(NSArray *)routePoints
{
    
	MKMapPoint northEastPoint;
	MKMapPoint southWestPoint;
    
	// create a c array of points.
	MKMapPoint* pointArr = malloc(sizeof(CLLocationCoordinate2D) * [routePoints count]);
	//NSLog(@" %d",[routePoints count]);
	
	for(int idx = 0; idx < [routePoints count]; idx++)
	{
		CLLocation *location = (CLLocation *)[routePoints objectAtIndex:idx];
		
		CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude);
		
		// break the string down even further to latitude and longitude fields.
		MKMapPoint point = MKMapPointForCoordinate(coordinate);
        
		// if it is the first point, just use them, since we have nothing to compare to yet.
		if (idx == 0)
		{
			northEastPoint = point;
			southWestPoint = point;
		}
		else
		{
			if (point.x > northEastPoint.x)
				northEastPoint.x = point.x;
			if(point.y > northEastPoint.y)
				northEastPoint.y = point.y;
			if (point.x < southWestPoint.x)
				southWestPoint.x = point.x;
			if (point.y < southWestPoint.y)
				southWestPoint.y = point.y;
		}
		pointArr[idx] = point;
	}
	
	CLLocationDegrees maxLat = -90.0f;
	CLLocationDegrees maxLon = -180.0f;
	CLLocationDegrees minLat = 90.0f;
	CLLocationDegrees minLon = 180.0f;
	
	
	for (int i = 0; i < [routePoints count]; i++) {
		CLLocation *currentLocation = [routePoints  objectAtIndex:i];
		if(currentLocation.coordinate.latitude > maxLat) {
			maxLat = currentLocation.coordinate.latitude;
		}
		if(currentLocation.coordinate.latitude < minLat) {
			minLat = currentLocation.coordinate.latitude;
		}
		if(currentLocation.coordinate.longitude > maxLon) {
			maxLon = currentLocation.coordinate.longitude;
		}
		if(currentLocation.coordinate.longitude < minLon) {
			minLon = currentLocation.coordinate.longitude;
		}
	}
	
	MKCoordinateRegion region;
	region.center.latitude     = (maxLat + minLat) / 2;
	region.center.longitude    = (maxLon + minLon) / 2;
	region.span.latitudeDelta  = maxLat - minLat;
	region.span.longitudeDelta = maxLon - minLon;
    
	[self.map setRegion:region animated:YES];
    
	// create the polyline based on the array of points.
	self.routeLine = [MKPolyline polylineWithPoints:pointArr count:[routePoints count]];
	[self.map addOverlay:self.routeLine];
    
	// clear the memory allocated earlier for the points
	free(pointArr);
	
}

#pragma mark <MKMapViewDelegate> Methods

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
	static NSString *identifier = @"RoutePinAnnotation";
	
	if ([annotation isKindOfClass:[SingleAnnotation class]]) {
		MKPinAnnotationView *pinAnnotation = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
		if(!pinAnnotation) {
			pinAnnotation = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
		}
		
		if ([(SingleAnnotation *)annotation groupTag] == NAVIGATION_ANNOTATION_TYPE_WAY_POINT) {
			pinAnnotation.pinColor = MKPinAnnotationColorGreen;
            pinAnnotation.animatesDrop = YES;
            UIButton *calloutButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
            [calloutButton addTarget:self action:@selector(showCheckpoints) forControlEvents:UIControlEventTouchUpInside];
            pinAnnotation.rightCalloutAccessoryView = calloutButton;
		} else if ([(SingleAnnotation *)annotation groupTag] == NAVIGATION_ANNOTATION_TYPE_END) {
			pinAnnotation.pinColor = MKPinAnnotationColorRed;
		} else {
			pinAnnotation.pinColor = MKPinAnnotationColorPurple;
		}
		pinAnnotation.enabled = YES;
        pinAnnotation.canShowCallout = YES;
		return pinAnnotation;
	} else {
		return [self.map viewForAnnotation:self.map.userLocation];
	}
}
- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
	NSArray *pinTitle=self.map.annotations;
	for (int idx = 0 ; idx < [pinTitle count]; idx ++) {
		SingleAnnotation *pinTitle1 = [pinTitle objectAtIndex:idx];
		NSString *pinTitle11 = pinTitle1.title;
		NSLog(@" pinTitle1 %@",pinTitle11);
        
	}
}

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay
{
	MKOverlayView* overlayView = nil;
	if(overlay == self.routeLine)
	{
		//self.routeLineView = nil;
        //		//if we have not yet created an overlay view for this overlay, create it now.
        //		if(nil == self.routeLineView)
        //		{
        self.routeLineView = [[MKPolylineView alloc] initWithPolyline:self.routeLine];
        self.routeLineView.fillColor = [UIColor redColor];
        self.routeLineView.strokeColor = [UIColor redColor];
        self.routeLineView.lineWidth = 3;
		//}
		overlayView = self.routeLineView;
		
		NSLog(@"overlayView %@",overlayView);
	}
	return overlayView;
}



@end
