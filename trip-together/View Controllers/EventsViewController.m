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
#import "UIScrollView+EmptyDataSet.h"
#import "LUNSegmentedControl.h"
@import GooglePlaces;

@interface EventsViewController () <GMSAutocompleteTableDataSourceDelegate, UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate, LUNSegmentedControlDataSource, LUNSegmentedControlDelegate>

@property (weak, nonatomic) IBOutlet UITextField *searchField;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITableView *eventsTableView;
@property (weak, nonatomic) IBOutlet LUNSegmentedControl *segmentedControl;
@property (weak, nonatomic) IBOutlet UIButton *sortButton;
@property (weak, nonatomic) IBOutlet UILabel *sortByLabel;
@property (weak, nonatomic) IBOutlet UILabel *whereToLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) NSMutableArray *attractions;
@property (nonatomic, strong) NSMutableArray *restaurants;
@property (nonatomic) CGPoint attractionsPosition;
@property (nonatomic) CGPoint restaurantsPosition;
@property (strong, nonatomic) NSString *location;
@property (nonatomic) BOOL isLoadingData;
@property (nonatomic) BOOL isSwitchingType;
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
    self.eventsTableView.emptyDataSetSource = self;
    self.eventsTableView.emptyDataSetDelegate = self;
    
    // sets up and customizes segmented control
    self.segmentedControl.dataSource = self;
    self.segmentedControl.delegate = self;
    self.segmentedControl.backgroundColor = [UIColor systemGray6Color];
    self.segmentedControl.selectorViewColor = self.sortButton.backgroundColor;
    self.segmentedControl.shadowsEnabled = false;
    
    self.attractionsPosition = CGPointMake(0, 0);
    self.restaurantsPosition = CGPointMake(0, 0);
    
    self.isLoadingData = false;
    self.isSwitchingType = false;
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
    return self.segmentedControl.currentState == 0 ? self.attractions.count : self.restaurants.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    EventCell *cell = [self.eventsTableView dequeueReusableCellWithIdentifier:@"EventCell"];
    cell.event = self.segmentedControl.currentState == 0 ? self.attractions[indexPath.section] : self.restaurants[indexPath.section];
    [cell refreshData];
    return cell;
}

- (void)segmentedControl:(LUNSegmentedControl *)segmentedControl didChangeStateFromStateAtIndex:(NSInteger)fromIndex toStateAtIndex:(NSInteger)toIndex {
    // segmented control was clicked
    if (self.segmentedControl.currentState == 0) { // switched from restaurants -> attractions
        self.restaurantsPosition = self.eventsTableView.contentOffset;
    } else { // switched from attractions -> restaurants
        self.attractionsPosition = self.eventsTableView.contentOffset;
    }
    self.isSwitchingType = true;
    [self.eventsTableView reloadData];
    [self.eventsTableView layoutIfNeeded];
    [self.eventsTableView setContentOffset:(self.segmentedControl.currentState == 0 ? self.attractionsPosition : self.restaurantsPosition) animated:NO];
    self.isSwitchingType = false;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.isLoadingData || self.isSwitchingType) {
        return;
    }
    
    // load more data if nearing bottom of tableView
    if (self.segmentedControl.currentState == 0) { // displaying attractions
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
    if ([offset isEqualToString:@"0"]) { // querying new location
        [self.activityIndicator startAnimating];
        [self.eventsTableView setHidden:true];
    }
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
            if ((self.segmentedControl.currentState == 0 && self.attractions.count > 0) || (self.segmentedControl.currentState == 1 && self.restaurants.count > 0)) {
                [self.eventsTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:true];
            }
        }
        self.isLoadingData = false;
        [self.activityIndicator stopAnimating];
        [self.eventsTableView setHidden:false];
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

#pragma mark - Empty Table View Customization

- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView {
    if (self.isLoadingData) {
        return [[NSAttributedString alloc] initWithString:@""];
    }
    // only show title if finished loading & there are no results
    NSString *type = self.segmentedControl.currentState == 0 ? @"attraction" : @"restaurant";
    NSString *text = [NSString stringWithFormat:@"No %@ results", type];
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:18.0f weight:UIFontWeightMedium],
                                 NSForegroundColorAttributeName: [UIColor darkGrayColor]};
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

- (NSAttributedString *)descriptionForEmptyDataSet:(UIScrollView *)scrollView {
    if (self.isLoadingData) {
        return [[NSAttributedString alloc] initWithString:@""];
    }
    // only show description if finished loading & there are no results
    NSString *text = @"Try searching another location.";
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:16.0f],
                                 NSForegroundColorAttributeName: [UIColor lightGrayColor]};
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

- (CGFloat)verticalOffsetForEmptyDataSet:(UIScrollView *)scrollView {
    return -40.0f;
}

- (CGFloat)spaceHeightForEmptyDataSet:(UIScrollView *)scrollView {
    return 8.0f;
}

#pragma  mark - Segmented Control Customization

- (NSInteger)numberOfStatesInSegmentedControl:(LUNSegmentedControl *)segmentedControl {
    return 2;
}

- (NSAttributedString *)segmentedControl:(LUNSegmentedControl *)segmentedControl attributedTitleForStateAtIndex:(NSInteger)index {
    NSArray *titles = @[@"Places to Visit", @"Restaurants"];
    return [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@",titles[index]] attributes:@{
        NSFontAttributeName : [UIFont systemFontOfSize:16]
    }];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    EventDetailsViewController *eventDetailsViewController = [segue destinationViewController];
    NSIndexPath *indexPath = [self.eventsTableView indexPathForCell:sender];
    Event *event = self.segmentedControl.currentState == 0 ? self.attractions[indexPath.section] : self.restaurants[indexPath.section];
    eventDetailsViewController.event = event;
    [eventDetailsViewController setAllowBooking:true];
}


@end
