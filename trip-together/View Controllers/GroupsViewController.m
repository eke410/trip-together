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

@interface GroupsViewController () <CreateGroupViewControllerDelegate, GroupDetailsViewControllerDelegate, UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) NSMutableArray *groups;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation GroupsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    PFQuery *query = [PFQuery queryWithClassName:@"Group"];
    [query orderByDescending:@"startDate"];
    [query includeKey:@"users"];
    [query whereKey:@"users" containsAllObjectsInArray:[[NSArray alloc] initWithObjects:PFUser.currentUser, nil]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *groups, NSError *error) {
        if (groups != nil) {
            self.groups = (NSMutableArray *)groups;
            [self.tableView reloadData];
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
    }];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
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
    
    // if no photo, pass in gradient layer for cell background
    if (!cell.group.photo) {
        CAGradientLayer *gradient = [self gradientForCellAtIndexPath:indexPath];
        gradient.frame = cell.contentView.frame;
        cell.gradientLayer = gradient;
    }
    
    [cell refreshData];
    return cell;
}

- (CAGradientLayer *)gradientForCellAtIndexPath:(NSIndexPath *)indexPath {
    float index = indexPath.section * 1.0;
    float total = self.groups.count;
    
    float r1 = 86/255.0, g1 = 207/255.0, b1= 225/255.0;
    float r2 = 83/255.0, g2 = 144/255.0, b2= 217/255.0;

    float r3 = r1 + (index/total) * (r2 - r1);
    float g3 = g1 + (index/total) * (g2 - g1);
    float b3 = b1 + (index/total) * (b2 - b1);
    
    float r4 = r1 + ((index+1)/total) * (r2 - r1);
    float g4 = g1 + ((index+1)/total) * (g2 - g1);
    float b4 = b1 + ((index+1)/total) * (b2 - b1);
        
//    NSLog(@"index %f: %f %f %f", index, r3, g3, b3);
//    NSLog(@"4: %f %f %f", r4, g4, b4);
    
    UIColor *color1 = [UIColor colorWithRed:r3 green:g3 blue:b3 alpha:1];
    UIColor *color2 = [UIColor colorWithRed:r4 green:g4 blue:b4 alpha:1];
    
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.cornerRadius = 10;
    gradient.colors = @[(id)[color1 CGColor], (id)[color2 CGColor]];
    return gradient;
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
