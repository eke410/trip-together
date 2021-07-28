//
//  TimelineCell.h
//  trip-together
//
//  Created by Elizabeth Ke on 7/27/21.
//

#import <UIKit/UIKit.h>
#import "Event.h"

NS_ASSUME_NONNULL_BEGIN

@interface TimelineCell : UITableViewCell

@property (strong, nonatomic) Event *event;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *timelinePoint;
@property (weak, nonatomic) IBOutlet UIImageView *timelineLine;

- (void)refreshData;

@end

NS_ASSUME_NONNULL_END
