//
//  GroupCell.m
//  trip-together
//
//  Created by Elizabeth Ke on 7/12/21.
//

#import "GroupCell.h"

@implementation GroupCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.contentView.layer.cornerRadius = 10;
    [self.contentView setClipsToBounds:YES];
    
    // set gradient layer
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.contentView.frame;
    gradient.cornerRadius = 10;
    gradient.colors = @[(id)[[UIColor colorWithRed:100/255.0 green:178/255.0 blue:227/255.0 alpha:1] CGColor], (id)[[UIColor colorWithRed:78/255.0 green:168/255.0 blue:222/255.0 alpha:1] CGColor]];
    self.gradientLayer = gradient;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)refreshData {
    self.groupNameLabel.text = self.group.name;
    
    if (self.group.photo) {
        // if group photo exists, remove any gradient layers and set photo as background
        for (CALayer *layer in [self.contentView.layer.sublayers copy]) {
            if ([layer isKindOfClass:[CAGradientLayer class]]) {
                [layer removeFromSuperlayer];
            }
        }
        [self.group.photo getDataInBackgroundWithBlock:^(NSData * _Nullable imageData, NSError * _Nullable error) {
            self.photoView = [[UIImageView alloc] initWithImage:[UIImage imageWithData:imageData]];
            self.photoView.alpha = 0.85;
            [self.contentView addSubview:self.photoView];
            [self.contentView bringSubviewToFront:self.groupNameLabel];
        }];
    } else {
        // if no group photo, set gradient as background
        [self.contentView.layer insertSublayer:self.gradientLayer atIndex:0];
    }
    
}

- (void)prepareForReuse {
    [super prepareForReuse];
    if (self.group.photo) {
        [self.photoView removeFromSuperview];
    } else {
        [self.gradientLayer removeFromSuperlayer];
    }
}

@end
