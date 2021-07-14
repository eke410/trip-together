//
//  GroupDetailsViewController.h
//  trip-together
//
//  Created by Elizabeth Ke on 7/12/21.
//

#import <UIKit/UIKit.h>
#import "Group.h"

NS_ASSUME_NONNULL_BEGIN

@protocol GroupDetailsViewControllerDelegate <NSObject>

- (void)removeGroup:(Group *)group;

@end

@interface GroupDetailsViewController : UIViewController

@property (strong, nonatomic) Group *group;
@property (nonatomic, weak) id<GroupDetailsViewControllerDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
