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
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UITableView *usersToAddTableView;
@property (weak, nonatomic) IBOutlet UITextField *searchField;
@property (weak, nonatomic) IBOutlet UIButton *createGroupButton;

@property (strong, nonatomic) NSMutableArray *usersInGroup;
@property (strong, nonatomic) NSMutableArray *usersToAdd;
@property (strong, nonatomic) NSArray *filteredUsersToAdd;

@end

@implementation CreateGroupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.usersToAddTableView.dataSource = self;
    self.usersToAddTableView.delegate = self;
    self.groupNameField.layer.borderColor = [[UIColor systemGray3Color] CGColor];
    
    self.usersInGroup = [[NSMutableArray alloc] initWithObjects:PFUser.currentUser, nil];
    [self.usersTagListView addTag: [self getFullName:PFUser.currentUser]];
    self.usersTagListView.textFont = [UIFont systemFontOfSize:17];
    self.usersTagListView.delegate = self;
    
    TagView *firstTagView = self.usersTagListView.tagViews[0];
    firstTagView.enableRemoveButton = false;
    [self setTagViewGradientForTagAtIndex:0];
    
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.createGroupButton.bounds;
    gradient.startPoint = CGPointMake(0, 1);
    gradient.endPoint = CGPointMake(0, 0);
    gradient.cornerRadius = 18;
    gradient.colors = @[(id)[[UIColor colorWithRed:78/255.0 green:168/255.0 blue:222/255.0 alpha:1] CGColor], (id)[[UIColor colorWithRed:100/255.0 green:178/255.0 blue:227/255.0 alpha:1] CGColor]];
    [self.createGroupButton.layer insertSublayer:gradient atIndex:0];

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
    [self sortByName:self.usersInGroup];
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
    [self setTagViewGradientForTagAtIndex:(int)self.usersTagListView.tagViews.count-1];
    [self.usersToAdd removeObject:user];
    [self filterUsers];
    [self.usersToAddTableView reloadData];
    
    if (self.scrollView.frame.size.height < self.usersTagListView.intrinsicContentSize.height) { // scroll to bottom
        CGPoint bottomOffset = CGPointMake(0, self.usersTagListView.intrinsicContentSize.height - self.scrollView.bounds.size.height + self.scrollView.contentInset.bottom);
        [self.scrollView setContentOffset:bottomOffset animated:YES];
    }
}

- (void)removeUserFromGroup:(PFUser *)user {
    [self.usersInGroup removeObject:user];
    [self.usersTagListView removeTag:[self getFullName:user]];
    [self.usersToAdd addObject:user];
    [self sortByName:self.usersToAdd];
    [self filterUsers];
    [self.usersToAddTableView reloadData];
}

- (void)sortByName:(NSMutableArray *)users {
    NSSortDescriptor *firstNameSorter = [[NSSortDescriptor alloc] initWithKey:@"firstName" ascending:true];
    NSSortDescriptor *lastNameSorter = [[NSSortDescriptor alloc] initWithKey:@"lastName" ascending:true];
    [users sortUsingDescriptors:@[firstNameSorter, lastNameSorter]];
}

- (void)setTagViewGradientForTagAtIndex:(int)index {
    TagView *tagView = self.usersTagListView.tagViews[index];
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = tagView.frame;
    gradient.startPoint = CGPointMake(0, 1);
    gradient.endPoint = CGPointMake(0, 0);
    gradient.colors = @[(id)[[UIColor colorWithRed:78/255.0 green:168/255.0 blue:222/255.0 alpha:1] CGColor], (id)[[UIColor colorWithRed:100/255.0 green:178/255.0 blue:227/255.0 alpha:1] CGColor]];
    [tagView.layer insertSublayer:gradient atIndex:0];
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
