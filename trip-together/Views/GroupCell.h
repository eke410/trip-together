//
//  GroupCell.h
//  trip-together
//
//  Created by Elizabeth Ke on 7/12/21.
//

#import <UIKit/UIKit.h>
#import "Group.h"

NS_ASSUME_NONNULL_BEGIN

@interface GroupCell : UITableViewCell

@property (strong, nonatomic) Group *group;

@property (weak, nonatomic) IBOutlet UILabel *groupNameLabel;
@property (strong, nonatomic) UIView *photoView;
@property (strong, nonatomic) CAGradientLayer *gradientLayer;
 
- (void)refreshData;

@end

NS_ASSUME_NONNULL_END
