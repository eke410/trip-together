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

- (void)queryEventPhotos {
    NSString *URLString = [NSString stringWithFormat:@"https://api.yelp.com/v3/businesses/%@", self.event.yelpID];

    // get API Key from Keys.plist
    NSString *path = [[NSBundle mainBundle] pathForResource: @"Keys" ofType: @"plist"];
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile: path];
    NSString *APIKey= [dict objectForKey: @"yelpAPIKey"];

    // set request URL and authentication value
    NSURL *url = [NSURL URLWithString:URLString];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    NSString *authValue = [NSString stringWithFormat:@"Bearer %@", APIKey];
    [request setValue:authValue forHTTPHeaderField:@"Authorization"];

    // make request
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error != nil) {
            NSLog(@"%@", [error localizedDescription]);
        }
        else {
            NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            self.event.photoURLStrings = dataDictionary[@"photos"];
            [self refreshPhotos];
            [self.imageSlideshow presentFullScreenControllerFrom:self completion:nil];
            
            // if this is a booked event that was viewed from the itinerary, save the photos to Parse
            if (self.event.group) {
                [self.event saveInBackground];
            }
        }
    }];
    [task resume];
}

- (IBAction)tappedYelpURLButton:(id)sender {
    NSURL *url = [NSURL URLWithString:self.event.yelpURL];
    [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
}

- (IBAction)tappedImageSlideshow:(id)sender {
    [self.imageSlideshow presentFullScreenControllerFrom:self completion:nil];
}

- (IBAction)tappedMorePhotosButton:(id)sender {
    [self queryEventPhotos];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    BookEventViewController *bookEventViewController = [segue destinationViewController];
    bookEventViewController.event = self.event;
}


@end
