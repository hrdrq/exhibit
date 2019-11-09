//
//  NavigationMapView.h
//  ExhibitAPP
//
//  Created by eric on 12/10/10.
//
//

#import <MapKit/MapKit.h>
#import <MapKit/MapKit.h>
#import <MapKit/MKPolyline.h>

@interface NavigationMapView : MKMapView

@property (nonatomic, strong) MKPolyline*		routeLine;
@property (nonatomic, strong) MKPolylineView*	routeLineView;

-(void)loadRoutes:(NSArray *)inArray;
@end
