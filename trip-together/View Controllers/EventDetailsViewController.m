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
@property (weak, nonatomic) IBOutlet UIButton *phoneButton;
@property (weak, nonatomic) IBOutlet UILabel *priceLevelLabel;
@property (weak, nonatomic) IBOutlet UILabel *reviewCountLabel;
@property (weak, nonatomic) IBOutlet TagListView *categoriesTagListView;
@property (weak, nonatomic) IBOutlet UIButton *bookEventButton;
@property (weak, nonatomic) IBOutlet ImageSlideshow *imageSlideshow;
@property (weak, nonatomic) IBOutlet UIButton *morePhotosButton;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UIButton *websiteButton;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UIView *locationContainerView;
@property (weak, nonatomic) IBOutlet UIView *infoContainerView;

@end

@implementation EventDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.event) {
        [self refreshData];
    }
    
    if (!self.allowBooking) {
        [self.bookEventButton removeFromSuperview];
    }
    
    // sets up gradient background of book event button
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.bookEventButton.bounds;
    gradient.startPoint = CGPointMake(0, 1);
    gradient.endPoint = CGPointMake(0, 0);
    gradient.cornerRadius = 16;
    gradient.colors = @[(id)[[UIColor colorWithRed:78/255.0 green:168/255.0 blue:222/255.0 alpha:1] CGColor], (id)[[UIColor colorWithRed:100/255.0 green:178/255.0 blue:227/255.0 alpha:1] CGColor]];
    [self.bookEventButton.layer insertSublayer:gradient atIndex:0];
    
    self.categoriesTagListView.textFont = [UIFont systemFontOfSize:14];
    [self.imageSlideshow setContentScaleMode:UIViewContentModeScaleAspectFill];
    self.morePhotosButton.layer.backgroundColor = [[UIColor colorWithWhite:0 alpha:0.7] CGColor];
    
    // style container view
    self.containerView.layer.cornerRadius = 20;
    self.containerView.layer.shadowOpacity = 0.3;
    self.containerView.layer.shadowRadius = 3;
    self.containerView.layer.shadowColor = [[UIColor darkGrayColor] CGColor];
    self.containerView.layer.shadowOffset = CGSizeZero;
}

- (void)refreshData {
    self.nameLabel.text = self.event.name;
    self.locationLabel.text = self.event.location;
    [self.phoneButton setTitle:[@" " stringByAppendingString:self.event.phone] forState:UIControlStateNormal];
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
    
    if ([self.event.websiteURL isEqualToString:@"not queried yet"]) {
        [self.websiteButton setHidden:true];
    } else if ([self.event.websiteURL isEqualToString:@""]) {
        [self.websiteButton removeFromSuperview];
    }
    
    // set up map region, add pin at event location
    CLLocationCoordinate2D eventCoord = CLLocationCoordinate2DMake([self.event.latitude floatValue], [self.event.longitude floatValue]);
    MKCoordinateRegion mapRegion = MKCoordinateRegionMake(eventCoord, MKCoordinateSpanMake(0.005, 0.005));
    [self.mapView setRegion:mapRegion];
    
    MKPointAnnotation *annotation = [MKPointAnnotation new];
    annotation.coordinate = eventCoord;
    [self.mapView addAnnotation:annotation];
    
    if ([self.event.phone isEqualToString:@""]) {
        [self.phoneButton removeFromSuperview];
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
            } else {
                [self.websiteButton removeFromSuperview];
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

- (IBAction)tappedLocationButton:(id)sender {
    [self.locationContainerView setHidden:!self.locationContainerView.hidden];
}

- (IBAction)tappedInfoButton:(id)sender {
    [self.infoContainerView setHidden:!self.infoContainerView.hidden];
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

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.locationContainerView setHidden:true];
    [self.infoContainerView setHidden:true];
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
