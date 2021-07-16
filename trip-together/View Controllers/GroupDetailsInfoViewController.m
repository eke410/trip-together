//
//  GroupDetailsInfoViewController.m
//  trip-together
//
//  Created by Elizabeth Ke on 7/15/21.
//

#import "GroupDetailsInfoViewController.h"
#import "UserCell.h"
#import "Event.h"

@interface GroupDetailsInfoViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *usersTableView;

@end

@implementation GroupDetailsInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.usersTableView.delegate = self;
    self.usersTableView.dataSource = self;
    
    self.usersTableView.layer.borderColor = [[UIColor systemGray3Color] CGColor];
    self.usersTableView.layer.borderWidth = 1;
    self.usersTableView.layer.cornerRadius = 5;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.group.users.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UserCell *cell = [self.usersTableView dequeueReusableCellWithIdentifier:@"UserCell"];
    PFUser *user = self.group.users[indexPath.row];
    cell.user = user;
    [cell refreshData];
    [cell.button setHidden:true];
    return cell;
}

- (IBAction)leaveGroup:(id)sender {
    if (self.group.users.count == 1) { // if only 1 user, delete group
        [self deleteGroup:sender];
    } else { // if more than 1 user, remove user from group
        [self.navigationController popToRootViewControllerAnimated:YES];
        [self.delegate removeGroup:self.group];
        NSMutableArray *usersMutableCopy = [self.group.users mutableCopy];
        for (PFUser *user in self.group.users) {
            if ([user.objectId isEqualToString:PFUser.currentUser.objectId]) {
                [usersMutableCopy removeObject:user];
            }
        }
        self.group.users = (NSArray *)usersMutableCopy;
        [self.group saveInBackground];
    }
}

- (IBAction)deleteGroup:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
    [self.delegate removeGroup:self.group];
    [self.group deleteInBackground];
    
    // delete all events associated with group
    PFQuery *query = [PFQuery queryWithClassName:@"Event"];
    [query whereKey:@"group" equalTo:self.group];
    [query findObjectsInBackgroundWithBlock:^(NSArray *events, NSError *error) {
        if (events != nil) {
            for (Event *event in events) {
                [event deleteInBackground];
            }
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
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
