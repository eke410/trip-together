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

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        self.name = dictionary[@"name"];
        self.summary = dictionary[@"description"];
        self.eventSiteURLString = dictionary[@"event_site_url"];
        self.ticketsURLString = dictionary[@"tickets_url"];
        self.location = dictionary[@"location"];
        self.startTime = dictionary[@"time_start"];
        self.endTime = dictionary[@"time_end"];
        self.imageURLString = dictionary[@"image_url"];
    }
    return self;
}

+ (NSMutableArray *)eventsWithArray:(NSArray *)dictionaries {
    NSMutableArray *events = [NSMutableArray array];
    for (NSDictionary *dictionary in dictionaries) {
        Event *event = [[Event alloc] initWithDictionary: dictionary];
        [events addObject:event];
    }
    return events;
}

+ (void) postEventWithName:(NSString * _Nullable)name withSummary:(NSString *)summary withGroup:(Group *)group withCompletion:(PFBooleanResultBlock _Nullable)completion {
    Event *newEvent = [Event new];
    newEvent.name = name;
    newEvent.summary = summary;
    newEvent.group = group;

    [newEvent saveInBackgroundWithBlock:completion];
}


@end
