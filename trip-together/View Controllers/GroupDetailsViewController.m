//
//  GroupDetailsViewController.m
//  trip-together
//
//  Created by Elizabeth Ke on 7/12/21.
//

#import "GroupDetailsViewController.h"
#import "GroupEventCell.h"
#import "GroupDetailsInfoViewController.h"
#import "EventDetailsViewController.h"
#import "Mapkit/Mapkit.h"
#import "EventAnnotation.h"
#import "TimelineCell.h"

@interface GroupDetailsViewController () <GroupDetailsInfoViewControllerDelegate, UITableViewDataSource, UITableViewDelegate, MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *groupName;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (weak, nonatomic) IBOutlet UITableView *eventsTableView;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) NSMutableArray *events;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property int indexOfNextEvent;
@property (strong, nonatomic) UIAlertController *deleteEventAlert;
@property int indexOfEventToBeDeleted;

@end

@implementation GroupDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self refreshData];
    
    [self.segmentedControl addTarget:self action:@selector(changeType) forControlEvents:UIControlEventValueChanged];
    
    // sets up table view & refresh control
    self.eventsTableView.dataSource = self;
    self.eventsTableView.delegate = self;
    
    self.refreshControl = [UIRefreshControl new];
    [self.refreshControl addTarget:self action:@selector(queryEvents) forControlEvents:UIControlEventValueChanged];
    [self.eventsTableView insertSubview:self.refreshControl atIndex:0];
    
    self.mapView.delegate = self;
        
    // set up delete event confirmation alert + actions
    self.deleteEventAlert = [UIAlertController alertControllerWithTitle:@"Delete event" message:@"Are you sure you would like to delete this event?" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:nil];
    UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        // delete selected event from group
        Event *event = self.events[self.indexOfEventToBeDeleted];
        [self.events removeObject:event];
        [self.eventsTableView reloadData];
        [self calculateInxedOfNextEvent];
        [self refreshMap];
        [event deleteInBackground];
    }];
    [self.deleteEventAlert addAction:cancelAction];
    [self.deleteEventAlert addAction:deleteAction];
}

- (void)refreshData {
    self.groupName.text = self.group.name;
    [self queryEvents];
}

