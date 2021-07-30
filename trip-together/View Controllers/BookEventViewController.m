//
//  BookEventViewController.m
//  trip-together
//
//  Created by Elizabeth Ke on 7/12/21.
//

#import "BookEventViewController.h"
#import "Event.h"
#import "Group.h"
#import "DateTools.h"
#import "EventValidation.h"

@interface BookEventViewController () <UIPickerViewDataSource, UIPickerViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *eventNameLabel;
@property (weak, nonatomic) IBOutlet UIDatePicker *startDatePicker;
@property (weak, nonatomic) IBOutlet UIDatePicker *endDatePicker;
@property (weak, nonatomic) IBOutlet UILabel *forGroupLabel;
@property (weak, nonatomic) IBOutlet UIPickerView *groupPicker;
@property (weak, nonatomic) IBOutlet UIButton *bookEventButton;
@property (strong, nonatomic) NSArray *groups;
@property (strong, nonatomic) UIAlertController *invalidDateAlert;
@property (strong, nonatomic) UIAlertController *conflictAlert;
@property (strong, nonatomic) UIAlertController *groupDeletedAlert;
@property (strong, nonatomic) UIAlertController *generalErrorAlert;

@end

@implementation BookEventViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.event) {
        [self refreshData];
    }
    
    // sets up date pickers & their times
    self.startDatePicker.minimumDate = [NSDate date];
    self.endDatePicker.minimumDate = [NSDate date];
    
    NSDate *currentDate = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:currentDate];
    [components setHour:currentDate.hour + 1];
    NSDate *startDate = [calendar dateFromComponents:components];
    [self.startDatePicker setDate:startDate];
    [self.endDatePicker setDate:[NSDate dateWithTimeInterval:3600 sinceDate:startDate]];
    
    [self.startDatePicker addTarget:self action:@selector(startDateChanged) forControlEvents:UIControlEventValueChanged];
    
    // initializes alerts
    self.invalidDateAlert = [UIAlertController alertControllerWithTitle:@"Invalid times" message:@"Please choose an end time after the start time." preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil];
    [self.invalidDateAlert addAction:okAction];
    
    self.conflictAlert = [UIAlertController alertControllerWithTitle:@"Event time conflict" message:@"Some users in group have conflicts" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:nil];
    UIAlertAction *bookAction = [UIAlertAction actionWithTitle:@"Book" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self bookEventWithoutUserValidation];
    }];
    [self.conflictAlert addAction:cancelAction];
    [self.conflictAlert addAction:bookAction];
    
    self.groupDeletedAlert = [UIAlertController alertControllerWithTitle:@"Group does not exist anymore" message:@"Please select a different group." preferredStyle:UIAlertControllerStyleAlert];
    [self.groupDeletedAlert addAction:okAction];
    
    self.generalErrorAlert = [UIAlertController alertControllerWithTitle:@"Error" message:@"Please try again." preferredStyle:UIAlertControllerStyleAlert];
    [self.generalErrorAlert addAction:okAction];
    
    self.groupPicker.delegate = self;
    self.groupPicker.dataSource = self;
    
    // sets up gradient background of book event button
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.bookEventButton.bounds;
    gradient.startPoint = CGPointMake(0, 1);
    gradient.endPoint = CGPointMake(0, 0);
    gradient.cornerRadius = 16;
    gradient.colors = @[(id)[[UIColor colorWithRed:78/255.0 green:168/255.0 blue:222/255.0 alpha:1] CGColor], (id)[[UIColor colorWithRed:100/255.0 green:178/255.0 blue:227/255.0 alpha:1] CGColor]];
    [self.bookEventButton.layer insertSublayer:gradient atIndex:0];
    
    // queries groups that user is in
    PFQuery *query = [PFQuery queryWithClassName:@"Group"];
    [query orderByDescending:@"startDate"];
    [query includeKey:@"users"];
    [query whereKey:@"users" containsAllObjectsInArray:[[NSArray alloc] initWithObjects:PFUser.currentUser, nil]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *groups, NSError *error) {
        if (groups != nil) {
            self.groups = (NSMutableArray *)groups;
            [self.groupPicker reloadAllComponents];
            
            if (groups.count == 0) {
                self.forGroupLabel.text = @"You have no groups to book this event for. Please create a group and try again.";
                [self.forGroupLabel setFont:[UIFont systemFontOfSize:17 weight:UIFontWeightRegular]];
                [self.groupPicker removeFromSuperview];
                [self.bookEventButton removeFromSuperview];
            }
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
    }];
}

- (void)refreshData {
    self.eventNameLabel.text = self.event.name;
}

- (void)startDateChanged {
    [self.endDatePicker setDate:[NSDate dateWithTimeInterval:3600 sinceDate:self.startDatePicker.date]];
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

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    UILabel *pickerLabel = (UILabel *)view;
    if (!pickerLabel) {
        pickerLabel = [UILabel new];
        [pickerLabel setFont:[UIFont systemFontOfSize:17]];
        [pickerLabel setTextAlignment:NSTextAlignmentCenter];
    }
    Group *group = self.groups[row];
    pickerLabel.text = group.name;
    return pickerLabel;
}

#pragma mark - Booking Event & Event Validation

- (IBAction)bookEvent:(id)sender {
    
    // checks that event is not null
    if (!self.event || [self.event isEqual:[NSNull null]]) {
        self.generalErrorAlert.title = @"Error selecting event";
        [self presentViewController:self.generalErrorAlert animated:YES completion:nil];
        return;
    }
    
    // copies event and sets properties
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
    
    // checks that a group is selected
    if (!newEvent.group || [newEvent.group isEqual:[NSNull null]]) {
        self.generalErrorAlert.title = @"Error selecting group";
        [self presentViewController:self.generalErrorAlert animated:YES completion:nil];
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
    NSArray *usersWithConflicts = [EventValidation getUsersWithConflictsForEvent:newEvent];
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

- (void)bookEventWithoutUserValidation {
    // saves event without any null checks or user validation steps
    
    // copies event and saves properties
    Event *newEvent = [self.event copy];
    NSInteger row = (NSInteger)[self.groupPicker selectedRowInComponent:0];
    newEvent.group = self.groups[row];
    newEvent.startTime = self.startDatePicker.date;
    newEvent.endTime = self.endDatePicker.date;
    
    // checks if group still exists
    PFQuery *query = [PFQuery queryWithClassName:@"Group"];
    [query whereKey:@"objectId" equalTo:newEvent.group.objectId];
    NSArray *groups = [query findObjects];
    if ([groups count] == 0) {
        [self presentViewController:self.groupDeletedAlert animated:YES completion:nil];
        return;
    }
    
    // saves event to Parse
    [newEvent saveInBackground];
    [self dismissViewControllerAnimated:true completion:nil];
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
