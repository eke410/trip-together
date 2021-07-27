//
//  EventDetailsViewController.m
//  trip-together
//
//  Created by Elizabeth Ke on 7/12/21.
//

#import "EventDetailsViewController.h"
#import "UIImageView+AFNetworking.h"
#import "BookEventViewController.h"
#import "TagListView-Swift.h"
#import "ImageSlideshow-Swift.h"
#import "APIManager.h"
#import <MapKit/MapKit.h>
#import "EventMapViewController.h"

@interface EventDetailsViewController ()

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet UIImageView *ratingImageView;
@property (weak, nonatomic) IBOutlet UILabel *phoneLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLevelLabel;
@property (weak, nonatomic) IBOutlet UILabel *reviewCountLabel;
@property (weak, nonatomic) IBOutlet TagListView *categoriesTagListView;
@property (weak, nonatomic) IBOutlet UIButton *bookEventButton;
@property (weak, nonatomic) IBOutlet ImageSlideshow *imageSlideshow;
@property (weak, nonatomic) IBOutlet UIButton *morePhotosButton;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UIButton *websiteButton;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UIImageView *phoneIcon;

@end

@implementation EventDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.event) {
        [self refreshData];
    }
    
    if (!self.allowBooking) {
        [self.bookEventButton setHidden:true];
    }
    
    self.categoriesTagListView.textFont = [UIFont systemFontOfSize:14];
    [self.imageSlideshow setContentScaleMode:UIViewContentModeScaleAspectFill];
    self.morePhotosButton.layer.backgroundColor = [[UIColor colorWithWhite:0 alpha:0.7] CGColor];
}

- (void)refreshData {
    self.nameLabel.text = self.event.name;
    self.locationLabel.text = self.event.location;
    self.phoneLabel.text = self.event.phone;
    self.priceLevelLabel.text = self.event.priceLevel;
    self.reviewCountLabel.text = [NSString stringWithFormat:@"(%@)", self.event.reviewCount];
    
    for (NSDictionary *category in self.event.categories) {
        [self.categoriesTagListView addTag:category[@"title"]];
    }
    
    UIImage *ratingImage = [UIImage imageNamed:[self.event.rating stringByAppendingString:@"_star"]];
    [self.ratingImageView setImage:ratingImage];
    
    [self refreshPhotos];
    
    if ([self.event.placeDescription isEqualToString:@"not queried yet"]) {
        self.descriptionLabel.text = @"";
//        [self queryDetails];
    } else {
        self.descriptionLabel.text = self.event.placeDescription;
    }
    
    if (![self.event.websiteURL isEqualToString:@""]) {
        [self.websiteButton setHidden:false];
    }
    
    // set up map region, add pin at event location
    CLLocationCoordinate2D eventCoord = CLLocationCoordinate2DMake([self.event.latitude floatValue], [self.event.longitude floatValue]);
    MKCoordinateRegion mapRegion = MKCoordinateRegionMake(eventCoord, MKCoordinateSpanMake(0.005, 0.005));
    [self.mapView setRegion:mapRegion];
    
    MKPointAnnotation *annotation = [MKPointAnnotation new];
    annotation.coordinate = eventCoord;
    [self.mapView addAnnotation:annotation];
    
    if ([self.event.phone isEqualToString:@""]) {
        [self.phoneIcon setHidden:true];
    }
}

- (void)refreshPhotos {
    // displays either photo slideshow or singular photo
    if (self.event.photoURLStrings) {
        NSMutableArray *imageInputs = [NSMutableArray new];
        for (NSString *imageURLString in self.event.photoURLStrings) {
            NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageURLString]];
            UIImage *image = [[UIImage alloc] initWithData:imageData];
            [imageInputs addObject:[[ImageSource alloc] initWithImage:image]];
        }
        [self.imageSlideshow setImageInputs: imageInputs];
        [self.morePhotosButton setHidden:true];
    } else {
        NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:self.event.imageURLString]];
        UIImage *image = [[UIImage alloc] initWithData:imageData];
        ImageSource *imageSource = [[ImageSource alloc] initWithImage:image];
        [self.imageSlideshow setImageInputs: @[imageSource]];
    }
}

