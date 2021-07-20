//
//  EventValidation.m
//  trip-together
//
//  Created by Elizabeth Ke on 7/20/21.
//

#import "EventValidation.h"

@implementation EventValidation

+ (NSArray *)getUsersWithConflictsForEvent:(Event *)event {
    // returns array of users who have time conflicts for the event, sorted by alphabetical order on first name
    // finds users with conflicts
    NSMutableSet *usersWithConflicts = [NSMutableSet new];
    NSArray *conflictingEvents = [self getConflictingEventsForEvent:event];
    for (Event *conflictingEvent in conflictingEvents) {
        NSArray *overlappingUsers = [self getOverlappingUsersInGroup1:event.group andGroup2:conflictingEvent.group];
        [usersWithConflicts addObjectsFromArray:overlappingUsers];
    }
    // sorts users by first name
    NSSortDescriptor *firstNameSorter = [[NSSortDescriptor alloc] initWithKey:@"firstName" ascending:true];
    NSSortDescriptor *lastNameSorter = [[NSSortDescriptor alloc] initWithKey:@"lastName" ascending:true];
    NSArray *sortedUsers = [usersWithConflicts sortedArrayUsingDescriptors:@[firstNameSorter, lastNameSorter]];
    return sortedUsers;
}

+ (NSArray *)getConflictingEventsForEvent:(Event *)event {
    // returns array of events that would cause a time conflict for any user in the group
    NSMutableArray *conflictingEvents = [NSMutableArray new];
    NSArray *eventsToCheck = [self getEventsForUsersInGroup:event.group];
    for (Event *eventToCheck in eventsToCheck) {
        if ([self hasConflictBetweenEvent1:event andEvent2:eventToCheck]) {
            [conflictingEvents addObject:eventToCheck];
        }
    }
    return (NSArray *) conflictingEvents;
}

+ (NSArray *)getEventsForUsersInGroup:(Group *)group {
    // returns all events that any user in the group is signed up for
    PFQuery *query = [PFQuery queryWithClassName:@"Event"];
    [query includeKey:@"group"];
    [query includeKey:@"group.users"];
    
    NSArray *events = [query findObjects];
    NSMutableArray *filteredEvents = [NSMutableArray new];
    for (Event *event in events) {
        if ([self hasUserOverlapInGroup1:group andGroup2:event.group]) {
            [filteredEvents addObject:event];
        }
    }
    return (NSArray *) filteredEvents;
}

+ (NSArray *)getOverlappingUsersInGroup1:(Group *)group1 andGroup2:(Group *)group2 {
    // returns any users that group1 and group2 have in common
    NSMutableArray *overlappingUsers = [NSMutableArray new];
    NSArray *group2ids = [self getUserIDsOfGroup:group2];
    for (PFUser *user in group1.users) {
        if ([group2ids containsObject:user.objectId]) {
            [overlappingUsers addObject:user];
        }
    }
    return overlappingUsers;
}

+ (BOOL)hasUserOverlapInGroup1:(Group *)group1 andGroup2:(Group *)group2 {
    // returns true if group1 and group2 have any user in common, returns false otherwise
    NSArray *group2ids = [self getUserIDsOfGroup:group2];
    for (PFUser *user in group1.users) {
        if ([group2ids containsObject:user.objectId]) {
            return true;
        }
    }
    return false;
}

+ (NSArray *)getUserIDsOfGroup:(Group *)group {
    // returns array containing all objectIds of users in the group
    NSMutableArray *groupIDs = [NSMutableArray new];
    for (PFUser *user in group.users) {
        [groupIDs addObject:user.objectId];
    }
    return (NSArray *) groupIDs;
}

+ (BOOL) hasConflictBetweenEvent1:(Event *)event1 andEvent2:(Event *)event2 {
    // returns true if event1 and event2 overlap in time, returns false otherwise
    return (([event1.startTime compare:event2.startTime] != NSOrderedDescending && [event2.startTime compare:event1.endTime] == NSOrderedAscending) || ([event2.startTime compare:event1.startTime] != NSOrderedDescending && [event1.startTime compare:event2.endTime] == NSOrderedAscending));
}


@end
