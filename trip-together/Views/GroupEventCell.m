//
//  GroupEventCell.m
//  trip-together
//
//  Created by Elizabeth Ke on 7/15/21.
//

#import "GroupEventCell.h"
#import "UIImageView+AFNetworking.h"

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
    self.ratingLabel.text = [NSString stringWithFormat: @"%@/5", self.event.rating];
    

    self.timeLabel.text = @"Aug 1 to Aug 2";
    
    NSURL *url = [NSURL URLWithString:self.event.imageURLString];
    [self.photoImageView setImageWithURL:url];
}

@end
