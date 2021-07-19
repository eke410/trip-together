//
//  Event.m
//  trip-together
//
//  Created by Elizabeth Ke on 7/13/21.
//

#import "Event.h"

@implementation Event

@dynamic yelpID;
@dynamic name;
@dynamic imageURLString;
@dynamic location;
@dynamic rating;
@dynamic yelpURL;
@dynamic group;
@dynamic startTime;
@dynamic endTime;

+ (nonnull NSString *)parseClassName {
    return @"Event";
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        self.yelpID = dictionary[@"id"];
        self.name = dictionary[@"name"];
        self.imageURLString = dictionary[@"image_url"];
        NSArray *addressArray = dictionary[@"location"][@"display_address"];
        self.location = [addressArray componentsJoinedByString:@", "];
        self.rating = [NSString stringWithFormat:@"%@", dictionary[@"rating"]];
        self.yelpURL = dictionary[@"url"];
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


- (nonnull id)copyWithZone:(nullable NSZone *)zone {
    Event *newEvent = [[Event alloc] init];
    newEvent.yelpID = self.yelpID;
    newEvent.name = self.name;
    newEvent.imageURLString = self.imageURLString;
    newEvent.location = self.location;
    newEvent.rating = self.rating;
    newEvent.yelpURL = self.yelpURL;
    newEvent.group = self.group;
    newEvent.startTime = self.startTime;
    newEvent.endTime = self.endTime;
    return newEvent;
}

@end
