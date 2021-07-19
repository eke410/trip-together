//
//  GroupDetailsInfoViewController.h
//  trip-together
//
//  Created by Elizabeth Ke on 7/15/21.
//

#import <UIKit/UIKit.h>
#import "Group.h"

NS_ASSUME_NONNULL_BEGIN

@protocol GroupDetailsInfoViewControllerDelegate <NSObject>

- (void)removeGroup:(Group *)group;
- (void)changePhoto:(UIImage *)photo;

@end

@interface GroupDetailsInfoViewController : UIViewController

@property (strong, nonatomic) Group *group;
@property (nonatomic, weak) id<GroupDetailsInfoViewControllerDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
