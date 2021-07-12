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

+ (nonnull NSString *)parseClassName {
    return @"Group";
}

+ (void)postGroupWithUsers:(NSArray * _Nullable)users withName:(NSString * _Nullable)name withLocation:(NSString * _Nullable)location withStartDate:(NSDate * _Nullable)startDate withEndDate:(NSDate * _Nullable)endDate withCompletion:(PFBooleanResultBlock _Nullable)completion {
    Group *newGroup = [Group new];
    newGroup.users = users;
    newGroup.name = name;
    newGroup.location = location;
    newGroup.startDate = startDate;
    newGroup.endDate = endDate;

    [newGroup saveInBackgroundWithBlock:completion];
}

@end
