//
//  RegisterViewController.m
//  trip-together
//
//  Created by Elizabeth Ke on 7/16/21.
//

#import "RegisterViewController.h"
#import "Parse/Parse.h"
#import "SceneDelegate.h"
#import "Shift-Swift.h"

@interface RegisterViewController ()

@property (weak, nonatomic) IBOutlet ShiftButton_Objc *welcomeButton;
@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *firstNameField;
@property (weak, nonatomic) IBOutlet UITextField *lastNameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;

@end

@implementation RegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.welcomeButton setColors: @[
        [UIColor colorWithRed:83/255.0 green:144/255.0 blue:217/255.0 alpha:1],
        [UIColor colorWithRed:127/255.0 green:75/255.0 blue:210/255.0 alpha:1]
    ]];
    [self.welcomeButton animationDuration:1.5];
    [self.welcomeButton startTimedAnimation];
    [self.welcomeButton setMaskToText:true];
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

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.usernameField endEditing:YES];
    [self.firstNameField endEditing:YES];
    [self.lastNameField endEditing:YES];
    [self.passwordField endEditing:YES];
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
