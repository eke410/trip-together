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
@property (nonatomic, strong) NSString *summary;
@property (nonatomic, strong) Group *group;
@property (nonatomic, strong) NSString *eventSiteURLString;
@property (nonatomic, strong) NSString *ticketsURLString;
@property (nonatomic, strong) NSDictionary *location;
@property (nonatomic, strong) NSString *startTime;
@property (nonatomic, strong) NSString *endTime;
@property (nonatomic, strong) NSString *imageURLString;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;
+ (NSMutableArray *)eventsWithArray:(NSArray *)dictionaries;
+ (void) postEventWithName:(NSString * _Nullable)name withSummary:(NSString *)summary withGroup:(Group *)group withCompletion:(PFBooleanResultBlock _Nullable)completion;

@end

NS_ASSUME_NONNULL_END
