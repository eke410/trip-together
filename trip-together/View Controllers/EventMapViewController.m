//
//  EventMapViewController.m
//  trip-together
//
//  Created by Elizabeth Ke on 7/26/21.
//

#import "EventMapViewController.h"
#import <MapKit/MapKit.h>
#import "UIImageView+AFNetworking.h"

@interface EventMapViewController () <MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;

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
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
