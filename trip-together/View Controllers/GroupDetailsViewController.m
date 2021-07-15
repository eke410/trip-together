//
//  GroupDetailsViewController.m
//  trip-together
//
//  Created by Elizabeth Ke on 7/12/21.
//

#import "GroupDetailsViewController.h"
#import "EventCell.h"
#import "GroupDetailsInfoViewController.h"

@interface GroupDetailsViewController () <GroupDetailsInfoViewControllerDelegate, UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *groupName;
@property (weak, nonatomic) IBOutlet UITableView *eventsTableView;
@property (weak, nonatomic) IBOutlet UILabel *allUsersLabel;
@property (strong, nonatomic) NSMutableArray *events;

@end

@implementation GroupDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self refreshData];
    
    self.eventsTableView.dataSource = self;
    self.eventsTableView.delegate = self;
}

- (void)refreshData {
    self.groupName.text = self.group.name;
    
    NSString *allUsersString = @"People: ";
    for (PFUser *user in self.group.users) {
        allUsersString = [allUsersString stringByAppendingString:user.username];
        allUsersString = [allUsersString stringByAppendingString:@", "];
    }
    self.allUsersLabel.text = [allUsersString substringToIndex:[allUsersString length]-2]; 
//    [self queryEvents];
}

- (void)queryEvents {
    PFQuery *query = [PFQuery queryWithClassName:@"Event"];
    [query orderByDescending:@"startTime"];
    [query whereKey:@"group" equalTo:self.group];
    [query findObjectsInBackgroundWithBlock:^(NSArray *events, NSError *error) {
        if (events != nil) {
            self.events = (NSMutableArray *)events;
            [self.eventsTableView reloadData];
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.events.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    EventCell *cell = [self.eventsTableView dequeueReusableCellWithIdentifier:@"EventCell"];
    cell.event = self.events[indexPath.row];
    [cell refreshData];
    return cell;
}

- (UISwipeActionsConfiguration *)tableView:(UITableView *)tableView trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.eventsTableView) {
        UIContextualAction *deleteAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleDestructive title:nil handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
            // when delete button is clicked, delete event from group
            Event *event = self.events[indexPath.row];
            [self.events removeObject:event];
            [self.eventsTableView reloadData];
            [event deleteInBackground];
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


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"groupDetailsInfoSegue"]) {
        GroupDetailsInfoViewController *vc = [segue destinationViewController];
        vc.group = self.group;
        vc.delegate = self;
    }
}


@end
