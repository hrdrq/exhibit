//
//  NavigationViewController.h
//  ExhibitAPP
//
//  Created by eric on 12/10/10.
//
//

#import <UIKit/UIKit.h>
#import "UICGDirections.h"
#import "UICGCheckPoint.h"
#import <MapKit/MKPolyline.h>
#import "SingleAnnotation.h"

@class UICGRoutes ;
@class SBRouteDetailView;

@interface NavigationViewController : UIViewController<UICGDirectionsDelegate,UIWebViewDelegate,UITableViewDelegate,UITableViewDataSource,MKMapViewDelegate>


@property (weak, nonatomic) IBOutlet MKMapView *map;
@property (nonatomic,strong) UICGDirections* Directions;
@property (nonatomic,strong) NSString* startPoint;
@property (nonatomic,strong) NSString* endPoint;
@property (nonatomic,strong) SingleAnnotation* BetweenAnnotation;
@property (nonatomic,strong) NSMutableArray* annotationArray;
@property (nonatomic)        UICGTravelModes travelMode;
@property (nonatomic,strong) NSMutableArray *destination;
@property (nonatomic,strong) UICGRoutes *		routes;
@property (nonatomic,strong) NSMutableArray *Annotations;
@property (nonatomic,strong) NSArray *RouteArray;
@property (nonatomic,strong) SBRouteDetailView*  RouteDetail;
@property (nonatomic,strong) UITableViewController*  checkPointsTable;

//for map view
@property (nonatomic, strong) MKPolyline*		routeLine;
@property (nonatomic, strong) MKPolylineView*	routeLineView;

- (IBAction)toCheckPointTable:(id)sender;

-(void)updateRoute;
-(void)loadRouteAnnotations;
-(void)showCheckpoints;

//for map view
-(void)loadRoutes:(NSArray *)inArray;

@end
