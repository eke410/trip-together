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

- (IBAction)bookEvent:(id)sender {
    NSInteger row = (NSInteger)[self.groupPicker selectedRowInComponent:0];
    self.event.group = self.groups[row];
    self.event.startTime = self.startDatePicker.date;
    self.event.endTime = self.endDatePicker.date;
    
    if ([self.startDatePicker.date compare:self.endDatePicker.date] == NSOrderedDescending) {
        [self presentViewController:self.invalidDateAlert animated:YES completion:nil];
    } else {
        [self.event saveInBackground];
        [self dismissViewControllerAnimated:true completion:nil];
    }
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
