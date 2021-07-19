//
//  Group.h
//  trip-together
//
//  Created by Elizabeth Ke on 7/12/21.
//

#import <Foundation/Foundation.h>
#import "Parse/Parse.h"

NS_ASSUME_NONNULL_BEGIN

@interface Group : PFObject<PFSubclassing>

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSArray *users;
@property (nonatomic, strong) NSString *location;
@property (nonatomic, strong) NSDate *startDate;
@property (nonatomic, strong) NSDate *endDate;
@property (nonatomic, strong) PFFileObject *photo;

+ (Group *)postGroupWithUsers:(NSArray * _Nullable)users withName:(NSString * _Nullable)name withLocation:(NSString * _Nullable)location withStartDate:(NSDate * _Nullable)startDate withEndDate:(NSDate * _Nullable)endDate withCompletion:(PFBooleanResultBlock _Nullable)completion;
+ (PFFileObject *)getPFFileFromImage: (UIImage * _Nullable)image;
+ (UIImage *)resizeImage:(UIImage *)image withSize:(CGSize)size;

@end

NS_ASSUME_NONNULL_END
