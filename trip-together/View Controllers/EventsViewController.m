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

@interface EventsViewController () <GMSAutocompleteTableDataSourceDelegate, UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITextField *searchField;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITableView *eventsTableView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (weak, nonatomic) IBOutlet UIButton *sortButton;
@property (weak, nonatomic) IBOutlet UILabel *sortByLabel;
@property (weak, nonatomic) IBOutlet UILabel *whereToLabel;
@property (nonatomic, strong) NSMutableArray *attractions;
@property (nonatomic, strong) NSMutableArray *restaurants;
@property (nonatomic) CGPoint attractionsPosition;
@property (nonatomic) CGPoint restaurantsPosition;
@property (strong, nonatomic) NSString *location;
@property (nonatomic) BOOL isLoadingData;
@property (nonatomic) BOOL noMoreAttractionData;
@property (nonatomic) BOOL noMoreRestaurantData;
@property (nonatomic, strong) DropDown *dropDown;
@property (nonatomic) BOOL isTypingFirstLocation;

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
    self.searchField.delegate = self;
    [self.tableView setHidden:true];
    
    // style autocomplete table view
    [tableDataSource setTableCellBackgroundColor:[UIColor colorWithWhite:0.96 alpha:1]];
    
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
    NSArray *dropDownLabels = @[@"recommended", @"review count", @"weighted rating", @"distance"];
    self.dropDown.cellConfiguration = ^NSString * _Nonnull(NSInteger index, NSString * _Nonnull item) {
        return dropDownLabels[index];
    };
    [self.dropDown selectRow:0 scrollPosition:UITableViewScrollPositionTop];
    [self.sortButton setTranslatesAutoresizingMaskIntoConstraints:true];
    self.sortButton.frame = CGRectMake(self.sortButton.frame.origin.x, self.sortByLabel.frame.origin.y+2, self.sortButton.intrinsicContentSize.width+16, self.sortButton.frame.size.height);
    
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
        UIButton *sortButton = strongSelf.sortButton;
        [sortButton setTitle:dropDownLabels[index] forState:UIControlStateNormal];
        sortButton.frame = CGRectMake(sortButton.frame.origin.x, sortButton.frame.origin.y, sortButton.intrinsicContentSize.width+16, sortButton.frame.size.height);
    };
    [DropDown startListeningToKeyboard];
    
    // styling dropDown menu
    self.dropDown.textFont = [UIFont systemFontOfSize:13];
    self.dropDown.cellHeight = 32;
    self.dropDown.cornerRadius = 10;
    
    // set up search field padding
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, self.searchField.frame.size.height)];
    self.searchField.leftView = paddingView;
    self.searchField.leftViewMode = UITextFieldViewModeAlways;
    
    // set up start animation
    self.isTypingFirstLocation = false;
    self.searchField.translatesAutoresizingMaskIntoConstraints = YES;
    self.searchField.frame = CGRectMake(8, self.self.view.frame.size.height/2-30, self.view.frame.size.width-16, 45);
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
        if (error) {
            NSLog(@"Error querying from Yelp: %@", error.localizedDescription);
            return;
        }
        if ([term isEqualToString:@"top+tourist+attractions"]) { // store attractions data
            [self.attractions addObjectsFromArray:[Event eventsWithArray:dataArray withType:@"attraction"]];
            self.noMoreAttractionData = dataArray.count < 20;
        } else { // store restaurants data
            [self.restaurants addObjectsFromArray:[Event eventsWithArray:dataArray withType:@"restaurant"]];
            self.noMoreRestaurantData = dataArray.count < 20;
        }
        [self.eventsTableView reloadData];
        if ([offset isEqualToString:@"0"]) { // scroll to top if querying data from new location
            if ((self.segmentedControl.selectedSegmentIndex == 0 && self.attractions.count > 0) || (self.segmentedControl.selectedSegmentIndex == 1 && self.restaurants.count > 0)) {
                [self.eventsTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:true];
            }
        }
        self.isLoadingData = false;
    }];
}

- (IBAction)tappedSortButton:(id)sender {
    [self.dropDown show];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.searchField endEditing:true];
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
    [self.searchField endEditing:true];
    self.searchField.text = place.formattedAddress;
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

#pragma mark - Search Field

- (IBAction)searchTextChanged:(id)sender {
    if ([self.searchField.text isEqualToString:@""]) {
        [self.tableView setHidden:true];
    } else {
        if (self.searchField.frame.origin.y == self.view.frame.size.height/2-30) { // first time searching location -> animate
            self.isTypingFirstLocation = true;
            [UIView animateWithDuration:0.5 animations:^{
                self.searchField.frame = CGRectMake(8, self.sortButton.frame.origin.y-47, self.view.frame.size.width-16, 40);
                [self.whereToLabel setHidden:true];
            } completion:^(BOOL finished) {
                [self.tableView setHidden:false];
                [self.segmentedControl setHidden:false];
                [self.sortButton setHidden:false];
                [self.sortByLabel setHidden:false];
                self.isTypingFirstLocation = false;
            }];
        } else if (!self.isTypingFirstLocation) {
            [self.tableView setHidden:false];
        }
    }
    // Update the GMSAutocompleteTableDataSource with the search text.
    [tableDataSource sourceTextHasChanged:self.searchField.text];
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
