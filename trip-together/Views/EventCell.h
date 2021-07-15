//
//  EventCell.h
//  trip-together
//
//  Created by Elizabeth Ke on 7/13/21.
//

#import <UIKit/UIKit.h>
#import "Event.h"

NS_ASSUME_NONNULL_BEGIN

@interface EventCell : UITableViewCell

@property (nonatomic, strong) Event *event;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *photoImageView;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet UILabel *ratingLabel;

- (void)refreshData;

@end

NS_ASSUME_NONNULL_END
