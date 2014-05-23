//
//  BFAPI.h
//  Uncommen
//
//  Created by Jeff McFadden on 4/23/14.
//  Copyright (c) 2014 Brushfire. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>
#import <AFNetworking/AFNetworkActivityIndicatorManager.h>

FOUNDATION_EXPORT NSString  *const FAAnacondaCredentialsUploadURLKey;
FOUNDATION_EXPORT NSString  *const FAAnacondaCredentialsFileNameKey;
FOUNDATION_EXPORT NSString  *const FAAnacondaCredentialsMimeTypeKey;

FOUNDATION_EXPORT NSString  *const FAAnacondaCredentialsAWSAccessKeyIdKey;
FOUNDATION_EXPORT NSString  *const FAAnacondaCredentialsAclKey;
FOUNDATION_EXPORT NSString  *const FAAnacondaCredentialsKeyKey;
FOUNDATION_EXPORT NSString  *const FAAnacondaCredentialsPolicyKey;
FOUNDATION_EXPORT NSString  *const FAAnacondaCredentialsSignatureKey;


@interface FAAnaconda : NSObject

- (id)initWithAPIBaseURL:(NSURL *)apiBaseURL;

- (void)getFileUploadCredentialsFromPath:(NSString *)page success:(void (^)(NSDictionary *credentials))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

- (void)uploadFileData:(NSData *)data withUploadCredentials:(NSDictionary *)credentials progress:(NSProgress *)progress success: (void (^)(NSDictionary *anacondaKeysForObject, NSURLResponse *response, id responseObject))success failure:(void (^)(NSError *error, NSURLResponse *response, id responseObject))failure;


@end
