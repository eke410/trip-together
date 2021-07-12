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
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)refreshData {
    self.groupNameLabel.text = self.group.name;
}

@end
