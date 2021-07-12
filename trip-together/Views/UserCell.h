//
//  UserCell.h
//  trip-together
//
//  Created by Elizabeth Ke on 7/12/21.
//

#import <UIKit/UIKit.h>
#import "Parse/Parse.h"

NS_ASSUME_NONNULL_BEGIN

@protocol UserCellDelegate

- (void)addUserToGroup:(PFUser *)user;
- (void)removeUserFromGroup:(PFUser *)user;

@end
    

@interface UserCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UIButton *button;

@property (strong, nonatomic) PFUser *user;
@property (nonatomic, weak) id<UserCellDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
