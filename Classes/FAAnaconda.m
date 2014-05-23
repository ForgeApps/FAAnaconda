//
//  BFAPI.m
//  Uncommen
//
//  Created by Jeff McFadden on 4/23/14.
//  Copyright (c) 2014 Brushfire. All rights reserved.
//

#import "FAAnaconda.h"

NSString  *const FAAnacondaCredentialsUploadURLKey = @"post_url";
NSString  *const FAAnacondaCredentialsFileNameKey  = @"filename";
NSString  *const FAAnacondaCredentialsMimeTypeKey  = @"Content-Type";

NSString  *const FAAnacondaCredentialsAWSAccessKeyIdKey = @"AWSAccessKeyId";
NSString  *const FAAnacondaCredentialsAclKey = @"acl";
NSString  *const FAAnacondaCredentialsKeyKey = @"key";
NSString  *const FAAnacondaCredentialsPolicyKey = @"policy";
NSString  *const FAAnacondaCredentialsSignatureKey = @"signature";


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

- (void)getFileUploadCredentialsFromPath:(NSString *)path success:(void (^)(NSDictionary *credentials))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];

    NSString *urlString = [NSString stringWithFormat:@"%@/%@", self.apiBaseURL, path];

    [manager GET:urlString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);

        if (success) {
            success( responseObject );
        }

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);

        if (failure) {
            failure( operation, error );
        }

    }];
}

- (void)uploadFileData:(NSData *)data withUploadCredentials:(NSDictionary *)credentials progress:(NSProgress *)progress success: (void (^)(NSDictionary *anacondaKeysForObject, NSURLResponse *response, id responseObject))success failure:(void (^)(NSError *error, NSURLResponse *response, id responseObject))failure
{
    NSString *urlString = [NSString stringWithFormat:@"%@", [credentials objectForKey:FAAnacondaCredentialsUploadURLKey]];

    NSString *fileName = [credentials objectForKey:FAAnacondaCredentialsFileNameKey];
    NSString *mimeType = [credentials objectForKey:FAAnacondaCredentialsMimeTypeKey];
    
    NSDictionary *parameters = @{@"AWSAccessKeyId": [credentials objectForKey:FAAnacondaCredentialsAWSAccessKeyIdKey],
                                 @"Content-Type" :  [credentials objectForKey:FAAnacondaCredentialsMimeTypeKey],
                                 @"acl" :           [credentials objectForKey:FAAnacondaCredentialsAclKey],
                                 @"key" :           [credentials objectForKey:FAAnacondaCredentialsKeyKey],
                                 @"policy" :        [credentials objectForKey:FAAnacondaCredentialsPolicyKey],
                                 @"signature" :     [credentials objectForKey:FAAnacondaCredentialsSignatureKey],
                                 };

    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST" URLString:urlString parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData:data name:@"file" fileName:fileName mimeType:mimeType];
    } error:nil];
    
    /**
     * "WTF IS GOING ON HERE?" I hear you asking.
     * 
     * Well, Apple has a bug in NSURLSessionTask where it refuses to pass a Content-Length: header if you're uploading
     * from anywhere except a file. So this is a hacky ass workaround to fix that.
     * You can follow the whole thread here: https://github.com/AFNetworking/AFNetworking/issues/1398
     *
     * Oh, and the best part is that Apple claims this isn't actually a bug, but intended behavior:
     * https://devforums.apple.com/message/919330#919330
     */
    
    NSURL *tempFileURL = [[NSURL fileURLWithPath:NSTemporaryDirectory() isDirectory:YES] URLByAppendingPathComponent:@"temp_image_file_upload"];
    
    __block NSProgress *block_progress = progress;
    
    [[AFHTTPRequestSerializer serializer] requestWithMultipartFormRequest:request writingStreamContentsToFile:tempFileURL completionHandler:^(NSError *error){
       
        AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
        
        manager.responseSerializer = [AFXMLParserResponseSerializer serializer];
        
        NSURLSessionUploadTask *uploadTask = [manager uploadTaskWithRequest:request fromFile:tempFileURL progress:&block_progress completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
            if (error) {
                NSLog(@"Error: %@", error);
                
                if (failure) {
                    failure( error, response, responseObject );
                }
                
            } else {
                NSLog(@"%@ %@", response, responseObject);
                
                //[:title, :asset_filename, :asset_file_path, :asset_size, :asset_original_filename, :asset_stored_privately, :asset_type]

                
                NSDictionary *anacondaKeysForObjects = @{ @"filename" : fileName,
                                                          @"file_path" : [[credentials objectForKey:FAAnacondaCredentialsKeyKey] stringByReplacingOccurrencesOfString:@"${filename}" withString:fileName],
                                                          @"size" : [NSString stringWithFormat:@"%lu", (unsigned long)[data length]],
                                                          @"original_filename" : fileName,
                                                          @"stored_privately" : @"",
                                                          @"type" : @""};
                
                if (success) {
                    success( anacondaKeysForObjects, response, responseObject );
                }
            }
        }];
        
        [uploadTask resume];

    }];
    
}


@end
