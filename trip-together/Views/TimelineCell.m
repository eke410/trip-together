//
//  TimelineCell.m
//  trip-together
//
//  Created by Elizabeth Ke on 7/27/21.
//

#import "TimelineCell.h"
#import "DateTools.h"

@implementation TimelineCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.timelinePoint.layer.borderWidth = 2;
    self.timelinePoint.layer.borderColor = [[UIColor colorWithRed:138/255.0 green:179/255.0 blue:229/255.0 alpha:1] CGColor];
    self.timelinePoint.layer.cornerRadius = self.timelinePoint.frame.size.width/2;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)refreshData {
    self.nameLabel.text = self.event.name;

    if (self.event.startTime.dayOfYear == self.event.endTime.dayOfYear) {
        NSString *startTimeString = [self.event.startTime formattedDateWithFormat:@"MMM d, h:mm a"];
        NSString *endTimeString = [self.event.endTime formattedDateWithFormat:@"h:mm a"];
        self.timeLabel.text = [NSString stringWithFormat:@"%@ - %@", startTimeString, endTimeString];
    } else {
        NSString *startTimeString = [self.event.startTime formattedDateWithFormat:@"MMM d, h:mm a"];
        NSString *endTimeString = [self.event.endTime formattedDateWithFormat:@"MMM d, h:mm a"];
        self.timeLabel.text = [NSString stringWithFormat:@"%@ - %@", startTimeString, endTimeString];
    }
}


@end
