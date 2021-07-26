//
//  EventAnnotation.m
//  trip-together
//
//  Created by Elizabeth Ke on 7/26/21.
//

#import "EventAnnotation.h"

@interface EventAnnotation()

@property (nonatomic) CLLocationCoordinate2D coordinate;

@end

@implementation EventAnnotation

- (NSString *)title {
    return [NSString stringWithFormat:@"%@", self.event.name];
}

@end
