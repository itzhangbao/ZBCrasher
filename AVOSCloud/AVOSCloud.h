//
//  paas.h
//  paas
//
//  Created by Zhu Zeng on 2/25/13.
//  Copyright (c) 2013 AVOS. All rights reserved.
//

#import <Foundation/Foundation.h>

// Public headers

#import "AVAvailability.h"
#import "AVConstants.h"
#import "AVLogger.h"

// Object
#import "AVObject.h"
#import "AVObject+Subclass.h"
#import "AVSubclassing.h"
#import "AVRelation.h"

// Option
#import "AVSaveOption.h"

// Query
#import "AVQuery.h"

// File
#import "AVFile.h"
#import "AVFileQuery.h"

// Geo
#import "AVGeoPoint.h"

// Status
#import "AVStatus.h"

// Push
#import "AVInstallation.h"
#import "AVPush.h"

// User
#import "AVUser.h"
#import "AVAnonymousUtils.h"

// CloudCode
#import "AVCloud.h"
#import "AVCloudQueryResult.h"

// Search
#import "AVSearchQuery.h"
#import "AVSearchSortBuilder.h"

// ACL
#import "AVACL.h"
#import "AVRole.h"

#import "AVCaptcha.h"
#import "AVSMS.h"

// Router
#import "LCRouter.h"

#if !TARGET_OS_WATCH
// Analytics
#import "AVAnalytics.h"
#endif

typedef enum : NSUInteger {
    kAVVerboseShow,
    kAVVerboseNone,
#if DEBUG
    kAVVerboseAuto = kAVVerboseShow
#else
    kAVVerboseAuto = kAVVerboseNone
#endif
} AVVerbosePolicy;

typedef enum AVLogLevel : NSUInteger {
    AVLogLevelNone      = 0,
    AVLogLevelError     = 1 << 0,
    AVLogLevelWarning   = 1 << 1,
    AVLogLevelInfo      = 1 << 2,
    AVLogLevelVerbose   = 1 << 3,
    AVLogLevelDefault   = AVLogLevelError | AVLogLevelWarning
} AVLogLevel;

typedef NS_ENUM(NSInteger, AVServiceModule) {
    AVServiceModuleAPI = 1,
    AVServiceModuleEngine,
    AVServiceModulePush,
    AVServiceModuleRTM,
    AVServiceModuleStatistics
};

NS_ASSUME_NONNULL_BEGIN

/**
 *  AVOSCloud is the main Class for AVOSCloud SDK
 */
@interface AVOSCloud : NSObject

// MARK: ID, Key and Server URL

/// Setup ID, Key and Server URL of the application.
/// @param applicationId The applicaiton id for your LeanCloud application.
/// @param clientKey The client key for your LeanCloud application.
/// @param serverURLString The server url for your LeanCloud application.
+ (void)setApplicationId:(nonnull NSString *)applicationId
               clientKey:(nonnull NSString *)clientKey
         serverURLString:(nonnull NSString *)serverURLString;

/*!
 Sets the applicationId and clientKey of your application.
 @param applicationId The applicaiton id for your LeanCloud application.
 @param clientKey The client key for your LeanCloud application.
 */
+ (void)setApplicationId:(nonnull NSString *)applicationId
               clientKey:(nonnull NSString *)clientKey;

/**
 *  get Application Id
 *
 *  @return Application Id
 */
+ (NSString *)getApplicationId;

/**
 *  get Client Key
 *
 *  @return Client Key
 */
+ (NSString *)getClientKey;

/**
 Custom server URL for specific service module.
 
 @param URLString     The URL string of service module.
 @param serviceModule The service module which you want to customize.
 */
+ (void)setServerURLString:(nullable NSString *)URLString
          forServiceModule:(AVServiceModule)serviceModule;

// MARK: Last Modify

/**
 *  ??????LastModify??????, ????????????????????????????????????
 *  @param enabled ??????
 *  @attention ??????????????????????????????AVQuery???????????????????????????????????????AVQuery??????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????kAVCachePolicyNetworkOnly
 */
+ (void)setLastModifyEnabled:(BOOL)enabled;

/**
 *  ??????????????????LastModify??????
 */
+ (BOOL)getLastModifyEnabled;

/**
 *  ??????LastModify??????
 */
+ (void)clearLastModifyCache;

// MARK: HTTP Request Timeout Interval

/**
 *  Get the timeout interval for network requests. Default is 60 seconds.
 *
 *  @return timeout interval
 */
+ (NSTimeInterval)networkTimeoutInterval;

/**
 *  Set the timeout interval for network request.
 *
 *  @param time  timeout interval(seconds)
 */
+ (void)setNetworkTimeoutInterval:(NSTimeInterval)time;

// MARK: Log

/*!
 * Enable logs of all levels and domains. When define DEBUG macro, it's enabled, otherwise, it's not enabled. This is recommended. But you can set it NO, and call AVLogger's methods to control which domains' log should be output.
 */
