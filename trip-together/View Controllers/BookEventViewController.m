//
//  BookEventViewController.m
//  trip-together
//
//  Created by Elizabeth Ke on 7/12/21.
//

#import "BookEventViewController.h"
#import "Event.h"
#import "Group.h"

@interface BookEventViewController () <UIPickerViewDataSource, UIPickerViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *eventNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet UILabel *ratingLabel;
@property (weak, nonatomic) IBOutlet UIDatePicker *startDatePicker;
@property (weak, nonatomic) IBOutlet UIDatePicker *endDatePicker;
@property (weak, nonatomic) IBOutlet UIPickerView *groupPicker;
@property (strong, nonatomic) NSArray *groups;
@property (strong, nonatomic) UIAlertController *invalidDateAlert;
@property (strong, nonatomic) UIAlertController *conflictAlert;
@property (strong, nonatomic) UIAlertController *groupDeletedAlert;

@end

@implementation BookEventViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.event) {
        [self refreshData];
    }
    
    self.invalidDateAlert = [UIAlertController alertControllerWithTitle:@"Invalid times" message:@"Please choose an end time after the start time." preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil];
    [self.invalidDateAlert addAction:okAction];
    
    self.conflictAlert = [UIAlertController alertControllerWithTitle:@"Event time conflict" message:@"Some users in group have conflicts" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:nil];
    UIAlertAction *bookAction = [UIAlertAction actionWithTitle:@"Book" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self bookEventWithoutValidation];
    }];
    [self.conflictAlert addAction:cancelAction];
    [self.conflictAlert addAction:bookAction];
    
    self.groupDeletedAlert = [UIAlertController alertControllerWithTitle:@"Group does not exist anymore" message:@"Please select a different group." preferredStyle:UIAlertControllerStyleAlert];
    [self.groupDeletedAlert addAction:okAction];
    
    self.groupPicker.delegate = self;
    self.groupPicker.dataSource = self;
    
    PFQuery *query = [PFQuery queryWithClassName:@"Group"];
    [query orderByDescending:@"startDate"];
    [query includeKey:@"users"];
    [query whereKey:@"users" containsAllObjectsInArray:[[NSArray alloc] initWithObjects:PFUser.currentUser, nil]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *groups, NSError *error) {
        if (groups != nil) {
            self.groups = (NSMutableArray *)groups;
            [self.groupPicker reloadAllComponents];
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
    }];
}

- (void)refreshData {
    self.eventNameLabel.text = self.event.name;
    self.locationLabel.text = self.event.location;
    self.ratingLabel.text = [NSString stringWithFormat: @"%@/5", self.event.rating];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return self.groups.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    Group *group = self.groups[row];
    return group.name;
}

#pragma mark - Booking Event & Event Validation

- (IBAction)bookEvent:(id)sender {
    Event *newEvent = [self.event copy];
    NSInteger row = (NSInteger)[self.groupPicker selectedRowInComponent:0];
    newEvent.group = self.groups[row];
    newEvent.startTime = self.startDatePicker.date;
    newEvent.endTime = self.endDatePicker.date;
    
    // checks that start time is before end time
    if ([newEvent.startTime compare:newEvent.endTime] != NSOrderedAscending) {
        [self presentViewController:self.invalidDateAlert animated:YES completion:nil];
        return;
    }
    
    // checks if group still exists
    PFQuery *query = [PFQuery queryWithClassName:@"Group"];
    [query whereKey:@"objectId" equalTo:newEvent.group.objectId];
    NSArray *groups = [query findObjects];
    if ([groups count] == 0) {
        [self presentViewController:self.groupDeletedAlert animated:YES completion:nil];
        return;
    }
    
    // checks if any user has time conflicts
    NSArray *usersWithConflicts = [self getUsersWithConflictsForEvent:newEvent];
    if ([usersWithConflicts count] > 0) {
        NSString *userConflictString = @"Warning! The following people have conflicts: ";
        for (PFUser *user in usersWithConflicts) {
            userConflictString = [userConflictString stringByAppendingString:[NSString stringWithFormat:@"%@, ", user[@"firstName"]]];
        }
        userConflictString = [userConflictString substringToIndex:[userConflictString length]-2];
        self.conflictAlert.message = userConflictString;
        [self presentViewController:self.conflictAlert animated:YES completion:nil];
        return;
    }
    
    // if no conflicts, save event to Parse
    [newEvent saveInBackground];
    [self dismissViewControllerAnimated:true completion:nil];
}

