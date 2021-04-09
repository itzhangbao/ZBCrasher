/*
 * Author: Jumbo <hi@itzhangbao.com>
 *
 * Copyright (c) 2012-2021 @itzhangbao.
 * All rights reserved.
 *
 * Permission is hereby granted, free of charge, to any person
 * obtaining a copy of this software and associated documentation
 * files (the "Software"), to deal in the Software without
 * restriction, including without limitation the rights to use,
 * copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following
 * conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 * OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 * HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 * WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 * OTHER DEALINGS IN THE SOFTWARE.
 */

#if __has_include(<ZBCrasherManager/ZBCrasherManager.h>)
#import <ZBCrasher/ZBCrasher.h>
#import <ZBCrasher/ZBCrasherManager.h>
#else
#import "ZBCrasher.h"
#import "ZBCrasherManager.h"
#endif

#import "ZBCrasherHandlerDelegate.h"
#import "ZBNSExceptionHandler.h"
#import "ZBSignalHandler.h"

/** @internal
 * Crasher cache directory name. */
static NSString *ZBCRASH_CACHE_DIR = @"com.itzhangbao.crasher.data";

/** @internal
 * Crash Report file name. */
static NSString *ZBCRASH_LIVE_CRASHREPORT = @"live_report.plcrash";

/** @internal
 * Directory containing crash reports queued for sending. */
static NSString *ZBCRASH_QUEUED_DIR = @"queued_reports";

/* @internal
 * crash call back */
static ZBCrasherCallback crashCallback;

@interface ZBCrasherManager()<ZBCrasherHandlerDelegate>

@end

@interface ZBCrasherManager (PrivateMethods)

- (id) initWithBundle:(NSBundle *)bundle configuration:(ZBCrasherConfig *)configuration;

- (BOOL) populateCrasherDirectoryAndReturnError: (NSError **) outError;
- (NSString *) crasherDirectory;
- (NSString *) queuedCrasherDirectory;
- (NSString *) crashReportPath;
@end

@implementation ZBCrasherManager

+ (NSString *)version {
    return @"0.1.0";
}

/* (Deprecated) Crash manager singleton. */
static ZBCrasherManager *_manager = nil;

/**
 * Return the default crash reporter instance. The returned instance will be configured
 * appropriately for release deployment.
 */
+ (ZBCrasherManager *) manager {
    static dispatch_once_t onceLock;
    dispatch_once(&onceLock, ^{
        if (_manager == nil)
            _manager = [[ZBCrasherManager alloc] initWithBundle: [NSBundle mainBundle] configuration: [ZBCrasherConfig defaultConfiguration]];
    });
    return _manager;
}

/**
 * Initialize a new PLCrashReporter instance with a default configuration appropraite
 * for release deployment.
 */
- (instancetype) init {
    return [self initWithConfiguration: [ZBCrasherConfig defaultConfiguration]];
}

/**
 * Initialize a new PLCrashReporter instance with the given configuration.
 *
 * @param configuration The configuration to be used by this reporter instance.
 */
- (instancetype) initWithConfiguration:(ZBCrasherConfig *) configuration {
    return [self initWithBundle: [NSBundle mainBundle] configuration: configuration];
}

/**
 * Returns YES if the application has previously crashed and
 * an pending crash report is available.
 */
- (BOOL) hasPendingCrashReport {
    /* Check for a live crash report file */
    return [[NSFileManager defaultManager] fileExistsAtPath: [self crashReportPath]];
}

/**
 * If an application has a pending crash report, this method returns the crash
 * report data.
 *
 * You may use this to submit the report to your own HTTP server, over e-mail, or even parse and
 * introspect the report locally using the PLCrashReport API.
 *
 * @return Returns nil if the crash report data could not be loaded.
 */
- (NSData *) loadPendingCrashReportData {
    return [self loadPendingCrashReportDataAndReturnError: NULL];
}

/**
 * If an application has a pending crash report, this method returns the crash
 * report data.
 *
 * You may use this to submit the report to your own HTTP server, over e-mail, or even parse and
 * introspect the report locally using the PLCrashReport API.
 
 * @param outError A pointer to an NSError object variable. If an error occurs, this pointer
 * will contain an error object indicating why the pending crash report could not be
 * loaded. If no error occurs, this parameter will be left unmodified. You may specify
 * nil for this parameter, and no error information will be provided.
 *
 * @return Returns nil if the crash report data could not be loaded.
 */
