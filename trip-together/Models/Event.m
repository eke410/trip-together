//
//  Event.m
//  trip-together
//
//  Created by Elizabeth Ke on 7/13/21.
//

#import "Event.h"

@implementation Event

@dynamic name;
@dynamic summary;
@dynamic group;
@dynamic eventSiteURLString;
@dynamic ticketsURLString;
@dynamic location;
@dynamic startTime;
@dynamic endTime;
@dynamic imageURLString;

+ (nonnull NSString *)parseClassName {
    return @"Event";
}

+ (void) postEventWithName:(NSString * _Nullable)name withSummary:(NSString *)summary withGroup:(Group *)group withCompletion:(PFBooleanResultBlock _Nullable)completion {
    Event *newEvent = [Event new];
    newEvent.name = name;
    newEvent.summary = summary;
    newEvent.group = group;

    [newEvent saveInBackgroundWithBlock:completion];
}


@end
