//
//  EventValidation.h
//  trip-together
//
//  Created by Elizabeth Ke on 7/20/21.
//

#import <Foundation/Foundation.h>
#import "Event.h"

NS_ASSUME_NONNULL_BEGIN

@interface EventValidation : NSObject

+ (NSArray *)getUsersWithConflictsForEvent:(Event *)event;
+ (NSArray *)getConflictingEventsForEvent:(Event *)event;
+ (NSArray *)getEventsForUsersInGroup:(Group *)group;
+ (NSArray *)getOverlappingUsersInGroup1:(Group *)group1 andGroup2:(Group *)group2;
+ (BOOL)hasUserOverlapInGroup1:(Group *)group1 andGroup2:(Group *)group2;
+ (NSArray *)getUserIDsOfGroup:(Group *)group;
+ (BOOL) hasConflictBetweenEvent1:(Event *)event1 andEvent2:(Event *)event2;

@end

NS_ASSUME_NONNULL_END
