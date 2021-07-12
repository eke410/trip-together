//
//  CreateGroupViewController.m
//  trip-together
//
//  Created by Elizabeth Ke on 7/12/21.
//

#import "CreateGroupViewController.h"
#import "Group.h"

@interface CreateGroupViewController ()

@end

@implementation CreateGroupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
