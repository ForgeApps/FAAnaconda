//
//  BFAPI.m
//  Uncommen
//
//  Created by Jeff McFadden on 4/23/14.
//  Copyright (c) 2014 Brushfire. All rights reserved.
//

#import "FAAnaconda.h"

@interface FAAnaconda()

@property (strong) NSURL *apiBaseURL;

@end

@implementation FAAnaconda

- (id)initWithAPIBaseURL:(NSURL *)apiBaseURL
{
    self = [super init];
    if (self) {
        _apiBaseURL = apiBaseURL;
    }
    return self;
}

- (void)getFileUploadCredentialsWithSuccess:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;


@end
