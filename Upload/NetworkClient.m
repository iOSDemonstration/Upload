//
//  NetworkClient.m
//  Sales
//
//  Created by Jayce Yang on 14-1-6.
//  Copyright (c) 2014年 DJI. All rights reserved.
//

#import "NetworkClient.h"

#import "AFHTTPRequestOperationManager.h"
#import "AFURLRequestSerialization.h"
#import "AFSecurityPolicy.h"
#import "AFNetworkReachabilityManager.h"

NSString * const NetworkClientErrorDomain = @"com.dji.sales";

NSString * const NetworkClientStatus = @"status";
NSString * const NetworkClientMessage = @"status_msg";
NSString * const NetworkClientData = @"data";

@interface NetworkClient ()

@property (nonatomic) BOOL waitingForNetworkMonitoring;
@property (nonatomic) BOOL showingAlertView;

@end

@implementation NetworkClient

#pragma mark - Public

+ (instancetype)sharedClient
{
    static NetworkClient *sharedInstance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[super alloc] initWithBaseURL:[NSURL URLWithString:@"http://10.10.1.117:9999/"]];
//        sharedInstance = [[super alloc] initWithBaseURL:[NSURL URLWithString:@"http://10.81.4.121/"]];
        sharedInstance.securityPolicy.allowInvalidCertificates = YES;
        sharedInstance.waitingForNetworkMonitoring = YES;
        sharedInstance.showingAlertView = NO;
        sharedInstance.requestSerializer.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
        sharedInstance.requestSerializer.timeoutInterval = 60 * 10;
        [sharedInstance startMonitoringNetwork];
    });
    
    return sharedInstance;
}

- (void)dealloc
{
    [self.reachabilityManager stopMonitoring];
}

- (void)startMonitoringNetwork
{
    self.reachabilityManager = [AFNetworkReachabilityManager sharedManager];
    [self.reachabilityManager startMonitoring];
    __weak __typeof(self)weakSelf = self;
    [self.reachabilityManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        __strong __typeof(self)strongSelf = weakSelf;
        switch (status) {
            case AFNetworkReachabilityStatusNotReachable:
                NSLog(@"Not Reachable");
                break;
            case AFNetworkReachabilityStatusReachableViaWWAN:
                NSLog(@"WWAN");
                break;
            case AFNetworkReachabilityStatusReachableViaWiFi:
                NSLog(@"Wi-Fi");
                break;
            default:
                NSLog(@"Unknown");
                break;
        }
        strongSelf.waitingForNetworkMonitoring = NO;
    }];
}

- (void)stopMonitoringNetwork
{
    [self.reachabilityManager stopMonitoring];
}

- (AFHTTPRequestOperation *)GET:(NSString *)URLString parameters:(NSDictionary *)parameters success:(NetworkSuccessHandler)success failure:(NetworkFailureHandler)failure
{
    NSMutableURLRequest *request = [self.requestSerializer requestWithMethod:@"GET" URLString:[[NSURL URLWithString:URLString relativeToURL:self.baseURL] absoluteString] parameters:parameters error:nil];
    return [self request:request constructingBodyWithBlock:nil success:success failure:failure uploadProgress:nil];
}

- (AFHTTPRequestOperation *)POST:(NSString *)URLString parameters:(NSDictionary *)parameters success:(NetworkSuccessHandler)success failure:(NetworkFailureHandler)failure
{
    NSMutableURLRequest *request = [self.requestSerializer requestWithMethod:@"POST" URLString:[[NSURL URLWithString:URLString relativeToURL:self.baseURL] absoluteString] parameters:parameters error:nil];
    
    return [self request:request constructingBodyWithBlock:nil success:success failure:failure uploadProgress:nil];
}

- (AFHTTPRequestOperation *)DELETE:(NSString *)URLString parameters:(NSDictionary *)parameters success:(NetworkSuccessHandler)success failure:(NetworkFailureHandler)failure
{
    NSMutableURLRequest *request = [self.requestSerializer requestWithMethod:@"DELETE" URLString:[[NSURL URLWithString:URLString relativeToURL:self.baseURL] absoluteString] parameters:parameters error:nil];
    return [self request:request constructingBodyWithBlock:nil success:success failure:failure uploadProgress:nil];
}

- (AFHTTPRequestOperation *)POSTMultipartFormRequestURLString:(NSString *)URLString parameters:(NSDictionary *)parameters constructingBodyWithBlock:(void (^)(id <AFMultipartFormData> formData))constructingBody success:(NetworkSuccessHandler)success failure:(NetworkFailureHandler)failure
{
    NSMutableURLRequest *request = [self.requestSerializer multipartFormRequestWithMethod:@"POST" URLString:[[NSURL URLWithString:URLString relativeToURL:self.baseURL] absoluteString] parameters:parameters constructingBodyWithBlock:constructingBody error:nil];
    return [self request:request constructingBodyWithBlock:nil success:success failure:failure uploadProgress:nil];
}

- (AFHTTPRequestOperation *)POSTMultipartFormRequestURLString:(NSString *)URLString parameters:(NSDictionary *)parameters constructingBodyWithBlock:(void (^)(id <AFMultipartFormData> formData))constructingBody success:(NetworkSuccessHandler)success failure:(NetworkFailureHandler)failure uploadProgress:(NetworkProgressHandler)uploadProgress{
    NSMutableURLRequest *request = [self.requestSerializer multipartFormRequestWithMethod:@"POST" URLString:[[NSURL URLWithString:URLString relativeToURL:self.baseURL] absoluteString] parameters:parameters constructingBodyWithBlock:constructingBody error:nil];
    return [self request:request constructingBodyWithBlock:nil success:success failure:failure uploadProgress:uploadProgress];
}

- (AFHTTPRequestOperation *)request:(NSMutableURLRequest *)request constructingBodyWithBlock:(void (^)(id <AFMultipartFormData> formData))constructingBody success:(NetworkSuccessHandler)success failure:(NetworkFailureHandler)failure uploadProgress:(NetworkProgressHandler)uploadProgress {
    if (self.waitingForNetworkMonitoring || [self.reachabilityManager isReachable]) {
        AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
//            NSLog(@"%@", responseObject);
            if (success) {
                success(responseObject);
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
#ifdef DEBUG
            NSLog(@"%@", error.localizedDescription);
#endif
            if (failure) {
                failure(NSLocalizedString(@"Unknown error.", nil), error.code);
            }
        }];
        if (uploadProgress) {
            [operation setUploadProgressBlock:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
//                ELog(@"%lu\t%lld\t%lld", (unsigned long)bytesWritten, totalBytesWritten, totalBytesExpectedToWrite);
                uploadProgress(totalBytesWritten, totalBytesExpectedToWrite);
            }];
        }
        [self.operationQueue addOperation:operation];
        
        return operation;
    } else {
        if (failure) {
            failure(NSLocalizedString(@"Network connection lost.", nil), ErrorCodeNetworkConnectionLost);
        }
    }
    
    return nil;
}

@end
