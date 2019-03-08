//
//  SQLProLogHelperDelegate.m
//  SQLPro for MSSQL
//
//  Created by Kyle Hankinson on 2016-12-01.
//  Copyright © 2016 Hankinsoft Development, Inc. All rights reserved.
//

#import "SQLProLogHelperDelegate.h"

@implementation SQLProLogHelperDelegate
{
    DDFileLogger                * fileLogger;
}

+ (instancetype) sharedInstance
{
    // structure used to test whether the block has completed or not
    static dispatch_once_t p = 0;
    
    // initialize sharedObject as nil (first call only)
    __strong static SQLProLogHelperDelegate * _sharedObject = nil;
    
    // executes a block object once and only once for the lifetime of an application
    dispatch_once(&p, ^{
        _sharedObject = [[SQLProLogHelperDelegate alloc] init];
        
        DDFileLogger * fileLogger = [[DDFileLogger alloc] init];
        fileLogger.rollingFrequency                       = 60 * 60 * 24; // 24 hour rolling
        fileLogger.logFileManager.maximumNumberOfLogFiles = 1;
        
        // Set the file logger
        _sharedObject->fileLogger = fileLogger;
    });

    // returns the same object each time
    return _sharedObject;
} // End of sharedInstance

- (DDFileLogger*) fileLogger
{
    return fileLogger;
} // End of fileLogger

#pragma mark -
#pragma mark HSLogHelperDelegate

- (void) HSLogHelper: (HSLogHelper*) logHelper
          logMessage: (NSString*) logMessage
{
    NSLog(@"%@", logMessage);
} // End of HSLogHelper:logMessage:

- (void) HSLogHelper: (nonnull HSLogHelper*) logHelper
            logEvent: (nonnull NSString*) eventName
         withDetails: (nullable NSDictionary*) details
{
#if !DEBUG
    [MSAnalytics trackEvent: eventName
             withProperties: details];
#endif
} // End of HSLogHelper:logEvent:withDetails:

- (void) HSLogHelper: (nonnull HSLogHelper*) logHelper
            logError: (nonnull NSError *)errorToLog
         withDetails: (nullable NSDictionary*) details
{
#if !DEBUG
    NSString * eventName = [NSString stringWithFormat: @"Error-%@", nil == errorToLog.domain ? @"<nil>" : errorToLog.domain];
    [MSAnalytics trackEvent: eventName
             withProperties: errorToLog.userInfo];
#endif
} // End of HSLogHelper:logError:

- (void) HSLogHelper: (nonnull HSLogHelper*) logHelper
     setCrashDetails: (nullable id) value
              forKey: (nullable NSString*) key
{
/*
    [CrashlyticsKit setObjectValue: value
                            forKey: key];
*/
} // End of HSLogHelper:setCrashDetails:forKey:

- (void) HSLogHelper: (nonnull HSLogHelper*) logHelper
            logLogin: (nonnull NSString*) loginMethod
             success: (BOOL) success
             details: (NSDictionary*) details
{
#if !DEBUG
    NSString * eventName = [NSString stringWithFormat: @"Login-%@", nil == loginMethod ? @"<nil>" : loginMethod];
    [MSAnalytics trackEvent: eventName
             withProperties: details];
#endif
} // End of HSLogHelper:logLogin:success:

- (void) HSLogHelper: (nonnull HSLogHelper*) logHelper
logPurchaseWithPrice: (nonnull NSDecimalNumber*) purchasePrice
            currency: (nonnull NSString*) currency
             success: (BOOL) success
            itemName: (nonnull NSString*) itemName
            itemType: (nonnull NSString*) itemType
              itemId: (nonnull NSString*) itemId
    customAttributes: (nullable NSDictionary*) customAttributes
{
    if(!success)
    {
        return;
    } // End of no success

    // No purchases to log
}

#pragma mark -
#pragma mark MSCrashesDelegate

- (NSArray<MSErrorAttachmentLog *> *)attachmentsWithCrashes: (MSCrashes *) crashes
                                             forErrorReport: (MSErrorReport *) errorReport
{
    NSString * logString = [self getLogFilesContentWithMaxSize: 1024 * 5]; // Max 5mb logs
    MSErrorAttachmentLog * textLog = [MSErrorAttachmentLog attachmentWithText: logString
                                                                     filename: @"log.txt"];

    return @[textLog];
} // End of attachementsWithCrashes:forErrorReport

// get the log content with a maximum byte size
- (NSString *) getLogFilesContentWithMaxSize: (NSInteger) maxSize
{
    NSMutableString *description = [NSMutableString string];

    NSArray *sortedLogFileInfos = [[fileLogger logFileManager] sortedLogFileInfos];
    NSInteger count = [sortedLogFileInfos count];
    
    // we start from the last one
    for (NSInteger index = count - 1; index >= 0; index--)
    {
        DDLogFileInfo *logFileInfo = [sortedLogFileInfos objectAtIndex:index];
        
        NSData *logData = [[NSFileManager defaultManager] contentsAtPath:[logFileInfo filePath]];
        if ([logData length] > 0) {
            NSString *result = [[NSString alloc] initWithBytes:[logData bytes]
                                                        length:[logData length]
                                                      encoding: NSUTF8StringEncoding];
            
            [description appendString:result];
        }
    }

    if ([description length] > maxSize)
    {
        description = (NSMutableString *)[description substringWithRange:NSMakeRange([description length]-maxSize-1, maxSize)];
    }
    
    return description;
}

@end