- (NSData *) loadPendingCrashReportDataAndReturnError: (NSError **) outError {
    /* Load the (memory mapped) data */
    return [NSData dataWithContentsOfFile: [self crashReportPath] options: NSMappedRead error: outError];
}

/**
 * Purge a pending crash report.
 *
 * @return Returns YES on success, or NO on error.
 */
- (BOOL) purgePendingCrashReport {
    return [self purgePendingCrashReportAndReturnError: NULL];
}

/**
 * Purge a pending crash report.
 *
 * @return Returns YES on success, or NO on error.
 */
- (BOOL) purgePendingCrashReportAndReturnError: (NSError **) outError {
    return [[NSFileManager defaultManager] removeItemAtPath: [self crashReportPath] error: outError];
}

/**
 * Enable the crasher. Once called, all application crashes will
 * result in a crash report being written prior to application exit.
 *
 * @return Returns YES on success, or NO if the crash reporter could
 * not be enabled.
 *
 * @par Registering Multiple Reporters
 *
 * Only one ZBCrasher instance may be enabled in a process; attempting to enable an additional instance
 * will return NO, and the reporter will not be enabled. This restriction may be removed in a future release.
 */
- (BOOL) enableCrasher {
    return [self enableCrasherAndReturnError: nil];
}

/**
 * Enable the crash reporter. Once called, all application crashes will
 * result in a crash report being written prior to application exit.
 *
 * This method must only be invoked once. Further invocations will throw
 * a PLCrashReporterException.
 *
 * @param outError A pointer to an NSError object variable. If an error occurs, this pointer
 * will contain an error in the PLCrashReporterErrorDomain indicating why the Crash Reporter
 * could not be enabled. If no error occurs, this parameter will be left unmodified. You may
 * specify nil for this parameter, and no error information will be provided.
 *
 * @return Returns YES on success, or NO if the crash reporter could
 * not be enabled.
 *
 * @par Registering Multiple Reporters
 *
 * Only one PLCrashReporter instance may be enabled in a process; attempting to enable an additional instance
 * will return NO and a PLCrashReporterErrorResourceBusy error, and the reporter will not be enabled.
 * This restriction may be removed in a future release.
 */
- (BOOL) enableCrasherAndReturnError: (NSError **) outError {
    
    /* Check for programmer error */
    if (_enabled)
        [NSException raise: ZBCrasherException format: @"The crash reporter has alread been enabled"];

    /* Create the directory tree */
    if (![self populateCrasherDirectoryAndReturnError: outError])
        return NO;
    
    /* register crash report */
    [self zb_registerCrashReport];
    
    /* Success */
    _enabled = YES;
    return YES;
}

- (void)zb_registerCrashReport {
    // exception handler
    [ZBNSExceptionHandler handler].delegate = self;
    [ZBNSExceptionHandler zb_registerUncaughtExceptionHandler];
    // signal handler
    [ZBSignalHandler handler].delegate = self;
    [ZBSignalHandler zb_registerSignalHandler];
}

// MARK: - crash handler delegate
- (void)zb_crashHandlerModel:(nonnull ZBCrasherModel *)model {
    
    // write file
    
    // av cloud
    
    // call back
    if (crashCallback != NULL) {
        crashCallback(model);
    }
    
    // un register
    [ZBNSExceptionHandler zb_unRegisterUncaughtExceptionHandler];
    [ZBSignalHandler zb_unRegisterSignalHandler];
}

/* set crash call back*/
- (void)setCrasherCallBack:(ZBCrasherCallback)callback {
    crashCallback = callback;
}

@end

/**
 * @internal
 *
 * Private Methods
 */
@implementation ZBCrasherManager (PrivateMethods)

/**
 * @internal
 *
 * This is the designated initializer, but it is not intended
 * to be called externally.
 *
 * @param applicationIdentifier The application identifier to be included in crash reports.
 * @param applicationVersion The application version number to be included in crash reports.
 * @param applicationMarketingVersion The application marketing version number to be included in crash reports.
 * @param configuration The ZBCrasher configuration.
 *
 * @todo The appId and version values should be fetched from the ZBCrasherConfig, once the API
 * has been extended to allow supplying these values.
 */
