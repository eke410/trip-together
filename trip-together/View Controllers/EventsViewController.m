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
#import "APIManager.h"
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
@property (strong, nonatomic) NSString *location;
@property (nonatomic) BOOL isLoadingData;
@property (nonatomic) BOOL noMoreAttractionData;
@property (nonatomic) BOOL noMoreRestaurantData;

@end

@implementation EventsViewController {
    GMSAutocompleteTableDataSource *tableDataSource;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.attractions = [NSMutableArray new];
    self.restaurants = [NSMutableArray new];
    
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
    
    self.isLoadingData = false;
    self.noMoreAttractionData = false;
    self.noMoreRestaurantData = false;
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
    self.isLoadingData = true;
    [self.eventsTableView reloadData];
    [self.eventsTableView layoutIfNeeded];
    [self.eventsTableView setContentOffset:(self.segmentedControl.selectedSegmentIndex == 0 ? self.attractionsPosition : self.restaurantsPosition) animated:NO];
    self.isLoadingData = false;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.isLoadingData) {
        return;
    }
    
    // load more data if nearing bottom of tableView
    if (self.segmentedControl.selectedSegmentIndex == 0) { // displaying attractions
        if (!self.noMoreAttractionData && indexPath.row + 3 == self.attractions.count) {
            NSString *offset = [NSString stringWithFormat:@"%i", (int)self.attractions.count];
            [self queryYelpWithLocation:self.location offset:offset term:@"top+tourist+attractions"];
        }
    } else { // displaying restaurants
        if (!self.noMoreRestaurantData && indexPath.row + 3 == self.restaurants.count) {
            NSString *offset = [NSString stringWithFormat:@"%i", (int)self.restaurants.count];
            [self queryYelpWithLocation:self.location offset:offset term:@"restaurants"];
        }
    }
}

- (void)queryYelpWithLocation:(NSString *)location offset:(NSString *)offset term:(NSString *)term {
    // calls APIManager's query Yelp method and stores results
        self.isLoadingData = true;
    NSDictionary *params = @{
        @"location": location,
        @"offset": offset,
        @"term": term,
        @"limit": @"20",
    };
    [APIManager queryYelpEventsWithParams:params withCompletion:^(NSArray * _Nonnull dataArray, NSError * _Nonnull error) {
        if (!error) {
            if ([term isEqualToString:@"top+tourist+attractions"]) { // store attractions data
                [self.attractions addObjectsFromArray:[Event eventsWithArray:dataArray withType:@"attraction"]];
                if (dataArray.count < 20) {
                    self.noMoreAttractionData = true;
                }
            } else { // store restaurants data
                [self.restaurants addObjectsFromArray:[Event eventsWithArray:dataArray withType:@"restaurant"]];
                if (dataArray.count < 20) {
                    self.noMoreRestaurantData = true;
                }
            }
            [self.eventsTableView reloadData];
            if ([offset isEqualToString:@"0"]) { // scroll to top if querying data from new location
                if ((self.segmentedControl.selectedSegmentIndex == 0 && self.attractions.count > 0) || (self.segmentedControl.selectedSegmentIndex == 1 && self.restaurants.count > 0)) {
                    [self.eventsTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:true];
                }
            }
            self.isLoadingData = false;
        } else {
            NSLog(@"Error querying from Yelp: %@", error.localizedDescription);
        }
    }];
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
    
    // clears current data
    [self.attractions removeAllObjects];
    [self.restaurants removeAllObjects];
    self.noMoreAttractionData = false;
    self.noMoreRestaurantData = false;
    
    // queries attractions and restaurants with selected location
    NSString *location = [place.formattedAddress stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    self.location = location;
    [self queryYelpWithLocation:location offset:@"0" term:@"top+tourist+attractions"];
    [self queryYelpWithLocation:location offset:@"0" term:@"restaurants"];
    
    // resets tableview scroll positions 
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
