//
//  NetworkClient.h
//  Sales
//
//  Created by Jayce Yang on 14-1-6.
//  Copyright (c) 2014年 DJI. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFHTTPRequestOperationManager.h"

typedef NS_ENUM(NSInteger, ErrorCode) {
    ErrorCodeUndefined                                      = - 1,
    ErrorCodeSuccess                                        = 0,
    ErrorCodeInformationValidationFailed                    = 201,
    ErrorCodeIncorrectAccountOrPassword                     = 305,
    ErrorCodeEmailIsAlreadyRegistered                       = 306,
    ErrorCodeEmailIsNotRegistered                           = 308,
    ErrorCodeEmailOfVerificationCodeIsNotRegistered         = 311,
    ErrorCodeRequiresLogin                                  = 315,
    ErrorCodeVerificationCodeIsIncorrectOrExpired           = 320,
    ErrorCodeInvalidMobile                                  = 321,
    ErrorCodeAccountIsInReview                              = 322,
    ErrorCodeApplicationRejected                            = 323,
    ErrorCodeAccountIDDoesNotExist                          = 324,
    ErrorCodeIncorrectOrderNumber                           = 400,
    ErrorCodeOrderFailed                                    = 401,
    ErrorCodeProductIsOutOfStock                            = 402,
    ErrorCodeProductIsUnavailable                           = 403,
    ErrorCodeInsufficientDJICredit                          = 404,
    ErrorCodeDJICreditExceedUnitPrice                       = 405,
    ErrorCodePaidOrdersCannotBeCancelled                    = 502,
    ErrorCodeNetworkConnectionLost                          = 1024
};

typedef void(^NetworkSuccessHandler)(id data);
typedef void(^NetworkFailureHandler)(NSString *message, ErrorCode code);
typedef void(^NetworkProgressHandler)(long long totalBytes, long long totalBytesExpected);

extern NSString * const NetworkClientErrorDomain;
extern NSString * const NetworkClientStatus;
extern NSString * const NetworkClientData;

@interface NetworkClient : AFHTTPRequestOperationManager

+ (instancetype)sharedClient;

- (void)startMonitoringNetwork;
- (void)stopMonitoringNetwork;

- (AFHTTPRequestOperation *)GET:(NSString *)URLString parameters:(NSDictionary *)parameters success:(NetworkSuccessHandler)success failure:(NetworkFailureHandler)failure;
- (AFHTTPRequestOperation *)POST:(NSString *)URLString parameters:(NSDictionary *)parameters success:(NetworkSuccessHandler)success failure:(NetworkFailureHandler)failure;
- (AFHTTPRequestOperation *)DELETE:(NSString *)URLString parameters:(NSDictionary *)parameters success:(NetworkSuccessHandler)success failure:(NetworkFailureHandler)failure;

- (AFHTTPRequestOperation *)POSTMultipartFormRequestURLString:(NSString *)URLString parameters:(NSDictionary *)parameters constructingBodyWithBlock:(void (^)(id <AFMultipartFormData> formData))constructingBody success:(NetworkSuccessHandler)success failure:(NetworkFailureHandler)failure;
- (AFHTTPRequestOperation *)POSTMultipartFormRequestURLString:(NSString *)URLString parameters:(NSDictionary *)parameters constructingBodyWithBlock:(void (^)(id <AFMultipartFormData> formData))constructingBody success:(NetworkSuccessHandler)success failure:(NetworkFailureHandler)failure uploadProgress:(NetworkProgressHandler)uploadProgress;

@end