- (id) initWithApplicationIdentifier: (NSString *) applicationIdentifier appVersion: (NSString *) applicationVersion appMarketingVersion: (NSString *) applicationMarketingVersion configuration: (ZBCrasherConfig *) configuration {
    /* Initialize our superclass */
    if ((self = [super init]) == nil)
        return nil;

    /* Save the configuration */
    _config = configuration;
    _applicationIdentifier = applicationIdentifier;
    _applicationVersion = applicationVersion;
    _applicationMarketingVersion = applicationMarketingVersion;
    
    /* No occurances of '/' should ever be in a bundle ID, but just to be safe, we escape them */
    NSString *appIdPath = [applicationIdentifier stringByReplacingOccurrencesOfString: @"/" withString: @"_"];
    
    NSString *basePath = _config.basePath;
    if (basePath == nil) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        basePath = [paths objectAtIndex: 0];
    }
    _crashReportDirectory = [[basePath stringByAppendingPathComponent: ZBCRASH_CACHE_DIR] stringByAppendingPathComponent: appIdPath];
    
    return self;
}

/**
 * @internal
 *
 * Derive the bundle identifier and version from @a bundle.
 *
 * @param bundle The application's main bundle.
 * @param configuration The ZBCrasher configuration to use for this instance.
 */
- (id) initWithBundle: (NSBundle *) bundle configuration: (ZBCrasherConfig *) configuration {
    NSString *bundleIdentifier = [bundle bundleIdentifier];
    NSString *bundleVersion = [[bundle infoDictionary] objectForKey: (NSString *) kCFBundleVersionKey];
    NSString *bundleMarketingVersion = [[bundle infoDictionary] objectForKey: @"CFBundleShortVersionString"];
    
    /* Verify that the identifier is available */
    if (bundleIdentifier == nil) {
        const char *progname = getprogname();
        if (progname == NULL) {
            [NSException raise: ZBCrasherException format: @"Can not determine process identifier or process name"];
            return nil;
        }

//        PLCR_LOG("Warning -- bundle identifier, using process name %s", progname);
        bundleIdentifier = [NSString stringWithUTF8String: progname];
    }

    /* Verify that the version is available */
    if (bundleVersion == nil) {
//        PLCR_LOG("Warning -- bundle version unavailable");
        bundleVersion = @"";
    }

    return [self initWithApplicationIdentifier: bundleIdentifier appVersion: bundleVersion appMarketingVersion:bundleMarketingVersion configuration: configuration];
}

/**
 * Validate (and create if necessary) the crash reporter directory structure.
 */
- (BOOL) populateCrasherDirectoryAndReturnError: (NSError **) outError {
    NSFileManager *fm = [NSFileManager defaultManager];
    
    /* Set up reasonable directory attributes */
    NSDictionary *attributes = [NSDictionary dictionaryWithObject: [NSNumber numberWithUnsignedLong: 0755] forKey: NSFilePosixPermissions];
    
    /* Create the top-level path */
    if (![fm fileExistsAtPath: [self crasherDirectory]] &&
        ![fm createDirectoryAtPath: [self crasherDirectory] withIntermediateDirectories: YES attributes: attributes error: outError])
    {
        return NO;
    }

    /* Create the queued crash report directory */
    if (![fm fileExistsAtPath: [self queuedCrasherDirectory]] &&
        ![fm createDirectoryAtPath: [self queuedCrasherDirectory] withIntermediateDirectories: YES attributes: attributes error: outError])
    {
        return NO;
    }

    return YES;
}

/**
 * Return the path to the crash reporter data directory.
 */
- (NSString *) crasherDirectory {
    return _crashReportDirectory;
}

/**
 * Return the path to to-be-sent crash reports.
 */
- (NSString *) queuedCrasherDirectory {
    return [[self crasherDirectory] stringByAppendingPathComponent: ZBCRASH_QUEUED_DIR];
}

/**
 * Return the path to live crash report (which may not yet, or ever, exist).
 */
- (NSString *) crashReportPath {
    return [[self crasherDirectory] stringByAppendingPathComponent: ZBCRASH_LIVE_CRASHREPORT];
}
@end
