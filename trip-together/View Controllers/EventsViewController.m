//
//  EventsViewController.m
//  trip-together
//
//  Created by Elizabeth Ke on 7/12/21.
//

#import "EventsViewController.h"
#import "Event.h"
#import "EventCell.h"
#import "EventDetailsViewController.h"
@import GooglePlaces;

@interface EventsViewController () <GMSAutocompleteTableDataSourceDelegate, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITableView *eventsTableView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (nonatomic, strong) NSMutableArray *attractions;
@property (nonatomic, strong) NSMutableArray *restaurants;
@property (nonatomic) CGPoint attractionsPosition;
@property (nonatomic) CGPoint restaurantsPosition;

@end

@implementation EventsViewController {
    GMSAutocompleteTableDataSource *tableDataSource;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // filters only geocoding results (only locations) in autocomplete
    GMSAutocompleteFilter *filter = [[GMSAutocompleteFilter alloc] init];
    filter.type = kGMSPlacesAutocompleteTypeFilterGeocode;
    
    // sets up location autocomplete tableview and search bar
    tableDataSource = [[GMSAutocompleteTableDataSource alloc] init];
    tableDataSource.delegate = self;
    tableDataSource.autocompleteFilter = filter;
    
    self.tableView.delegate = tableDataSource;
    self.tableView.dataSource = tableDataSource;
    self.searchBar.delegate = self;
    [self.tableView setHidden:true];
    
    self.eventsTableView.dataSource = self;
    self.eventsTableView.delegate = self;
    
    [self.segmentedControl addTarget:self action:@selector(changeType) forControlEvents:UIControlEventValueChanged];
    self.attractionsPosition = CGPointMake(0, 0);
    self.restaurantsPosition = CGPointMake(0, 0);
    
    [self queryEventsWithURLString:@"https://api.yelp.com/v3/businesses/search?limit=20&location=Manhattan,+NY,+USA&term=top+tourist+attractions"];
    [self queryEventsWithURLString:@"https://api.yelp.com/v3/businesses/search?limit=20&location=Manhattan,+NY,+USA&term=restaurants"];
}

- (void)queryEventsWithURLString:(NSString *)URLString {
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
               if ([URLString containsString:@"top+tourist+attractions"]) {
                   self.attractions = [Event eventsWithArray:dataDictionary[@"businesses"]];
               } else {
                   self.restaurants = [Event eventsWithArray:dataDictionary[@"businesses"]];
               }
               [self.eventsTableView reloadData];
               if ((self.segmentedControl.selectedSegmentIndex == 0 && self.attractions.count > 0) || (self.segmentedControl.selectedSegmentIndex == 1 && self.restaurants.count > 0)) {
                   [self.eventsTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:true];
               }
           }
       }];
    [task resume];
}

- (void)queryEventsWithParams:(NSDictionary *)params {
    // make string for request params
    NSString *paramString = @"&";
    for (NSString *key in params) {
        NSString *newParamString = [NSString stringWithFormat:@"%@=%@&", key, [params objectForKey:key]];
        paramString = [paramString stringByAppendingString:newParamString];
    }
    paramString = [paramString substringToIndex:[paramString length]-1];
    
    // add param string to yelp event query strings
    [self queryEventsWithURLString:[@"https://api.yelp.com/v3/businesses/search?term=top+tourist+attractions" stringByAppendingString:paramString]];
    [self queryEventsWithURLString:[@"https://api.yelp.com/v3/businesses/search?term=restaurants" stringByAppendingString:paramString]];

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.segmentedControl.selectedSegmentIndex == 0 ? self.attractions.count : self.restaurants.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    EventCell *cell = [self.eventsTableView dequeueReusableCellWithIdentifier:@"EventCell"];
    cell.event = self.segmentedControl.selectedSegmentIndex == 0 ? self.attractions[indexPath.row] : self.restaurants[indexPath.row];
    [cell refreshData];
    return cell;
}

- (void)changeType{
    // segmented control was clicked
    if (self.segmentedControl.selectedSegmentIndex == 0) { // switched from restaurants -> attractions
        self.restaurantsPosition = self.eventsTableView.contentOffset;
    } else { // switched from attractions -> restaurants
        self.attractionsPosition = self.eventsTableView.contentOffset;
    }
    [self.eventsTableView reloadData];
    [self.eventsTableView layoutIfNeeded];
    [self.eventsTableView setContentOffset:(self.segmentedControl.selectedSegmentIndex == 0 ? self.attractionsPosition : self.restaurantsPosition) animated:NO];
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

#pragma mark - GMSAutocompleteTableDataSourceDelegate

- (void)didUpdateAutocompletePredictionsForTableDataSource:(GMSAutocompleteTableDataSource *)tableDataSource {
    [self.tableView reloadData];
}

- (void)didRequestAutocompletePredictionsForTableDataSource:(GMSAutocompleteTableDataSource *)tableDataSource {
    [self.tableView reloadData];
}

- (void)tableDataSource:(GMSAutocompleteTableDataSource *)tableDataSource didAutocompleteWithPlace:(GMSPlace *)place {
    // updates UI view
    [self.searchBar endEditing:true];
    self.searchBar.text = place.formattedAddress;
    [self.tableView setHidden:true];
    
    // queries events with selected location
    NSString *location = [place.formattedAddress stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    NSArray *keys = [[NSArray alloc] initWithObjects:@"location", @"limit", nil];
    NSArray *values = [[NSArray alloc] initWithObjects:location, @"20", nil];
    NSDictionary *params = [[NSDictionary alloc] initWithObjects:values forKeys:keys];
    [self queryEventsWithParams:params];
    
    self.attractionsPosition = CGPointMake(0, 0);
    self.restaurantsPosition = CGPointMake(0, 0);
}

- (void)tableDataSource:(GMSAutocompleteTableDataSource *)tableDataSource didFailAutocompleteWithError:(NSError *)error {
    NSLog(@"Error %@", error.description);
}

- (BOOL)tableDataSource:(GMSAutocompleteTableDataSource *)tableDataSource didSelectPrediction:(GMSAutocompletePrediction *)prediction {
    return YES;
}

#pragma mark - UISearchBarDelegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if ([searchText isEqualToString:@""]) {
        [self.tableView setHidden:true];
    } else {
        [self.tableView setHidden:false];
    }
    // Update the GMSAutocompleteTableDataSource with the search text.
    [tableDataSource sourceTextHasChanged:searchText];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    EventDetailsViewController *eventDetailsViewController = [segue destinationViewController];
    NSIndexPath *indexPath = [self.eventsTableView indexPathForCell:sender];
    Event *event = self.segmentedControl.selectedSegmentIndex == 0 ? self.attractions[indexPath.row] : self.restaurants[indexPath.row];
    eventDetailsViewController.event = event;
    [eventDetailsViewController setAllowBooking:true];
}


@end
