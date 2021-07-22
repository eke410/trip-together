//
//  APIManager.h
//  trip-together
//
//  Created by Elizabeth Ke on 7/22/21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface APIManager : NSObject

+ (void)queryFoursquareDetailsWithParams:(NSDictionary *)params withCompletion:(void(^)(NSDictionary *details, NSError *error))completion;

@end

NS_ASSUME_NONNULL_END
