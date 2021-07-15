//
//  EventCell.m
//  trip-together
//
//  Created by Elizabeth Ke on 7/13/21.
//

#import "EventCell.h"
#import "UIImageView+AFNetworking.h"

@implementation EventCell

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
    
    NSURL *url = [NSURL URLWithString:self.event.imageURLString];
    [self.photoImageView setImageWithURL:url];
}

@end
