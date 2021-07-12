//
//  CreateGroupViewController.m
//  trip-together
//
//  Created by Elizabeth Ke on 7/12/21.
//

#import "CreateGroupViewController.h"
#import "Group.h"
#import "UserCell.h"

@interface CreateGroupViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *usersInGroupTableView;
@property (weak, nonatomic) IBOutlet UITableView *usersToAddTableView;

@property (strong, nonatomic) NSArray *usersInGroup;
@property (strong, nonatomic) NSArray *usersToAdd;

@end

@implementation CreateGroupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.usersInGroupTableView.dataSource = self;
    self.usersInGroupTableView.delegate = self;
    self.usersToAddTableView.dataSource = self;
    self.usersToAddTableView.delegate = self;
    
    self.usersInGroup = [[NSArray alloc] initWithObjects:PFUser.currentUser, nil];

    PFQuery *query = [PFUser query];
    [query whereKey:@"objectId" notEqualTo:PFUser.currentUser.objectId];
    [query orderByAscending:@"username"];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable users, NSError * _Nullable error) {
        self.usersToAdd = users;
        [self.usersToAddTableView reloadData];
    }];
}


- (IBAction)createGroup:(id)sender {
    [Group postGroupWithUsers:[NSArray new] withName:@"placeholder_name" withLocation:@"placeholder_location" withStartDate:[NSDate new] withEndDate:[NSDate new] withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
        if (error != nil) {
            NSLog(@"Failed to create group: %@", error.localizedDescription);
        } else {
            NSLog(@"Created group successfully");
        }
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.usersInGroupTableView) {
        return self.usersInGroup.count;
    } else {
        return self.usersToAdd.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.usersInGroupTableView) {
        UserCell *cell = [self.usersInGroupTableView dequeueReusableCellWithIdentifier:@"UserCell"];
        PFUser *user = self.usersInGroup[indexPath.row];
        cell.usernameLabel.text = user.username;
        [cell.button setImage:[UIImage systemImageNamed:@"minus"] forState:UIControlStateNormal];
        return cell;
    } else {
        UserCell *cell = [self.usersToAddTableView dequeueReusableCellWithIdentifier:@"UserCell"];
        PFUser *user = self.usersToAdd[indexPath.row];
        cell.usernameLabel.text = user.username;
        [cell.button setImage:[UIImage systemImageNamed:@"plus"] forState:UIControlStateNormal];
        return cell;
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