+ (void)setAllLogsEnabled:(BOOL)enabled;

/**
 *  ??????SDK????????????
 *  @param verbosePolicy SDK?????????????????????kAVVerboseShow????????????
 *         kAVVerboseNone???????????????kAVVerboseAuto???DEBUG?????????
 */
+ (void)setVerbosePolicy:(AVVerbosePolicy)verbosePolicy;

/// Set log level.
/// @param level The level of log.
+ (void)setLogLevel:(AVLogLevel)level;

/// Get log level.
+ (AVLogLevel)logLevel;

// MARK: Schedule work

/**
 *  get the query cache expired days
 *
 *  @return the query cache expired days
 */
+ (NSInteger)queryCacheExpiredDays;

/**
 *  set Query Cache Expired Days, default is 30 days
 *
 *  @param days the days you want to set
 */
+ (void)setQueryCacheExpiredDays:(NSInteger)days;

/**
 *  get the file cache expired days
 *
 *  @return the file cache expired days
 */
+ (NSInteger)fileCacheExpiredDays;

/**
 *  set File Cache Expired Days, default is 30 days
 *
 *  @param days the days you want to set
 */
+ (void)setFileCacheExpiredDays:(NSInteger)days;

// MARK: SMS

/*!
 *  ?????????????????????????????????????????????????????? API ?????????
 *  ??????????????????????????????????????????
 *  @param code 6??????????????????
 *  @param phoneNumber 11???????????????
 *  @param callback ????????????
 */
+ (void)verifySmsCode:(NSString *)code
    mobilePhoneNumber:(NSString *)phoneNumber
             callback:(AVBooleanResultBlock)callback;

// MARK: Date

/// Get current server date synchronously.
/// @param error Pointer to `NSError *`.
+ (nullable NSDate *)getServerDate:(NSError **)error;

/// Get current server date synchronously.
/// @param error Pointer to `NSError *`.
+ (nullable NSDate *)getServerDateAndThrowsWithError:(NSError **)error;

/// Get current server date asynchronously.
/// @param block Result callback.
+ (void)getServerDateWithBlock:(void (^)(NSDate *_Nullable date, NSError *_Nullable error))block;

@end

// MARK: Deprecated

@interface AVOSCloud (AVDeprecated)

+ (void)startNetworkStatistics __deprecated;

typedef NS_ENUM(NSInteger, AVStorageType) {
    AVStorageTypeQiniu = 0,
    AVStorageTypeParse,
    AVStorageTypeS3,
    AVStorageTypeQCloud,
    AVStorageTypeDefault = AVStorageTypeQiniu,
} __deprecated;

+ (void)setStorageType:(AVStorageType)type
__deprecated_msg("No need any more, now it is NOP.");

typedef NS_ENUM(NSInteger, AVServiceRegion) {
    AVServiceRegionCN = 1,
    AVServiceRegionUS,
    AVServiceRegionDefault = AVServiceRegionCN,
} __deprecated;

+ (void)setServiceRegion:(AVServiceRegion)region
__deprecated_msg("No need any more, now it is NOP.");

+ (void)setTimeZoneForSecondsFromGMT:(NSInteger)seconds
__deprecated_msg("No need any more, now it is NOP.");

+ (void)requestSmsCodeWithPhoneNumber:(NSString *)phoneNumber
                             callback:(AVBooleanResultBlock)callback
__deprecated_msg("Deprecated, `use +[AVSMS requestShortMessageForPhoneNumber:options:callback:]` instead.");

+ (void)requestSmsCodeWithPhoneNumber:(NSString *)phoneNumber
                              appName:(nullable NSString *)appName
                            operation:(nullable NSString *)operation
                           timeToLive:(NSUInteger)ttl
                             callback:(AVBooleanResultBlock)callback
__deprecated_msg("Deprecated, use `+[AVSMS requestShortMessageForPhoneNumber:options:callback:]` instead.");

+ (void)requestSmsCodeWithPhoneNumber:(NSString *)phoneNumber
                         templateName:(nullable NSString *)templateName
                            variables:(nullable NSDictionary *)variables
                             callback:(AVBooleanResultBlock)callback
__deprecated_msg("Deprecated, use `+[AVSMS requestShortMessageForPhoneNumber:options:callback:]` instead.");

+ (void)requestVoiceCodeWithPhoneNumber:(NSString *)phoneNumber
                                    IDD:(nullable NSString *)IDD
                               callback:(AVBooleanResultBlock)callback
__deprecated_msg("Deprecated, use `+[AVSMS requestShortMessageForPhoneNumber:options:callback:]` instead.");

+ (void)handleRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
                                          teamId:(NSString *)teamId
__deprecated_msg("Deprecated, use `AVInstallation` instead.");

+ (void)handleRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
                                          teamId:(NSString *)teamId
               constructingInstallationWithBlock:(nullable void (^)(AVInstallation *))block
__deprecated_msg("Deprecated, use `AVInstallation` instead.");

@end

NS_ASSUME_NONNULL_END
