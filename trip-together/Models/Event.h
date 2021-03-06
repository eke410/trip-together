//
//  Event.h
//  trip-together
//
//  Created by Elizabeth Ke on 7/13/21.
//

#import <Parse/Parse.h>
#import "Group.h"

NS_ASSUME_NONNULL_BEGIN

@interface Event : PFObject<PFSubclassing, NSCopying>

@property (nonatomic, strong) NSString *yelpID;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *imageURLString;
@property (nonatomic, strong) NSString *location;
@property (nonatomic, strong) NSString *latitude;
@property (nonatomic, strong) NSString *longitude;
@property (nonatomic, strong) NSString *rating;
@property (nonatomic, strong) NSString *yelpURL;
@property (nonatomic, strong) NSString *phone;
@property (nonatomic, strong) NSArray *categories;
@property (nonatomic, strong) NSString *priceLevel;
@property (nonatomic, strong) NSString *reviewCount;
@property (nonatomic, strong) NSArray *photoURLStrings;
@property (nonatomic, strong) NSString *placeDescription;
@property (nonatomic, strong) NSString *websiteURL;
@property (nonatomic, strong) NSString *type;

@property (nonatomic, strong) Group *group;
@property (nonatomic, strong) NSDate *startTime;
@property (nonatomic, strong) NSDate *endTime;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary withType:(NSString *)type;
+ (NSMutableArray *)eventsWithArray:(NSArray *)dictionaries withType:(NSString *)type;

@end

NS_ASSUME_NONNULL_END
