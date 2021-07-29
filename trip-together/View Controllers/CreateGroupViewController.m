//
//  CreateGroupViewController.m
//  trip-together
//
//  Created by Elizabeth Ke on 7/12/21.
//

#import "CreateGroupViewController.h"
#import "Group.h"
#import "UserCell.h"
#import "TagListView-Swift.h"

@interface CreateGroupViewController () <UserCellDelegate, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, TagListViewDelegate>

@property (weak, nonatomic) IBOutlet UITextField *groupNameField;
@property (weak, nonatomic) IBOutlet TagListView *usersTagListView;
@property (weak, nonatomic) IBOutlet UITableView *usersToAddTableView;
@property (weak, nonatomic) IBOutlet UITextField *searchField;

@property (strong, nonatomic) NSMutableArray *usersInGroup;
@property (strong, nonatomic) NSMutableArray *usersToAdd;
@property (strong, nonatomic) NSArray *filteredUsersToAdd;

@end

@implementation CreateGroupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.usersToAddTableView.dataSource = self;
    self.usersToAddTableView.delegate = self;
    self.usersToAddTableView.layer.borderColor = [[UIColor systemGray3Color] CGColor];
    self.groupNameField.layer.borderColor = [[UIColor systemGray3Color] CGColor];
    
    self.usersInGroup = [[NSMutableArray alloc] initWithObjects:PFUser.currentUser, nil];
    [self.usersTagListView addTag: [self getFullName:PFUser.currentUser]];
    self.usersTagListView.textFont = [UIFont systemFontOfSize:17];
    self.usersTagListView.delegate = self;
    
    TagView *firstTagView = self.usersTagListView.tagViews[0];
    firstTagView.enableRemoveButton = false;

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
    return self.filteredUsersToAdd.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UserCell *cell = [self.usersToAddTableView dequeueReusableCellWithIdentifier:@"UserCell"];
    PFUser *user = self.filteredUsersToAdd[indexPath.row];
    cell.user = user;
    [cell refreshData];
    [cell.button setImage:[UIImage systemImageNamed:@"plus"] forState:UIControlStateNormal];
    cell.delegate = self;
    return cell;
}

- (void)tagRemoveButtonPressed:(NSString *)title tagView:(TagView *)tagView sender:(TagListView *)sender {
    int index = (int)[sender.tagViews indexOfObject:tagView];
    [self removeUserFromGroup:self.usersInGroup[index]];
}

- (void)addUserToGroup:(PFUser *)user {
    [self.usersInGroup addObject:user];
    [self.usersTagListView addTag:[self getFullName:user]];
    [self.usersToAdd removeObject:user];
    [self filterUsers];
    [self.usersToAddTableView reloadData];
}

- (void)removeUserFromGroup:(PFUser *)user {
    [self.usersInGroup removeObject:user];
    [self.usersTagListView removeTag:[self getFullName:user]];
    [self.usersToAdd addObject:user];
    [self filterUsers];
    [self sortFilteredUsersByName];
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
        NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(PFUser *user, NSDictionary *bindings) {
            NSString *fullName = [self getFullName:user];
            return [[fullName lowercaseString] hasPrefix:[self.searchField.text lowercaseString]] || [[user[@"lastName"] lowercaseString] hasPrefix:[self.searchField.text lowercaseString]];
        }];
        self.filteredUsersToAdd = [self.usersToAdd filteredArrayUsingPredicate:predicate];
    } else {
        self.filteredUsersToAdd = [self.usersToAdd copy];
    }
    [self.usersToAddTableView reloadData];
}

- (NSString *)getFullName:(PFUser *)user {
     return [NSString stringWithFormat:@"%@ %@", user[@"firstName"], user[@"lastName"]];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.groupNameField endEditing:YES];
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
