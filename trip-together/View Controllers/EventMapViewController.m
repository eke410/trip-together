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

@interface EventMapViewController () <MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) UIAlertController *locationAlert;
@property (nonatomic) BOOL isShowingUserLocation;

@end

@implementation EventMapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // set up map region, add pin at event location
    CLLocationCoordinate2D eventCoord = CLLocationCoordinate2DMake([self.event.latitude floatValue], [self.event.longitude floatValue]);
    MKCoordinateRegion mapRegion = MKCoordinateRegionMake(eventCoord, MKCoordinateSpanMake(0.01, 0.01));
    [self.mapView setRegion:mapRegion];
    
    MKPointAnnotation *annotation = [MKPointAnnotation new];
    annotation.coordinate = eventCoord;
    annotation.title = self.event.name;
    [self.mapView addAnnotation:annotation];
    
    self.mapView.delegate = self;
    
    // set up user location
    self.locationManager = [CLLocationManager new];
    [self.locationManager requestWhenInUseAuthorization];
    self.isShowingUserLocation = false;
    
    // set up location alert
    self.locationAlert = [UIAlertController alertControllerWithTitle:@"Location not enabled" message:@"Please authorize location services for this app." preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil];
    [self.locationAlert addAction:okAction];
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
        [self presentViewController:self.locationAlert animated:YES completion:nil];
        return;
    }
    
    // location services authorized
    if ([self.locationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways || [self.locationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse) {

        if (!self.isShowingUserLocation) {
            NSArray *annotations = [self.mapView.annotations arrayByAddingObject:self.mapView.userLocation];
            [self.mapView showAnnotations:annotations animated:true];
        } else {
            CLLocationCoordinate2D eventCoord = CLLocationCoordinate2DMake([self.event.latitude floatValue], [self.event.longitude floatValue]);
            MKCoordinateRegion mapRegion = MKCoordinateRegionMake(eventCoord, MKCoordinateSpanMake(0.01, 0.01));
            [self.mapView setRegion:mapRegion animated:true];
        }
        self.isShowingUserLocation = !self.isShowingUserLocation;
    }
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
