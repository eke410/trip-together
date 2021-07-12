//
//  UserCell.h
//  trip-together
//
//  Created by Elizabeth Ke on 7/12/21.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UserCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UIButton *button;

@end

NS_ASSUME_NONNULL_END
