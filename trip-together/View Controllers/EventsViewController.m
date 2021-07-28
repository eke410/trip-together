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
#import "DropDown-Swift.h"
@import GooglePlaces;

@interface EventsViewController () <GMSAutocompleteTableDataSourceDelegate, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITableView *eventsTableView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (weak, nonatomic) IBOutlet UIButton *sortButton;
@property (nonatomic, strong) NSMutableArray *attractions;
@property (nonatomic, strong) NSMutableArray *restaurants;
@property (nonatomic) CGPoint attractionsPosition;
@property (nonatomic) CGPoint restaurantsPosition;
@property (strong, nonatomic) NSString *location;
@property (nonatomic) BOOL isLoadingData;
@property (nonatomic) BOOL noMoreAttractionData;
@property (nonatomic) BOOL noMoreRestaurantData;
@property (nonatomic, strong) DropDown *dropDown;

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
    
    // set up sorting dropDown menu
    self.dropDown = [DropDown new];
    self.dropDown.anchorView = self.sortButton;
    self.dropDown.bottomOffset = CGPointMake(-4, self.dropDown.anchorView.plainView.bounds.size.height + 6);
    self.dropDown.dataSource = @[@"best_match", @"review_count", @"rating", @"distance"];
    NSArray *dropDownLabels = @[@"recommended", @"review count", @"overall rating", @"distance"];
    self.dropDown.cellConfiguration = ^NSString * _Nonnull(NSInteger index, NSString * _Nonnull item) {
        return dropDownLabels[index];
    };
    [self.dropDown selectRow:0 scrollPosition:UITableViewScrollPositionTop];
    __weak EventsViewController *weakSelf = self;
    self.dropDown.selectionAction = ^(NSInteger index, NSString * _Nonnull item) {
        __strong EventsViewController *strongSelf = weakSelf;
        if (strongSelf && strongSelf.location) {
            // clears current data
            [strongSelf.attractions removeAllObjects];
            [strongSelf.restaurants removeAllObjects];
            strongSelf.noMoreAttractionData = false;
            strongSelf.noMoreRestaurantData = false;
            // sets new data
            [strongSelf queryYelpWithLocation:strongSelf.location offset:@"0" term:@"top+tourist+attractions" sortBy:item];
            [strongSelf queryYelpWithLocation:strongSelf.location offset:@"0" term:@"restaurants" sortBy:item];
            // resets tableview scroll positions
            strongSelf.attractionsPosition = CGPointMake(0, 0);
            strongSelf.restaurantsPosition = CGPointMake(0, 0);
        }
        [strongSelf.sortButton setTitle:[@" " stringByAppendingString:dropDownLabels[index]] forState:UIControlStateNormal];
        [strongSelf.sortButton.titleLabel setFont:[UIFont systemFontOfSize:13]];
    };
    [DropDown startListeningToKeyboard];
    
    // styling dropDown menu
    self.dropDown.textFont = [UIFont systemFontOfSize:13];
    self.dropDown.cellHeight = 32;
    self.dropDown.cornerRadius = 10;
    
    self.location = @"Cambridge,%20MA,%20USA";
    [self queryYelpWithLocation:@"Cambridge,%20MA,%20USA" offset:@"0" term:@"top+tourist+attractions" sortBy:@"best_match"];
    [self queryYelpWithLocation:@"Cambridge,%20MA,%20USA" offset:@"0" term:@"restaurants" sortBy:@"best_match"];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.segmentedControl.selectedSegmentIndex == 0 ? self.attractions.count : self.restaurants.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    EventCell *cell = [self.eventsTableView dequeueReusableCellWithIdentifier:@"EventCell"];
    cell.event = self.segmentedControl.selectedSegmentIndex == 0 ? self.attractions[indexPath.section] : self.restaurants[indexPath.section];
    [cell refreshData];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 8;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = [[UIView alloc] init];
    headerView.backgroundColor = self.view.backgroundColor;
    return headerView;
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
        if (!self.noMoreAttractionData && indexPath.section + 3 == self.attractions.count) {
            NSString *offset = [NSString stringWithFormat:@"%i", (int)self.attractions.count];
            [self queryYelpWithLocation:self.location offset:offset term:@"top+tourist+attractions" sortBy:self.dropDown.selectedItem];
        }
    } else { // displaying restaurants
        if (!self.noMoreRestaurantData && indexPath.section + 3 == self.restaurants.count) {
            NSString *offset = [NSString stringWithFormat:@"%i", (int)self.restaurants.count];
            [self queryYelpWithLocation:self.location offset:offset term:@"restaurants" sortBy:self.dropDown.selectedItem];
        }
    }
}

- (void)queryYelpWithLocation:(NSString *)location offset:(NSString *)offset term:(NSString *)term sortBy:(NSString *)sortBy {
    // calls APIManager's query Yelp method and stores results
    self.isLoadingData = true;
    NSDictionary *params = @{
        @"location": location,
        @"offset": offset,
        @"term": term,
        @"sort_by": sortBy,
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

- (IBAction)tappedSortButton:(id)sender {
    [self.dropDown show];
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
    if (!self.dropDown.selectedItem) {
        [self.dropDown selectRow:0 scrollPosition:UITableViewScrollPositionTop];
    }
    [self queryYelpWithLocation:location offset:@"0" term:@"top+tourist+attractions" sortBy:self.dropDown.selectedItem];
    [self queryYelpWithLocation:location offset:@"0" term:@"restaurants" sortBy:self.dropDown.selectedItem];
    
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
    Event *event = self.segmentedControl.selectedSegmentIndex == 0 ? self.attractions[indexPath.section] : self.restaurants[indexPath.section];
    eventDetailsViewController.event = event;
    [eventDetailsViewController setAllowBooking:true];
}


@end
