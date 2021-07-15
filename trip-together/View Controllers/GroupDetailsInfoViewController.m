//
//  GroupDetailsInfoViewController.m
//  trip-together
//
//  Created by Elizabeth Ke on 7/15/21.
//

#import "GroupDetailsInfoViewController.h"

@interface GroupDetailsInfoViewController ()

@end

@implementation GroupDetailsInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (IBAction)leaveGroup:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
    [self.delegate removeGroup:self.group];

    if (self.group.users.count == 1) { // if only 1 user, delete group
        [self.group deleteInBackground];
    } else { // if more than 1 user, remove user from group
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
