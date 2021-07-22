//
//  APIManager.m
//  trip-together
//
//  Created by Elizabeth Ke on 7/22/21.
//

#import "APIManager.h"

@implementation APIManager

+ (void)queryFoursquareDetailsWithParams:(NSDictionary *)params withCompletion:(void(^)(NSDictionary *details, NSError *error))completion {
    
    // get authentication keys from Keys.plist
    NSString *path = [[NSBundle mainBundle] pathForResource: @"Keys" ofType: @"plist"];
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile: path];
    NSString *clientID = [dict objectForKey: @"foursquareClientID"];
    NSString *clientSecret = [dict objectForKey: @"foursquareClientSecret"];
    
    // make request URL string
    NSMutableDictionary *requestParams = [params mutableCopy];
    [requestParams addEntriesFromDictionary:@{
        @"client_id": clientID,
        @"client_secret": clientSecret,
        @"v": @"20210720",
    }];
    NSString *baseURLString = @"https://api.foursquare.com/v2/venues/search";
    NSString *fullURLString = [self addParams:requestParams toBaseURLString:baseURLString];
    
    // make request
    NSURL *url = [NSURL URLWithString:fullURLString];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error != nil) {
            completion(nil, error);
        }
        else {
            NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            NSArray *venues = dataDictionary[@"response"][@"venues"];
            if (venues.count > 0) {
                [self queryFoursquareDetailsForVenueWithID:venues[0][@"id"] withCompletion:completion];
            } else {
                completion(@{@"description":@"", @"websiteURL":@""}, nil);
            }
        }
    }];
    [task resume];
    
}

+ (void)queryFoursquareDetailsForVenueWithID:(NSString *)venueID withCompletion:(void(^)(NSDictionary *details, NSError *error))completion {
        
    // get authentication keys from Keys.plist
    NSString *path = [[NSBundle mainBundle] pathForResource: @"Keys" ofType: @"plist"];
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile: path];
    NSString *clientID = [dict objectForKey: @"foursquareClientID"];
    NSString *clientSecret = [dict objectForKey: @"foursquareClientSecret"];
    
    // make request URL string
    NSDictionary *params = @{
        @"client_id": clientID,
        @"client_secret": clientSecret,
        @"v": @"20210720",
    };
    NSString *baseURLString = [NSString stringWithFormat:@"https://api.foursquare.com/v2/venues/%@", venueID];
    NSString *fullURLString = [self addParams:params toBaseURLString:baseURLString];
    
    // make request
    NSURL *url = [NSURL URLWithString:fullURLString];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error != nil) {
            completion(nil, error);
        }
        else {
            NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            NSDictionary *venue = dataDictionary[@"response"][@"venue"];
            NSDictionary *details = @{
                @"description": venue[@"description"] ? venue[@"description"] : @"",
                @"websiteURL": venue[@"url"] ? venue[@"url"] : @"",
            };
            completion(details, nil);
        }
    }];
    [task resume];
    
}

+ (NSString *)addParams:(NSDictionary *)params toBaseURLString:(NSString *)baseURLString {
    // makes new URL string with params attached to end
    NSString *paramString = @"?";
    for (NSString *key in params) {
        NSString *newParamString = [NSString stringWithFormat:@"%@=%@&", key, [params objectForKey:key]];
        paramString = [paramString stringByAppendingString:newParamString];
    }
    paramString = [paramString substringToIndex:[paramString length]-1];
    return [baseURLString stringByAppendingString:paramString];
}

@end
