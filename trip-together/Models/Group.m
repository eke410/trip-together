//
//  Group.m
//  trip-together
//
//  Created by Elizabeth Ke on 7/12/21.
//

#import "Group.h"

@implementation Group

@dynamic users;
@dynamic name;
@dynamic location;
@dynamic startDate;
@dynamic endDate;
@dynamic photo;

+ (nonnull NSString *)parseClassName {
    return @"Group";
}

+ (Group *)postGroupWithUsers:(NSArray * _Nullable)users withName:(NSString * _Nullable)name withLocation:(NSString * _Nullable)location withStartDate:(NSDate * _Nullable)startDate withEndDate:(NSDate * _Nullable)endDate withCompletion:(PFBooleanResultBlock _Nullable)completion {
    Group *newGroup = [Group new];
    newGroup.users = users;
    newGroup.name = name;
    newGroup.location = location;
    newGroup.startDate = startDate;
    newGroup.endDate = endDate;

    [newGroup saveInBackgroundWithBlock:completion];
    
    return newGroup;
}

+ (PFFileObject *)getPFFileFromImage: (UIImage * _Nullable)image {
 
    // check if image is not nil
    if (!image) {
        return nil;
    }
    
    NSData *imageData = UIImagePNGRepresentation(image);
    // get image data and check if that is not nil
    if (!imageData) {
        return nil;
    }
    
    return [PFFileObject fileObjectWithName:@"image.png" data:imageData];
}

+ (UIImage *)resizeImage:(UIImage *)image withSize:(CGSize)size {
    UIImageView *resizeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    
    resizeImageView.contentMode = UIViewContentModeScaleAspectFill;
    resizeImageView.image = image;
    
    UIGraphicsBeginImageContext(size);
    [resizeImageView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

@end
