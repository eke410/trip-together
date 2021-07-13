//
//  CreateGroupViewController.h
//  trip-together
//
//  Created by Elizabeth Ke on 7/12/21.
//

#import <UIKit/UIKit.h>
#import "Group.h"

NS_ASSUME_NONNULL_BEGIN

@protocol CreateGroupViewControllerDelegate <NSObject>

- (void)didCreateGroup:(Group *)group;

@end

@interface CreateGroupViewController : UIViewController

@property (nonatomic, weak) id<CreateGroupViewControllerDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