- (void)refreshMap {
    // resets marker annotations
    [self.mapView removeAnnotations:self.mapView.annotations];
    for (int i = 0; i < self.events.count; i++) {
        Event *event = self.events[i];
        EventAnnotation *annotation = [EventAnnotation new];
        annotation.coordinate = CLLocationCoordinate2DMake([event.latitude floatValue], [event.longitude floatValue]);
        annotation.event = event;
        annotation.index = i+1;
        [self.mapView addAnnotation:annotation];
    }
    [self.mapView showAnnotations:self.mapView.annotations animated:false];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    MKMarkerAnnotationView *annotationView = (MKMarkerAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:@"Marker"];
    if (annotationView == nil) {
        annotationView = [[MKMarkerAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"Marker"];
        annotationView.canShowCallout = true;
        annotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    }
    EventAnnotation *eventAnnotation = (EventAnnotation *)annotation;
    [annotationView setGlyphText:[NSString stringWithFormat:@"%i", eventAnnotation.index]];
    if ([eventAnnotation.event.type isEqualToString:@"attraction"]) {
        [annotationView setMarkerTintColor:[UIColor colorWithRed:114/255.0 green:205/255.0 blue:233/255.0 alpha:1]];
    } else {
        [annotationView setMarkerTintColor:[UIColor colorWithRed:185/255.0 green:157/255.0 blue:231/255.0 alpha:1]];
    }
    return annotationView;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    EventAnnotation *eventAnnotation = (EventAnnotation *)view.annotation;
    [self performSegueWithIdentifier:@"groupEventDetailsSegue" sender:eventAnnotation.event];
}

- (void)queryEvents {
    PFQuery *query = [PFQuery queryWithClassName:@"Event"];
    [query orderByAscending:@"startTime"];
    [query whereKey:@"group" equalTo:self.group];
    [query findObjectsInBackgroundWithBlock:^(NSArray *events, NSError *error) {
        if (events != nil) {
            self.events = (NSMutableArray *)events;
            [self.eventsTableView reloadData];
            [self refreshMap];
            [self calculateInxedOfNextEvent];
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
        [self.refreshControl endRefreshing];
    }];
}

- (void)calculateInxedOfNextEvent {
    NSDate *currentDate = [NSDate date];
    int index = 0;
    for (int i = 0; i < self.events.count; i++) {
        Event *event = self.events[i];
        if ([currentDate compare:event.endTime] == NSOrderedAscending) { // current date is before event's end time
            index = i;
            break;
        }
        if (i == self.events.count - 1) { // current date is after last event's end time -> all events over
            index = (int)self.events.count;
        }
    }
    self.indexOfNextEvent = index;
}

- (void)changeType {
    if (self.segmentedControl.selectedSegmentIndex == 0 || self.segmentedControl.selectedSegmentIndex == 1) { // show itinerary or events
        [self.eventsTableView setHidden:false];
        [self.mapView setHidden:true];
        [self.eventsTableView reloadData];
    } else { // show map
        [self.eventsTableView setHidden:true];
        [self.mapView setHidden:false];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.events.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.segmentedControl.selectedSegmentIndex == 0) { // itinerary
        TimelineCell *cell = [self.eventsTableView dequeueReusableCellWithIdentifier:@"TimelineCell"];
        cell.event = self.events[indexPath.section];
        cell.indexLabel.text = [NSString stringWithFormat:@"%i", (int)indexPath.section + 1];
        [cell refreshData];
        // crops timeline edges for first and last cells
        if (self.events.count == 1) {
            [cell.timelineLine setHidden:true];
        } else if (indexPath.section == 0) {
            [cell.timelineLine setFrame:CGRectMake(37, cell.contentView.frame.size.height/2, 4, cell.contentView.frame.size.height/2)];
        } else if (indexPath.section == self.events.count - 1) {
            [cell.timelineLine setFrame:CGRectMake(37, 0, 4, cell.contentView.frame.size.height/2)];
        }
        // darkens circle of next event
        if (indexPath.section == self.indexOfNextEvent) {
            [cell.timelinePoint setBackgroundColor:[UIColor colorWithRed:138/255.0 green:179/255.0 blue:229/255.0 alpha:1]];
        }
        return cell;
    } else { // events list
        GroupEventCell *cell = [self.eventsTableView dequeueReusableCellWithIdentifier:@"GroupEventCell"];
        cell.event = self.events[indexPath.section];
        [cell refreshData];
        return cell;
    }
}

- (UISwipeActionsConfiguration *)tableView:(UITableView *)tableView trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.eventsTableView) {
        UIContextualAction *deleteAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleDestructive title:nil handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
            // if trash button clicked, present confirmation
            self.indexOfEventToBeDeleted = (int)indexPath.section;
            [self presentViewController:self.deleteEventAlert animated:true completion:nil];
        }];
        [deleteAction setImage:[UIImage systemImageNamed:@"trash"]];

        UISwipeActionsConfiguration *swipeActionConfig = [UISwipeActionsConfiguration configurationWithActions:@[deleteAction]];
        [swipeActionConfig setPerformsFirstActionWithFullSwipe:NO];
        return swipeActionConfig;
    } else {
        return nil;
    }
}

- (void)removeGroup:(Group *)group {
    [self.delegate removeGroup:group];
}

- (void)changePhoto:(UIImage *)photo {
    [self.delegate updateCellForGroup:self.group];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"groupDetailsInfoSegue"]) {
        GroupDetailsInfoViewController *vc = [segue destinationViewController];
        vc.group = self.group;
        vc.delegate = self;
    } else if ([segue.identifier isEqualToString:@"groupEventDetailsSegue"]) {
        EventDetailsViewController *vc = [segue destinationViewController];
        [vc setAllowBooking:false];
        if ([sender isKindOfClass:[UITableViewCell class]]) { // segue from table view itinerary
            NSIndexPath *indexPath = [self.eventsTableView indexPathForCell:sender];
            vc.event = self.events[indexPath.section];
        } else if ([sender isKindOfClass:[Event class]]) { // segue from map itinerary
            vc.event = sender;
        }
    }
}


@end
