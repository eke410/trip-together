//
//  Event.h
//  trip-together
//
//  Created by Elizabeth Ke on 7/13/21.
//

#import <Parse/Parse.h>
#import "Group.h"

NS_ASSUME_NONNULL_BEGIN

@interface Event : PFObject<PFSubclassing>

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *imageURLString;
@property (nonatomic, strong) NSString *location;
@property (nonatomic, strong) NSString *rating;
@property (nonatomic, strong) NSString *yelpURL;

@property (nonatomic, strong) Group *group;
@property (nonatomic, strong) NSDate *startTime;
@property (nonatomic, strong) NSDate *endTime;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;
+ (NSMutableArray *)eventsWithArray:(NSArray *)dictionaries;

@end

NS_ASSUME_NONNULL_END
