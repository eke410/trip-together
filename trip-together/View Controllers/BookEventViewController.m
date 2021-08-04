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
@import PopupDialog;

@interface BookEventViewController () <UIPickerViewDataSource, UIPickerViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *eventNameLabel;
@property (weak, nonatomic) IBOutlet UIDatePicker *startDatePicker;
@property (weak, nonatomic) IBOutlet UIDatePicker *endDatePicker;
@property (weak, nonatomic) IBOutlet UILabel *forGroupLabel;
@property (weak, nonatomic) IBOutlet UIPickerView *groupPicker;
@property (weak, nonatomic) IBOutlet UIButton *bookEventButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (strong, nonatomic) NSArray *groups;

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
        
    self.groupPicker.delegate = self;
    self.groupPicker.dataSource = self;
    
    // sets up gradient background of book event button, border of cancel button
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.bookEventButton.bounds;
    gradient.startPoint = CGPointMake(0, 1);
    gradient.endPoint = CGPointMake(0, 0);
    gradient.cornerRadius = 16;
    gradient.colors = @[(id)[[UIColor colorWithRed:78/255.0 green:168/255.0 blue:222/255.0 alpha:1] CGColor], (id)[[UIColor colorWithRed:100/255.0 green:178/255.0 blue:227/255.0 alpha:1] CGColor]];
    [self.bookEventButton.layer insertSublayer:gradient atIndex:0];
    
    self.cancelButton.layer.borderWidth = 1;
    self.cancelButton.layer.borderColor = [[UIColor colorWithRed:83/255.0 green:144/255.0 blue:217/255.0 alpha:1] CGColor];
    
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

- (IBAction)tappedCancelButton:(id)sender {
    [self dismissViewControllerAnimated:true completion:nil];
}

#pragma mark - Booking Event & Event Validation

- (IBAction)bookEvent:(id)sender {
    // checks that event is not null
    if (!self.event || [self.event isEqual:[NSNull null]]) {
        PopupDialog *popup = [[PopupDialog alloc] initWithTitle:@"Error selecting event" message:@"Please try again" image:nil buttonAlignment:UILayoutConstraintAxisHorizontal transitionStyle:PopupDialogTransitionStyleZoomIn preferredWidth:200 tapGestureDismissal:YES panGestureDismissal:YES hideStatusBar:NO completion:nil];
        [popup addButtons:@[[[DefaultButton alloc] initWithTitle:@"Ok" height:45 dismissOnTap:YES action:nil]]];
        [self presentViewController:popup animated:YES completion:nil];
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
        PopupDialog *popup = [[PopupDialog alloc] initWithTitle:@"Invalid times selected" message:@"Please choose an end time after the start time" image:nil buttonAlignment:UILayoutConstraintAxisHorizontal transitionStyle:PopupDialogTransitionStyleZoomIn preferredWidth:200 tapGestureDismissal:YES panGestureDismissal:YES hideStatusBar:NO completion:nil];
        [popup addButtons:@[[[DefaultButton alloc] initWithTitle:@"Ok" height:45 dismissOnTap:YES action:nil]]];
        [self presentViewController:popup animated:YES completion:nil];
        return;
    }
    
    // checks that a group is selected
    if (!newEvent.group || [newEvent.group isEqual:[NSNull null]]) {
        PopupDialog *popup = [[PopupDialog alloc] initWithTitle:@"Error selecting group" message:@"Please try again" image:nil buttonAlignment:UILayoutConstraintAxisHorizontal transitionStyle:PopupDialogTransitionStyleZoomIn preferredWidth:200 tapGestureDismissal:YES panGestureDismissal:YES hideStatusBar:NO completion:nil];
        [popup addButtons:@[[[DefaultButton alloc] initWithTitle:@"Ok" height:45 dismissOnTap:YES action:nil]]];
        [self presentViewController:popup animated:YES completion:nil];
        return;
    }
    
    // checks if group still exists
    PFQuery *query = [PFQuery queryWithClassName:@"Group"];
    [query whereKey:@"objectId" equalTo:newEvent.group.objectId];
    NSArray *groups = [query findObjects];
    if ([groups count] == 0) {
        PopupDialog *popup = [[PopupDialog alloc] initWithTitle:@"Group does not exist anymore" message:@"Please select a different group" image:nil buttonAlignment:UILayoutConstraintAxisHorizontal transitionStyle:PopupDialogTransitionStyleZoomIn preferredWidth:200 tapGestureDismissal:YES panGestureDismissal:YES hideStatusBar:NO completion:nil];
        [popup addButtons:@[[[DefaultButton alloc] initWithTitle:@"Ok" height:45 dismissOnTap:YES action:nil]]];
        [self presentViewController:popup animated:YES completion:nil];
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
        
        // present conflict popup
        PopupDialog *popup = [[PopupDialog alloc] initWithTitle:@"Event time conflict" message:userConflictString image:nil buttonAlignment:UILayoutConstraintAxisHorizontal transitionStyle:PopupDialogTransitionStyleZoomIn preferredWidth:200 tapGestureDismissal:YES panGestureDismissal:YES hideStatusBar:NO completion:nil];
        CancelButton *cancel = [[CancelButton alloc] initWithTitle:@"Cancel" height:45 dismissOnTap:YES action:nil];
        DefaultButton *book = [[DefaultButton alloc] initWithTitle:@"Schedule anyways" height:45 dismissOnTap:YES action:^{
            [self bookEventWithoutUserValidation];
        }];
        [popup addButtons:@[cancel, book]];
        [self presentViewController:popup animated:YES completion:nil];
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
        PopupDialog *popup = [[PopupDialog alloc] initWithTitle:@"Group does not exist anymore" message:@"Please select a different group" image:nil buttonAlignment:UILayoutConstraintAxisHorizontal transitionStyle:PopupDialogTransitionStyleZoomIn preferredWidth:200 tapGestureDismissal:YES panGestureDismissal:YES hideStatusBar:NO completion:nil];
        [popup addButtons:@[[[DefaultButton alloc] initWithTitle:@"Ok" height:45 dismissOnTap:YES action:nil]]];
        [self presentViewController:popup animated:YES completion:nil];
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
