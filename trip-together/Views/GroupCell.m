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
}

- (UIColor *)colorWithHexString:(NSString *)str_HEX  alpha:(CGFloat)alpha_range{
    int red = 0;
    int green = 0;
    int blue = 0;
    sscanf([str_HEX UTF8String], "#%02X%02X%02X", &red, &green, &blue);
    return  [UIColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:alpha_range];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)refreshData {
    self.groupNameLabel.text = self.group.name;
    
    if (self.group.photo) {
        // if group photo exists, set photo as background
        [self.group.photo getDataInBackgroundWithBlock:^(NSData * _Nullable imageData, NSError * _Nullable error) {
            self.photoView = [[UIImageView alloc] initWithImage:[UIImage imageWithData:imageData]];
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
