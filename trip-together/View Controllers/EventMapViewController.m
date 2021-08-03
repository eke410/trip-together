//
//  EventMapViewController.m
//  trip-together
//
//  Created by Elizabeth Ke on 7/26/21.
//

#import "EventMapViewController.h"
#import <MapKit/MapKit.h>
#import "UIImageView+AFNetworking.h"
#import "CoreLocation/CoreLocation.h"
@import PopupDialog;

@interface EventMapViewController () <MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (nonatomic) BOOL isShowingUserLocation;

@end

@implementation EventMapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // set up map region
    CLLocationCoordinate2D eventCoord = CLLocationCoordinate2DMake([self.event.latitude floatValue], [self.event.longitude floatValue]);
    MKCoordinateRegion mapRegion = MKCoordinateRegionMake(eventCoord, MKCoordinateSpanMake(0.01, 0.01));
    [self.mapView setRegion:mapRegion];
    
    // add pin at event location
    MKPointAnnotation *annotation = [MKPointAnnotation new];
    annotation.coordinate = eventCoord;
    annotation.title = self.event.name;
    [self.mapView addAnnotation:annotation];
    
    self.mapView.delegate = self;
    
    // set up user location
    self.locationManager = [CLLocationManager new];
    [self.locationManager requestWhenInUseAuthorization];
    self.isShowingUserLocation = false;
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    if ([annotation isKindOfClass:[MKUserLocation class]]) {
        return nil;
    }
    MKPinAnnotationView *annotationView = (MKPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:@"Pin"];
    if (annotationView == nil) {
        annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"Pin"];
        annotationView.canShowCallout = true;
        annotationView.leftCalloutAccessoryView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 50.0, 50.0)];
    }

    UIImageView *imageView = (UIImageView*)annotationView.leftCalloutAccessoryView;
    [imageView setImageWithURL:[NSURL URLWithString:self.event.imageURLString]];

    return annotationView;
}

- (IBAction)tappedShowUserLocation:(id)sender {
    
    // location services not authorized
    if ([self.locationManager authorizationStatus] == kCLAuthorizationStatusDenied || [self.locationManager authorizationStatus] == kCLAuthorizationStatusRestricted) {
        PopupDialog *popup = [[PopupDialog alloc] initWithTitle:@"Location not enabled" message:@"Please authorize location services for this app." image:nil buttonAlignment:UILayoutConstraintAxisHorizontal transitionStyle:PopupDialogTransitionStyleZoomIn preferredWidth:200 tapGestureDismissal:YES panGestureDismissal:YES hideStatusBar:NO completion:nil];
        [popup addButtons:@[[[DefaultButton alloc] initWithTitle:@"Ok" height:45 dismissOnTap:YES action:nil]]];
        [self presentViewController:popup animated:YES completion:nil];
        return;
    }
    
    // location services authorized
    if ([self.locationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways || [self.locationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse) {

        if (!self.isShowingUserLocation) {
            // shows user location
            NSArray *annotations = [self.mapView.annotations arrayByAddingObject:self.mapView.userLocation];
            [self.mapView showAnnotations:annotations animated:true];
            
            // makes directions request from user location -> event
            MKDirectionsRequest *request = [MKDirectionsRequest new];
            [request setSource:[MKMapItem mapItemForCurrentLocation]];
            CLLocationCoordinate2D eventCoord = CLLocationCoordinate2DMake([self.event.latitude floatValue], [self.event.longitude floatValue]);
            [request setDestination: [[MKMapItem alloc] initWithPlacemark: [[MKPlacemark alloc] initWithCoordinate:eventCoord]]];
            [request setTransportType:MKDirectionsTransportTypeWalking];
            
            // calculates and displays directions on map
            MKDirections *directions = [[MKDirections alloc] initWithRequest:request];
            [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
                if (!error) {
                    for (MKRoute *route in [response routes]) {
                        [self.mapView addOverlay:[route polyline] level:MKOverlayLevelAboveRoads];
                    }
                }
            }];
            
        } else {
            // resets map region
            CLLocationCoordinate2D eventCoord = CLLocationCoordinate2DMake([self.event.latitude floatValue], [self.event.longitude floatValue]);
            MKCoordinateRegion mapRegion = MKCoordinateRegionMake(eventCoord, MKCoordinateSpanMake(0.01, 0.01));
            [self.mapView setRegion:mapRegion animated:true];
            
            // removes directions overlays
            [self.mapView removeOverlays: self.mapView.overlays];
        }
        self.isShowingUserLocation = !self.isShowingUserLocation;
    }
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay {
    if ([overlay isKindOfClass:[MKPolyline class]]) {
        MKPolylineRenderer *renderer = [[MKPolylineRenderer alloc] initWithOverlay:overlay];
        [renderer setStrokeColor:[UIColor blueColor]];
        [renderer setLineWidth:3.0];
        return renderer;
    }
    return nil;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
