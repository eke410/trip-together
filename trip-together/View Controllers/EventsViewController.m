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
@property (nonatomic, strong) NSMutableArray *events;

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
               self.events = [Event eventsWithArray:dataDictionary[@"events"]];
               [self.eventsTableView reloadData];
           }
       }];
    [task resume];
}

- (void)queryEventsWithParams:(NSDictionary *)params {
    // make string for request params
    NSString *paramString = @"?";
    for (NSString *key in params) {
        NSString *newParamString = [NSString stringWithFormat:@"%@=%@&", key, [params objectForKey:key]];
        paramString = [paramString stringByAppendingString:newParamString];
    }
    paramString = [paramString substringToIndex:[paramString length]-1];
    
    // add param string to yelp event query string
    NSString *URLString = [@"https://api.yelp.com/v3/events" stringByAppendingString:paramString];
    [self queryEventsWithURLString:URLString];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.events.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    EventCell *cell = [self.eventsTableView dequeueReusableCellWithIdentifier:@"EventCell"];
    cell.event = self.events[indexPath.row];
    [cell refreshData];
    return cell;
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
    NSArray *values = [[NSArray alloc] initWithObjects:location, @"5", nil];
    NSDictionary *params = [[NSDictionary alloc] initWithObjects:values forKeys:keys];
    [self queryEventsWithParams:params];
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
    Event *event = self.events[indexPath.row];
    eventDetailsViewController.event = event;
}


@end
