//
//  CreateGroupViewController.m
//  trip-together
//
//  Created by Elizabeth Ke on 7/12/21.
//

#import "CreateGroupViewController.h"
#import "Group.h"
#import "UserCell.h"

@interface CreateGroupViewController () <UserCellDelegate, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *groupNameField;
@property (weak, nonatomic) IBOutlet UITableView *usersInGroupTableView;
@property (weak, nonatomic) IBOutlet UITableView *usersToAddTableView;
@property (weak, nonatomic) IBOutlet UITextField *searchField;

@property (strong, nonatomic) NSMutableArray *usersInGroup;
@property (strong, nonatomic) NSMutableArray *usersToAdd;
@property (strong, nonatomic) NSArray *filteredUsersToAdd;

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
    
    NSSortDescriptor *firstNameSorter = [[NSSortDescriptor alloc] initWithKey:@"firstName" ascending:true];
    NSSortDescriptor *lastNameSorter = [[NSSortDescriptor alloc] initWithKey:@"lastName" ascending:true];
    [query orderBySortDescriptors:@[firstNameSorter, lastNameSorter]];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable users, NSError * _Nullable error) {
        self.usersToAdd = (NSMutableArray *)users;
        self.filteredUsersToAdd = users;
        [self.usersToAddTableView reloadData];
    }];
    
    self.searchField.delegate = self;
}


- (IBAction)createGroup:(id)sender {
    NSSortDescriptor *firstNameSorter = [[NSSortDescriptor alloc] initWithKey:@"firstName" ascending:true];
    NSSortDescriptor *lastNameSorter = [[NSSortDescriptor alloc] initWithKey:@"lastName" ascending:true];
    [self.usersInGroup sortUsingDescriptors:@[firstNameSorter, lastNameSorter]];

    Group *newGroup = [Group postGroupWithUsers:self.usersInGroup withName:self.groupNameField.text withLocation:@"placeholder_location" withStartDate:[NSDate new] withEndDate:[NSDate new] withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
        if (error != nil) {
            NSLog(@"Failed to create group: %@", error.localizedDescription);
        } else {
            NSLog(@"Created group successfully");
        }
    }];
    [self.navigationController popViewControllerAnimated:false];
    [self.delegate didCreateGroup:newGroup];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.usersInGroupTableView) {
        return self.usersInGroup.count;
    } else {
        return self.filteredUsersToAdd.count;
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
        PFUser *user = self.filteredUsersToAdd[indexPath.row];
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
    [self filterUsers];
    
    [self.usersInGroupTableView reloadData];
    [self.usersToAddTableView reloadData];
}

- (void)removeUserFromGroup:(PFUser *)user {
    [self.usersInGroup removeObject:user];
    [self.usersToAdd addObject:user];
    [self filterUsers];
    [self sortFilteredUsersByName];
        
    [self.usersInGroupTableView reloadData];
    [self.usersToAddTableView reloadData];
}

- (void)sortFilteredUsersByName {
    NSSortDescriptor *firstNameSorter = [[NSSortDescriptor alloc] initWithKey:@"firstName" ascending:true];
    NSSortDescriptor *lastNameSorter = [[NSSortDescriptor alloc] initWithKey:@"lastName" ascending:true];
    self.filteredUsersToAdd = [self.filteredUsersToAdd sortedArrayUsingDescriptors:@[firstNameSorter, lastNameSorter]];
}

- (IBAction)searchTextChanged:(id)sender {
    [self filterUsers];
}

- (void)filterUsers {
    // filters users based on search field text
    if (self.searchField.text.length != 0) {
        NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(PFUser *evaluatedObject, NSDictionary *bindings) {
            NSString *fullName = [NSString stringWithFormat:@"%@ %@", evaluatedObject[@"firstName"], evaluatedObject[@"lastName"]];
            return [[fullName lowercaseString] hasPrefix:[self.searchField.text lowercaseString]] || [[evaluatedObject[@"lastName"] lowercaseString] hasPrefix:[self.searchField.text lowercaseString]];
        }];
        self.filteredUsersToAdd = [self.usersToAdd filteredArrayUsingPredicate:predicate];
    } else {
        self.filteredUsersToAdd = [self.usersToAdd copy];
    }
    [self.usersToAddTableView reloadData];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.searchField endEditing:YES];
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
