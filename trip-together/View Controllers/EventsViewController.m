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
    
    // queries attractions with selected location
    NSMutableDictionary *params = [@{
        @"location": [place.formattedAddress stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]],
        @"limit": @"20",
        @"term": @"top+tourist+attractions",
    } mutableCopy];
    [APIManager queryYelpEventsWithParams:params withCompletion:^(NSArray * _Nonnull dataArray, NSError * _Nonnull error) {
        if (!error) {
            self.attractions = [Event eventsWithArray:dataArray withType:@"attraction"];
            [self.eventsTableView reloadData];
            if (self.segmentedControl.selectedSegmentIndex == 0 && self.attractions.count > 0) {
                [self.eventsTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:true];
            }
        } else {
            NSLog(@"Error querying attractions from Yelp: %@", error.localizedDescription);
        }
    }];
    
    // queries restaurants with selected location
    params[@"term"] = @"restaurants";
    [APIManager queryYelpEventsWithParams:params withCompletion:^(NSArray * _Nonnull dataArray, NSError * _Nonnull error) {
        if (!error) {
            self.restaurants = [Event eventsWithArray:dataArray withType:@"restaurant"];
            [self.eventsTableView reloadData];
            if (self.segmentedControl.selectedSegmentIndex == 1 && self.restaurants.count > 0) {
                [self.eventsTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:true];
            }
        } else {
            NSLog(@"Error querying restaurants from Yelp: %@", error.localizedDescription);
        }
    }];
    
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
