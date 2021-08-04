//
//  GroupsViewController.m
//  trip-together
//
//  Created by Elizabeth Ke on 7/12/21.
//

#import "GroupsViewController.h"
#import "GroupCell.h"
#import "GroupDetailsViewController.h"
#import "CreateGroupViewController.h"
#import "UIScrollView+EmptyDataSet.h"

@interface GroupsViewController () <CreateGroupViewControllerDelegate, GroupDetailsViewControllerDelegate, UITableViewDataSource, UITableViewDelegate, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate>

@property (strong, nonatomic) NSMutableArray *groups;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property BOOL isQueryingGroups;

@end

@implementation GroupsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.isQueryingGroups = true;
    [self refreshGroups];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.emptyDataSetSource = self;
    self.tableView.emptyDataSetDelegate = self;
    
    self.refreshControl = [UIRefreshControl new];
    [self.refreshControl addTarget:self action:@selector(refreshGroups) forControlEvents:UIControlEventValueChanged];
    [self.tableView insertSubview:self.refreshControl atIndex:0];
}

- (void)refreshGroups {
    self.isQueryingGroups = true;
    PFQuery *query = [PFQuery queryWithClassName:@"Group"];
    [query orderByDescending:@"startDate"];
    [query includeKey:@"users"];
    [query whereKey:@"users" containsAllObjectsInArray:[[NSArray alloc] initWithObjects:PFUser.currentUser, nil]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *groups, NSError *error) {
        if (groups != nil) {
            self.groups = (NSMutableArray *)groups;
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
        [self.refreshControl endRefreshing];
        self.isQueryingGroups = false;
        [self.tableView reloadData];
    }];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.groups.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GroupCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"GroupCell"];
    cell.group = self.groups[indexPath.section];
    [cell refreshData];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 10.;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = [[UIView alloc] init];
    headerView.backgroundColor = [UIColor clearColor];
    return headerView;
}

- (void)didCreateGroup:(Group *)group {
    [self.groups insertObject:group atIndex:0];
    [self.tableView reloadData];
    [self performSegueWithIdentifier:@"groupDetailsSegue" sender:group];
}

- (void)removeGroup:(Group *)group {
    [self.groups removeObject:group];
    [self.tableView reloadData];
}

- (void)updateCellForGroup:(Group *)group {
    NSUInteger index = [self.groups indexOfObject:group];
    NSIndexSet *indexSet = [[NSIndexSet alloc] initWithIndex:index];
    [self.tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationNone];
}

#pragma mark - Empty Table View Customization

- (UIImage *)imageForEmptyDataSet:(UIScrollView *)scrollView {
    if (self.isQueryingGroups) {
        return nil;
    }
    return [UIImage imageNamed:@"group_image"];
}

- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView {
    if (self.isQueryingGroups) {
        return nil;
    }
    NSString *text = @"You're not part of any groups yet";
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:18.0f weight:UIFontWeightMedium],
                                 NSForegroundColorAttributeName: [UIColor darkGrayColor]};
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

- (NSAttributedString *)descriptionForEmptyDataSet:(UIScrollView *)scrollView {
    if (self.isQueryingGroups) {
        return nil;
    }
    NSString *text = @"Create a group to get started.";
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:16.0f],
                                 NSForegroundColorAttributeName: [UIColor lightGrayColor]};
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

- (CGFloat)verticalOffsetForEmptyDataSet:(UIScrollView *)scrollView {
    return -50.0f;
}

- (CGFloat)spaceHeightForEmptyDataSet:(UIScrollView *)scrollView {
    return 8.0f;
}

- (BOOL)emptyDataSetShouldAllowScroll:(UIScrollView *)scrollView {
    return YES;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"groupDetailsSegue"]) {
        GroupDetailsViewController *groupDetailsViewController = [segue destinationViewController];
        groupDetailsViewController.delegate = self;
        if ([sender isKindOfClass:[GroupCell class]]) { // segue sent from table view cell being clicked
            NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
            groupDetailsViewController.group = self.groups[indexPath.section];
        } else if ([sender isKindOfClass:[Group class]]) { // segue sent from create group delegate method
            groupDetailsViewController.group = sender;
        }
    } else if ([segue.identifier isEqualToString: @"createGroupSegue"]) {
        CreateGroupViewController *createGroupViewController = [segue destinationViewController];
        createGroupViewController.delegate = self;
    }
}


@end
