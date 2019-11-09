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

@interface NavigationMapViewController : UIViewController<UICGDirectionsDelegate,UIWebViewDelegate,UITableViewDelegate,UITableViewDataSource,MKMapViewDelegate,UIActionSheetDelegate>


@property (weak, nonatomic) IBOutlet MKMapView *map;
@property (nonatomic,strong) UICGDirections* Directions;
@property (nonatomic,strong) CLLocation* startLocation;
@property (nonatomic,strong) CLLocation* endLocation;
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

//tool bar button

@property (weak, nonatomic) IBOutlet UIToolbar *toolBar;
@property (strong, nonatomic) MKUserTrackingBarButtonItem *userTracking;
@property (strong, nonatomic) UIBarButtonItem *toTargetLocation;
@property (strong, nonatomic) UIBarButtonItem *showRouteAnnotations;
@property (strong, nonatomic) UIBarButtonItem *toCheckPointTable;
@property (strong, nonatomic) UIBarButtonItem *openMapApp;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;


//for map view
@property (nonatomic, strong) MKPolyline*		routeLine;
@property (nonatomic, strong) MKPolylineView*	routeLineView;


-(void)updateRoute;
-(void)loadRouteAnnotations;
-(IBAction)showCheckpoints;

//for map view
-(void)loadRoutes:(NSArray *)inArray;

@end
