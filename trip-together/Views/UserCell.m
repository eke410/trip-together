//
//  UserCell.m
//  trip-together
//
//  Created by Elizabeth Ke on 7/12/21.
//

#import "UserCell.h"

@implementation UserCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)clickedButton:(id)sender {
    // TODO: add user to group (set up protocol)?
    NSLog(@"clicked button");
    
}

@end
