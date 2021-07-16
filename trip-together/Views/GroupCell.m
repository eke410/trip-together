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
    
    // sets cell shadow
//    self.containerView.layer.cornerRadius = 10;
//    self.containerView.layer.shadowOpacity = 1;
//    self.containerView.layer.shadowRadius = 1;
//    self.containerView.layer.shadowColor = [[self colorWithHexString:@"#123054" alpha:1.0] CGColor];
//    self.containerView.layer.shadowOffset = CGSizeMake(2, 2);
    
    // sets cell background gradient
//    CAGradientLayer *gradient = [CAGradientLayer layer];
//    gradient.frame = self.containerView.bounds;
//    gradient.cornerRadius = 10;
//    gradient.colors = @[(id)[[self colorWithHexString:@"#367DD3" alpha:1.0] CGColor], (id)[[self colorWithHexString:@"#2869B8" alpha:1.0] CGColor]];
//    [self.containerView.layer insertSublayer:gradient atIndex:0];
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
}

@end
