//
//  BookEventViewController.m
//  trip-together
//
//  Created by Elizabeth Ke on 7/12/21.
//

#import "BookEventViewController.h"
#import "Event.h"
#import "Group.h"

@interface BookEventViewController ()

@property (weak, nonatomic) IBOutlet UILabel *eventNameLabel;

@end

@implementation BookEventViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.event) {
        [self refreshData];
    }
}

- (void)refreshData {
    self.eventNameLabel.text = self.event.name;
}

- (IBAction)bookEvent:(id)sender {
    [Event postEventWithName:@"1st event" withSummary:@"fake" withGroup:[Group new] withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
        NSLog(@"booked fake event");
    }];
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
