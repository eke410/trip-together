//
//  AppDelegate.m
//  trip-together
//
//  Created by Elizabeth Ke on 7/12/21.
//

#import "AppDelegate.h"
#import "Parse/Parse.h"
@import GooglePlaces;
@import PopupDialog;

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    // Parse configuration
    ParseClientConfiguration *config = [ParseClientConfiguration  configurationWithBlock:^(id<ParseMutableClientConfiguration> configuration) {

        configuration.applicationId = @"e8bZUwithsizg4ropB42ehxIaMHrKKSU3y2rxtyY"; // <- UPDATE
        configuration.clientKey = @"UazQSFlOHdOsxuDAn2mv5n0boskl6po5RnqtXr3E"; // <- UPDATE
        configuration.server = @"https://parseapi.back4app.com";
    }];
    [Parse initializeWithConfiguration:config];
    
    // Sets Google API Key
    NSString *path = [[NSBundle mainBundle] pathForResource: @"Keys" ofType: @"plist"];
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile: path];
    NSString *googleAPIKey= [dict objectForKey: @"googleAPIKey"];
    [GMSPlacesClient provideAPIKey:googleAPIKey];
    
    // customizes design of alert popups
    PopupDialogDefaultView *dialogAppearance = [PopupDialogDefaultView appearance];
    dialogAppearance.titleFont = [UIFont systemFontOfSize:17 weight:UIFontWeightMedium];
    dialogAppearance.titleColor = [UIColor blackColor];
    dialogAppearance.messageFont = [UIFont systemFontOfSize:15];

    PopupDialogContainerView *containerAppearance = [PopupDialogContainerView appearance];
    containerAppearance.cornerRadius = 20;

    PopupDialogOverlayView *overlayAppearance = [PopupDialogOverlayView appearance];
    overlayAppearance.blurEnabled = false;
    overlayAppearance.opacity = 0.5;
    
    DefaultButton *defaultButtonAppearance = [DefaultButton appearance];
    defaultButtonAppearance.titleFont = [UIFont systemFontOfSize:15];
    defaultButtonAppearance.titleColor = [UIColor darkGrayColor];
    
    CancelButton *cancelButtonAppearance = [CancelButton appearance];
    cancelButtonAppearance.titleFont = [UIFont systemFontOfSize:15];

    DestructiveButton *destructiveButtonAppearance = [DestructiveButton appearance];
    destructiveButtonAppearance.titleFont = [UIFont systemFontOfSize:15];
    
    return YES;
}


#pragma mark - UISceneSession lifecycle


- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options {
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
}


- (void)application:(UIApplication *)application didDiscardSceneSessions:(NSSet<UISceneSession *> *)sceneSessions {
    // Called when the user discards a scene session.
    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
}


@end
