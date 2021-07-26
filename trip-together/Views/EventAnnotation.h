//
//  EventAnnotation.h
//  trip-together
//
//  Created by Elizabeth Ke on 7/26/21.
//

#import <Foundation/Foundation.h>
#import "Mapkit/Mapkit.h"
#import "Event.h"

NS_ASSUME_NONNULL_BEGIN

@interface EventAnnotation : NSObject <MKAnnotation>

@property (strong, nonatomic) Event *event;
@property int index;

@end

NS_ASSUME_NONNULL_END
