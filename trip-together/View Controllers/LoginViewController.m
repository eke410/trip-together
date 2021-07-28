//
//  LoginViewController.m
//  trip-together
//
//  Created by Elizabeth Ke on 7/12/21.
//

#import "LoginViewController.h"
#import "Parse/Parse.h"
#import "SceneDelegate.h"
#import "Shift-Swift.h"

@interface LoginViewController ()

@property (weak, nonatomic) IBOutlet ShiftButton_Objc *tripTogetherButton;
@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationController.navigationBar setHidden:YES];
    
    [self.tripTogetherButton setColors: @[
        [UIColor colorWithRed:83/255.0 green:144/255.0 blue:217/255.0 alpha:1],
        [UIColor colorWithRed:127/255.0 green:75/255.0 blue:210/255.0 alpha:1]
    ]];
    [self.tripTogetherButton animationDuration:1.5];
    [self.tripTogetherButton startTimedAnimation];
    [self.tripTogetherButton setMaskToText:true];
}

- (IBAction)loginUser:(id)sender {
    NSString *username = self.usernameField.text;
    NSString *password = self.passwordField.text;
    
    [PFUser logInWithUsernameInBackground:username password:password block:^(PFUser * user, NSError *  error) {
        if (error != nil) {
            NSLog(@"User log in failed: %@", error.localizedDescription);
        } else {
            NSLog(@"User logged in successfully");
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            UIViewController *tabBarController = [storyboard instantiateViewControllerWithIdentifier:@"TabBarController"];
            SceneDelegate *sceneDelegate = (SceneDelegate *)self.view.window.windowScene.delegate;
            [sceneDelegate changeRootViewController:tabBarController];
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
