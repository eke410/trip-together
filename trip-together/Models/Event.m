//
//  Event.m
//  trip-together
//
//  Created by Elizabeth Ke on 7/13/21.
//

#import "Event.h"

@implementation Event

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
        NSLog(@"making event");
        self.name = dictionary[@"name"];
        self.imageURLString = dictionary[@"image_url"];
        NSArray *addressArray = dictionary[@"location"][@"display_address"];
        self.location = [addressArray componentsJoinedByString:@", "];
        self.rating = dictionary[@"rating"];
        self.yelpURL = dictionary[@"url"];
        self.startTime = @"TBA";
        self.endTime = @"TBA";
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


@end
