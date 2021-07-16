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

- (void)refreshData {
    self.fullNameLabel.text = [NSString stringWithFormat:@"%@ %@", self.user[@"firstName"], self.user[@"lastName"]];

    PFFileObject *photo = self.user[@"photo"];
    if (photo) {
        [photo getDataInBackgroundWithBlock:^(NSData * _Nullable imageData, NSError * _Nullable error) {
            self.photoImageView.image =  [UIImage imageWithData:imageData];
        }];
    } else {
        self.photoImageView.image = [UIImage imageNamed:@"profile_icon"];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)clickedButton:(id)sender {
    if (self.button.imageView.image == [UIImage systemImageNamed:@"plus"]) {
        [self.delegate addUserToGroup:self.user];
    } else if (self.button.imageView.image == [UIImage systemImageNamed:@"minus"]) {
        [self.delegate removeUserFromGroup:self.user];
    }
}

@end
