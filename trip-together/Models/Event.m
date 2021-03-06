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
@dynamic latitude;
@dynamic longitude;
@dynamic rating;
@dynamic yelpURL;
@dynamic phone;
@dynamic categories;
@dynamic priceLevel;
@dynamic reviewCount;
@dynamic photoURLStrings;
@dynamic placeDescription;
@dynamic websiteURL;
@dynamic type;

@dynamic group;
@dynamic startTime;
@dynamic endTime;

+ (nonnull NSString *)parseClassName {
    return @"Event";
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary withType:(NSString *)type {
    self = [super init];
    if (self) {
        self.yelpID = dictionary[@"id"];
        self.name = dictionary[@"name"];
        self.imageURLString = dictionary[@"image_url"];
        NSArray *addressArray = dictionary[@"location"][@"display_address"];
        self.location = [addressArray componentsJoinedByString:@", "];
        self.latitude = [NSString stringWithFormat:@"%@", dictionary[@"coordinates"][@"latitude"]];
        self.longitude = [NSString stringWithFormat:@"%@", dictionary[@"coordinates"][@"longitude"]];
        self.rating = [NSString stringWithFormat:@"%@", dictionary[@"rating"]];
        self.yelpURL = dictionary[@"url"];
        self.phone = dictionary[@"display_phone"];
        self.categories = dictionary[@"categories"];
        self.priceLevel = dictionary[@"price"] ? dictionary[@"price"] : @"";
        self.reviewCount = [NSString stringWithFormat:@"%@", dictionary[@"review_count"]];
        self.placeDescription = @"not queried yet";
        self.websiteURL = @"not queried yet";
        self.type = type;
    }
    return self;
}

+ (NSMutableArray *)eventsWithArray:(NSArray *)dictionaries withType:(NSString *)type {
    NSMutableArray *events = [NSMutableArray array];
    for (NSDictionary *dictionary in dictionaries) {
        Event *event = [[Event alloc] initWithDictionary: dictionary withType:type];
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
    newEvent.latitude = self.latitude;
    newEvent.longitude = self.longitude;
    newEvent.rating = self.rating;
    newEvent.yelpURL = self.yelpURL;
    newEvent.group = self.group;
    newEvent.startTime = self.startTime;
    newEvent.endTime = self.endTime;
    newEvent.phone = self.phone;
    newEvent.categories = self.categories;
    newEvent.priceLevel = self.priceLevel;
    newEvent.reviewCount = self.reviewCount;
    newEvent.photoURLStrings = self.photoURLStrings;
    newEvent.placeDescription = self.placeDescription;
    newEvent.websiteURL = self.websiteURL;
    newEvent.type = self.type;
    return newEvent;
}

@end