- (void)queryDetails {
    // query event details from Foursquare API, store description and website URL
    NSDictionary *params = @{
        @"ll": [NSString stringWithFormat:@"%@,%@", self.event.latitude, self.event.longitude],
        @"query": [self.event.name stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]],
        @"radius": @"200",
        @"limit": @"1",
    };
    [APIManager queryFoursquareDetailsWithParams:params withCompletion:^(NSDictionary * _Nonnull details, NSError * _Nonnull error) {
        if (details) {
            self.event.placeDescription = details[@"description"];
            self.event.websiteURL = details[@"websiteURL"];
            
            [UIView animateWithDuration:0.5 animations:^{
                self.descriptionLabel.alpha = 0.0f;
                self.descriptionLabel.text = self.event.placeDescription;
                self.descriptionLabel.alpha = 1.0f;
            }];
            
            if (![self.event.websiteURL isEqualToString:@""]) {
                [UIView animateWithDuration:0.5 animations:^{
                    self.websiteButton.alpha = 0.0f;
                    [self.websiteButton setHidden:false];
                    self.websiteButton.alpha = 1.0f;
                }];
            }
        } else {
            NSLog(@"Error getting event details from Foursquare: %@", error.localizedDescription);
        }
    }];
}

- (IBAction)tappedPhoneNumber:(id)sender {
    NSString *cleanedPhoneNumber = [[self.event.phone componentsSeparatedByCharactersInSet:[[NSCharacterSet characterSetWithCharactersInString:@"0123456789"] invertedSet]] componentsJoinedByString:@""];
    NSURL *phoneNumber = [NSURL URLWithString:[NSString stringWithFormat:@"telprompt:%@", cleanedPhoneNumber]];
    [[UIApplication sharedApplication] openURL:phoneNumber options:@{} completionHandler:nil];
}

- (IBAction)tappedMapButton:(id)sender {
    [UIView transitionWithView:self.mapView duration:0.3 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        [self.mapView setHidden:!self.mapView.hidden];
    } completion:nil];
}

- (IBAction)tappedYelpURLButton:(id)sender {
    NSURL *url = [NSURL URLWithString:self.event.yelpURL];
    [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
}

- (IBAction)tappedWebsiteButton:(id)sender {
    NSURL *url = [NSURL URLWithString:self.event.websiteURL];
    [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
}

- (IBAction)tappedImageSlideshow:(id)sender {
    [self.imageSlideshow presentFullScreenControllerFrom:self completion:nil];
}

- (IBAction)tappedMorePhotosButton:(id)sender {
    [APIManager queryYelpPhotosForID:self.event.yelpID withCompletion:^(NSArray * _Nonnull photoURLStrings, NSError * _Nonnull error) {
        if (!error) {
            self.event.photoURLStrings = photoURLStrings;
            [self refreshPhotos];
            [self.imageSlideshow presentFullScreenControllerFrom:self completion:nil];
            
            // if this is a booked event that was viewed from the itinerary, save the photos to Parse
            if (self.event.group) {
                [self.event saveInBackground];
            }
        } else {
            NSLog(@"Error querying photos from Yelp: %@", error.localizedDescription);
        }
    }];
}

- (IBAction)tappedMapView:(id)sender {
    [self performSegueWithIdentifier:@"mapSegue" sender:nil];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"bookEventSegue"]) {
        BookEventViewController *bookEventViewController = [segue destinationViewController];
        bookEventViewController.event = self.event;
    } else if ([segue.identifier isEqualToString:@"mapSegue"]) {
        EventMapViewController *eventMapViewController = [segue destinationViewController];
        eventMapViewController.event = self.event;
    }

}


@end
