//
//  GroupEventCell.m
//  trip-together
//
//  Created by Elizabeth Ke on 7/15/21.
//

#import "GroupEventCell.h"
#import "UIImageView+AFNetworking.h"
#import "DateTools.h"

@implementation GroupEventCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)refreshData {
    self.nameLabel.text = self.event.name;
    self.locationLabel.text = self.event.location;
    
    if (self.event.startTime.month == self.event.endTime.month) {
        NSString *startTimeString = [self.event.startTime formattedDateWithFormat:@"MMM d, h:mm a"];
        NSString *endTimeString = [self.event.endTime formattedDateWithFormat:@"h:mm a"];
        self.timeLabel.text = [NSString stringWithFormat:@"%@ - %@", startTimeString, endTimeString];
    } else {
        NSString *startTimeString = [self.event.startTime formattedDateWithFormat:@"MMM d, h:mm a"];
        NSString *endTimeString = [self.event.endTime formattedDateWithFormat:@"MMM d, h:mm a"];
        self.timeLabel.text = [NSString stringWithFormat:@"%@ - %@", startTimeString, endTimeString];
    }

        
    NSURL *url = [NSURL URLWithString:self.event.imageURLString];
    [self.photoImageView setImageWithURL:url];
}

@end
