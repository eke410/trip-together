//
//  CreateGroupViewController.m
//  trip-together
//
//  Created by Elizabeth Ke on 7/12/21.
//

#import "CreateGroupViewController.h"
#import "Group.h"
#import "UserCell.h"

@interface CreateGroupViewController () <UserCellDelegate, UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITextField *groupNameField;
@property (weak, nonatomic) IBOutlet UITableView *usersInGroupTableView;
@property (weak, nonatomic) IBOutlet UITableView *usersToAddTableView;

@property (strong, nonatomic) NSMutableArray *usersInGroup;
@property (strong, nonatomic) NSMutableArray *usersToAdd;

@end

@implementation CreateGroupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.usersInGroupTableView.dataSource = self;
    self.usersInGroupTableView.delegate = self;
    self.usersToAddTableView.dataSource = self;
    self.usersToAddTableView.delegate = self;
    self.usersInGroupTableView.layer.borderColor = [[UIColor systemGray3Color] CGColor];
    self.usersToAddTableView.layer.borderColor = [[UIColor systemGray3Color] CGColor];
    self.groupNameField.layer.borderColor = [[UIColor systemGray3Color] CGColor];
    
    self.usersInGroup = [[NSMutableArray alloc] initWithObjects:PFUser.currentUser, nil];

    PFQuery *query = [PFUser query];
    [query whereKey:@"objectId" notEqualTo:PFUser.currentUser.objectId];
    [query orderByAscending:@"firstName"];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable users, NSError * _Nullable error) {
        self.usersToAdd = (NSMutableArray *)users;
        [self.usersToAddTableView reloadData];
    }];
}


- (IBAction)createGroup:(id)sender {
    [self sortByFirstName:self.usersInGroup];
    Group *newGroup = [Group postGroupWithUsers:self.usersInGroup withName:self.groupNameField.text withLocation:@"placeholder_location" withStartDate:[NSDate new] withEndDate:[NSDate new] withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
        if (error != nil) {
            NSLog(@"Failed to create group: %@", error.localizedDescription);
        } else {
            NSLog(@"Created group successfully");
        }
    }];
    [self.navigationController popViewControllerAnimated:true];
    [self.delegate didCreateGroup:newGroup];
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
        cell.user = user;
        [cell refreshData];
        [cell.button setImage:[UIImage systemImageNamed:@"minus"] forState:UIControlStateNormal];
        cell.delegate = self;
        if (user == PFUser.currentUser) {
            [cell.button setHidden:true];
        }
        return cell;
    } else {
        UserCell *cell = [self.usersToAddTableView dequeueReusableCellWithIdentifier:@"UserCell"];
        PFUser *user = self.usersToAdd[indexPath.row];
        cell.user = user;
        [cell refreshData];
        [cell.button setImage:[UIImage systemImageNamed:@"plus"] forState:UIControlStateNormal];
        cell.delegate = self;
        return cell;
    }
}

- (void)addUserToGroup:(PFUser *)user {
    [self.usersInGroup addObject:user];
    [self.usersToAdd removeObject:user];
    
    [self.usersInGroupTableView reloadData];
    [self.usersToAddTableView reloadData];
}

- (void)removeUserFromGroup:(PFUser *)user {
    [self.usersInGroup removeObject:user];
    [self.usersToAdd addObject:user];
    [self sortByFirstName:self.usersToAdd];
        
    [self.usersInGroupTableView reloadData];
    [self.usersToAddTableView reloadData];
}

- (void)sortByFirstName:(NSMutableArray *)users {
    NSSortDescriptor *firstNameSorter = [[NSSortDescriptor alloc] initWithKey:@"firstName" ascending:true];
    [users sortUsingDescriptors:[NSArray arrayWithObject:firstNameSorter]];
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
