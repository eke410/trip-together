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
    self.categoriesTagListView.textFont = [UIFont systemFontOfSize:10];
    
    self.containerView.layer.cornerRadius = 10;
    self.containerView.layer.shadowOpacity = 0.2;
    self.containerView.layer.shadowRadius = 4;
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
    
    for (NSDictionary *category in self.event.categories) {
        [self.categoriesTagListView addTag:category[@"title"]];
    }
    
    [self.ratingImageView setImage:[UIImage imageNamed:[self.event.rating stringByAppendingString:@"_star"]]];
    
    NSURL *url = [NSURL URLWithString:self.event.imageURLString];
    [self.photoImageView setImageWithURL:url];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    [self.categoriesTagListView removeAllTags];
    self.photoImageView.image = nil;
}

@end
