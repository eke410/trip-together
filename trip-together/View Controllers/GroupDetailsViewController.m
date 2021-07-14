//
//  GroupDetailsViewController.m
//  trip-together
//
//  Created by Elizabeth Ke on 7/12/21.
//

#import "GroupDetailsViewController.h"
#import "UserCell.h"
#import "EventCell.h"

@interface GroupDetailsViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *groupName;
@property (weak, nonatomic) IBOutlet UITableView *usersTableView;
@property (weak, nonatomic) IBOutlet UITableView *eventsTableView;
@property (strong, nonatomic) NSMutableArray *events;

@end

@implementation GroupDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self refreshData];
    
    self.usersTableView.dataSource = self;
    self.usersTableView.delegate = self;
    self.eventsTableView.dataSource = self;
    self.eventsTableView.delegate = self;
}

- (void)refreshData {
    self.groupName.text = self.group.name;
    [self queryEvents];
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
    if (tableView == self.usersTableView) {
        return self.group.users.count;
    } else {
        return self.events.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.usersTableView) {
        UserCell *cell = [self.usersTableView dequeueReusableCellWithIdentifier:@"UserCell"];
        PFUser *user = self.group.users[indexPath.row];
        cell.user = user;
        cell.usernameLabel.text = user.username;
        [cell.button setHidden:true];
        return cell;
    } else {
        EventCell *cell = [self.eventsTableView dequeueReusableCellWithIdentifier:@"EventCell"];
        cell.event = self.events[indexPath.row];
        [cell refreshData];
        return cell;
    }
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


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
