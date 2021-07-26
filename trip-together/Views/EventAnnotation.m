//
//  EventAnnotation.m
//  trip-together
//
//  Created by Elizabeth Ke on 7/26/21.
//

#import "EventAnnotation.h"
#import "DateTools.h"

@interface EventAnnotation()

@property (nonatomic) CLLocationCoordinate2D coordinate;

@end

@implementation EventAnnotation

- (NSString *)title {
    return [NSString stringWithFormat:@"%@", self.event.name];
}

- (NSString *)subtitle {
    NSString *startTimeString = [self.event.startTime formattedDateWithFormat:@"MMM d, h:mm a"];
    NSString *endTimeString = [self.event.endTime formattedDateWithFormat:@"MMM d, h:mm a"];

    if (self.event.startTime.dayOfYear == self.event.endTime.dayOfYear) {
        endTimeString = [self.event.endTime formattedDateWithFormat:@"h:mm a"];
    }
    return [NSString stringWithFormat:@"%@ - %@", startTimeString, endTimeString];

}

@end
