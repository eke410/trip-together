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
    
    self.containerView.layer.cornerRadius = 10;
    self.containerView.layer.shadowOpacity = 0.3;
    self.containerView.layer.shadowRadius = 2;
    self.containerView.layer.shadowColor = [[UIColor darkGrayColor] CGColor];
    self.containerView.layer.shadowOffset = CGSizeZero;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)refreshData {
    self.nameLabel.text = self.event.name;
    self.locationLabel.text = self.event.location;
    
    if (self.event.startTime.dayOfYear == self.event.endTime.dayOfYear) {
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
    
    if ([self.event.type isEqualToString:@"attraction"]) {
        [self.typeImageView setImage:[UIImage imageNamed:@"attraction_icon"]];
        self.typeImageView.backgroundColor = [UIColor colorWithRed:114/255.0 green:205/255.0 blue:233/255.0 alpha:1];
    } else {
        [self.typeImageView setImage:[UIImage imageNamed:@"restaurant_icon"]];
        self.typeImageView.backgroundColor = [UIColor colorWithRed:185/255.0 green:157/255.0 blue:231/255.0 alpha:1];

    }
}

@end