- (void)bookEventWithoutValidation {
    // saves event without any validation steps
    Event *newEvent = [self.event copy];
    NSInteger row = (NSInteger)[self.groupPicker selectedRowInComponent:0];
    newEvent.group = self.groups[row];
    newEvent.startTime = self.startDatePicker.date;
    newEvent.endTime = self.endDatePicker.date;
    
    [newEvent saveInBackground];
    [self dismissViewControllerAnimated:true completion:nil];
}

- (NSArray *)getUsersWithConflictsForEvent:(Event *)event {
    // returns array of users who have time conflicts for the event, sorted by alphabetical order on first name
    // finds users with conflicts
    NSMutableSet *usersWithConflicts = [NSMutableSet new];
    NSArray *conflictingEvents = [self getConflictingEventsForEvent:event];
    for (Event *conflictingEvent in conflictingEvents) {
        NSArray *overlappingUsers = [self getOverlappingUsersInGroup1:event.group andGroup2:conflictingEvent.group];
        [usersWithConflicts addObjectsFromArray:overlappingUsers];
    }
    // sorts users by first name
    NSSortDescriptor *firstNameSorter = [[NSSortDescriptor alloc] initWithKey:@"firstName" ascending:true];
    NSSortDescriptor *lastNameSorter = [[NSSortDescriptor alloc] initWithKey:@"lastName" ascending:true];
    NSArray *sortedUsers = [usersWithConflicts sortedArrayUsingDescriptors:@[firstNameSorter, lastNameSorter]];
    return sortedUsers;
}

- (NSArray *)getConflictingEventsForEvent:(Event *)event {
    // returns array of events that would cause a time conflict for any user in the group
    NSMutableArray *conflictingEvents = [NSMutableArray new];
    NSArray *eventsToCheck = [self getEventsForUsersInGroup:event.group];
    for (Event *eventToCheck in eventsToCheck) {
        if ([self hasConflictBetweenEvent1:event andEvent2:eventToCheck]) {
            [conflictingEvents addObject:eventToCheck];
        }
    }
    return (NSArray *) conflictingEvents;
}

- (NSArray *)getEventsForUsersInGroup:(Group *)group {
    // returns all events that any user in the group is signed up for
    PFQuery *query = [PFQuery queryWithClassName:@"Event"];
    [query includeKey:@"group"];
    [query includeKey:@"group.users"];
    
    NSArray *events = [query findObjects];
    NSMutableArray *filteredEvents = [NSMutableArray new];
    for (Event *event in events) {
        if ([self hasUserOverlapInGroup1:group andGroup2:event.group]) {
            [filteredEvents addObject:event];
        }
    }
    return (NSArray *) filteredEvents;
}

- (NSArray *)getOverlappingUsersInGroup1:(Group *)group1 andGroup2:(Group *)group2 {
    // returns any users that group1 and group2 have in common
    NSMutableArray *overlappingUsers = [NSMutableArray new];
    NSArray *group2ids = [self getUserIDsOfGroup:group2];
    for (PFUser *user in group1.users) {
        if ([group2ids containsObject:user.objectId]) {
            [overlappingUsers addObject:user];
        }
    }
    return overlappingUsers;
}

- (BOOL)hasUserOverlapInGroup1:(Group *)group1 andGroup2:(Group *)group2 {
    // returns true if group1 and group2 have any user in common, returns false otherwise
    NSArray *group2ids = [self getUserIDsOfGroup:group2];
    for (PFUser *user in group1.users) {
        if ([group2ids containsObject:user.objectId]) {
            return true;
        }
    }
    return false;
}

- (NSArray *)getUserIDsOfGroup:(Group *)group {
    // returns array containing all objectIds of users in the group
    NSMutableArray *groupIDs = [NSMutableArray new];
    for (PFUser *user in group.users) {
        [groupIDs addObject:user.objectId];
    }
    return (NSArray *) groupIDs;
}

- (BOOL) hasConflictBetweenEvent1:(Event *)event1 andEvent2:(Event *)event2 {
    // returns true if event1 and event2 overlap in time, returns false otherwise
    return (([event1.startTime compare:event2.startTime] != NSOrderedDescending && [event2.startTime compare:event1.endTime] == NSOrderedAscending) || ([event2.startTime compare:event1.startTime] != NSOrderedDescending && [event1.startTime compare:event2.endTime] == NSOrderedAscending));
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
