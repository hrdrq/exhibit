//
//  NavigationMapView.m
//  ExhibitAPP
//
//  Created by eric on 12/10/10.
//
//

#import "NavigationMapView.h"
#import "SingleAnnotation.h"

@implementation NavigationMapView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
		self.showsUserLocation = YES;        
		if (nil != self.routeLine) {
			[self addOverlay:self.routeLine];
		}
    }
    return self;
}

- (void) awakeFromNib
{
    self.showsUserLocation = YES;
    if (nil != self.routeLine) {
        [self addOverlay:self.routeLine];
    }
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
    
	[self setRegion:region animated:YES];
    
	// create the polyline based on the array of points.
	self.routeLine = [MKPolyline polylineWithPoints:pointArr count:[routePoints count]];
	[self addOverlay:self.routeLine];
    
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
		} else if ([(SingleAnnotation *)annotation groupTag] == NAVIGATION_ANNOTATION_TYPE_END) {
			pinAnnotation.pinColor = MKPinAnnotationColorRed;
		} else {
			pinAnnotation.pinColor = MKPinAnnotationColorPurple;
		}
		pinAnnotation.animatesDrop = YES;
		pinAnnotation.enabled = YES;
		pinAnnotation.canShowCallout = YES;
		pinAnnotation.canShowCallout = YES;
		pinAnnotation.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
		return pinAnnotation;
	} else {
		return [self viewForAnnotation:self.userLocation];
	}
}
- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
	NSArray *pinTitle=self.annotations;
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
