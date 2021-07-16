//
//  SceneDelegate.h
//  trip-together
//
//  Created by Elizabeth Ke on 7/12/21.
//

#import <UIKit/UIKit.h>

@interface SceneDelegate : UIResponder <UIWindowSceneDelegate>

@property (strong, nonatomic) UIWindow * window;

- (void)changeRootViewController:(UIViewController*)viewController;

@end

