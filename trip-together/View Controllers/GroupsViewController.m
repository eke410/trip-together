//
//  GroupsViewController.m
//  trip-together
//
//  Created by Elizabeth Ke on 7/12/21.
//

#import "GroupsViewController.h"
#import "GroupCell.h"
#import "GroupDetailsViewController.h"

@interface GroupsViewController () <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) NSArray *groups;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation GroupsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    PFQuery *query = [PFQuery queryWithClassName:@"Group"];
    [query orderByDescending:@"startDate"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *groups, NSError *error) {
        if (groups != nil) {
            self.groups = groups;
            [self.tableView reloadData];
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
    }];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.groups.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GroupCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"GroupCell"];
    cell.group = self.groups[indexPath.row];
    [cell refreshData];
    return cell;
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    GroupDetailsViewController *groupDetailsViewController = [segue destinationViewController];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];

    NSLog(@"%@", self.groups);
    NSLog(@"%@", indexPath.row);
    // TODO: figure out why indexPath.row returning (null) in GroupsViewController
    
    groupDetailsViewController.group = self.groups[indexPath.row];

}


@end
