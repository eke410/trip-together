//
//  RegisterViewController.m
//  trip-together
//
//  Created by Elizabeth Ke on 7/16/21.
//

#import "RegisterViewController.h"
#import "Parse/Parse.h"
#import "SceneDelegate.h"

@interface RegisterViewController ()

@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *firstNameField;
@property (weak, nonatomic) IBOutlet UITextField *lastNameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;

@end

@implementation RegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // sets gradient background
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.view.bounds;
    gradient.startPoint = CGPointZero;
    gradient.endPoint = CGPointMake(1, 1);
    gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor colorWithRed:34.0/255.0 green:211/255.0 blue:198/255.0 alpha:1.0] CGColor],(id)[[UIColor colorWithRed:145/255.0 green:72.0/255.0 blue:203/255.0 alpha:1.0] CGColor], nil];
    [self.view.layer insertSublayer:gradient atIndex:0];
}

- (IBAction)registerUser:(id)sender {
    // initialize a user object, set user properties
    PFUser *newUser = [PFUser user];
    newUser.username = self.usernameField.text;
    newUser[@"firstName"] = self.firstNameField.text;
    newUser[@"lastName"] = self.lastNameField.text;
    newUser.password = self.passwordField.text;
    
    // call sign up function on the object
    [newUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError * error) {
        if (error != nil) {
            NSLog(@"Error: %@", error.localizedDescription);
        } else {
            NSLog(@"User registered successfully");
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            UIViewController *tabBarController = [storyboard instantiateViewControllerWithIdentifier:@"TabBarController"];
            SceneDelegate *sceneDelegate = (SceneDelegate *)self.view.window.windowScene.delegate;
            [sceneDelegate changeRootViewController:tabBarController];        }
    }];
}

- (IBAction)tappedLoginButton:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
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
