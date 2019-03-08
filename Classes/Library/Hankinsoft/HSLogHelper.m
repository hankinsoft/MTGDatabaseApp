//
//  HSLogHelper.m
//  HSShared
//
//  Created by Kyle Hankinson on 2015-12-18.
//  Copyright © 2015 Hankinsoft Development, Inc. All rights reserved.
//

#import "HSLogHelper.h"

@implementation HSLogHelper
{
    BOOL isRunningInInstruments;
}

@synthesize delegate;

+ (HSLogHelper*) sharedInstance
{
    // structure used to test whether the block has completed or not
    static dispatch_once_t p = 0;
    
    // initialize sharedObject as nil (first call only)
    __strong static HSLogHelper* _sharedObject = nil;

    // executes a block object once and only once for the lifetime of an application
    dispatch_once(&p, ^{
        _sharedObject = [[self alloc] init];
        _sharedObject.enabled = YES;
    });

    // returns the same object each time
    return _sharedObject;
} // End of sharedInstance

- (id) init
{
    self = [super init];
    if(self)
    {
        isRunningInInstruments = NO;

        NSProcessInfo *processInfo = [NSProcessInfo processInfo];
        NSString * XPCServiceName = processInfo.environment[@"XPC_SERVICE_NAME"];

        if(NSNotFound != [XPCServiceName rangeOfString: @"com.apple.dt.Instruments"].location)
        {
            isRunningInInstruments = YES;
        } // End of we are running in instruments
    } // End of self
    
    return self;
} // End of init

- (void) setEnabled: (BOOL) enabled
{
    if(!enabled)
    {
        while(false); // Allow breakpoint
    }

    _enabled = enabled;
} // End of setEnabled;

- (void) logMessage: (NSString*) messageToLog, ...
{
    // Note: We still log messages no matter if feedback is enabled or not. Disabling
    // just disables things such as analytics
/*
    if(!self.enabled)
    {
        return;
    } // End of not enabled
*/
    if(nil == self.delegate)
    {
        return;
    } // End of delegate is nil

    if(![self.delegate respondsToSelector: @selector(HSLogHelper:logMessage:)])
    {
        return;
    } // End of delegate does not implement proper selector

    va_list args;
    va_start(args, messageToLog);

    NSString * formattedLogMessage =
        [[NSString alloc] initWithFormat: messageToLog arguments:args];

    [self.delegate HSLogHelper: self
                    logMessage: formattedLogMessage];

    va_end(args);
} // End of logMessage

- (void) logPurchaseWithPrice: (nonnull NSDecimalNumber*) purchasePrice
                     currency: (nonnull NSString*) currency
                      success: (BOOL) success
                     itemName: (nonnull NSString*) itemName
                     itemType: (nonnull NSString*) itemType
                       itemId: (nonnull NSString*) itemId
             customAttributes: (nullable NSDictionary*) customAttributes
{
    if(!self.enabled)
    {
        return;
    }

    if(nil == self.delegate)
    {
        return;
    } // End of delegate is nil
    
    if(![self.delegate respondsToSelector: @selector(HSLogHelper:logPurchaseWithPrice:currency:success:itemName:itemType:itemId:customAttributes:)])
    {
        return;
    }

    [self.delegate HSLogHelper: self
          logPurchaseWithPrice: purchasePrice
                      currency: currency
                       success: success
                      itemName: itemName
                      itemType: itemType
                        itemId: itemId
              customAttributes: customAttributes];
} // End of logPurchaseWithPrice

- (void) logLogin: (nonnull NSString*) loginMethod
          success: (BOOL) success
          details: (NSDictionary*) details
{
    if(!self.enabled)
    {
        return;
    } // End of not enabled
    
    if(nil == self.delegate)
    {
        return;
    } // End of delegate is nil

    if(![self.delegate respondsToSelector: @selector(HSLogHelper:logLogin:success:details:)])
    {
        return;
    } // End of delegate does not implement proper selector

    // Log our login
    [self.delegate HSLogHelper: self
                      logLogin: loginMethod
                       success: success
                       details: details];
} // End of logLogin

- (void) logError: (nonnull NSError*) errorToLog
      withDetails: (nullable NSDictionary*) details
{
    if(!self.enabled)
    {
        return;
    } // End of not enabled

    if(nil == self.delegate)
    {
        return;
    } // End of delegate is nil

    if(![self.delegate respondsToSelector: @selector(HSLogHelper:logError:withDetails:)])
    {
        return;
    } // End of delegate does not implement proper selector

    [self.delegate HSLogHelper: self
                      logError: errorToLog
                   withDetails: details];
} // End of logError:

- (void) logErrorMessage: (nonnull NSString*) errorMessageToLog
              withDomain: (nullable NSString*) domain
             withDetails: (nullable NSDictionary*) details
             ifTimeTaken: (CGFloat) timeTaken
          isGreatherThan: (CGFloat) expectedTime
{
    if(!self.enabled)
    {
        return;
    } // End of not enabled

    if(timeTaken < expectedTime)
    {
        return;
    } // End of we do not need to log

    if(nil == self.delegate)
    {
        return;
    } // End of delegate is nil

    if(![self.delegate respondsToSelector: @selector(HSLogHelper:logError:withDetails:)])
    {
        return;
    } // End of delegate does not implement proper selector

    // Do not log slow when instruments is running
    if(isRunningInInstruments)
    {
        return;
    } // End of running in instruments

#ifndef DEBUG
    // Debug does not log slow. We could be at a breakpoint, etc.
    NSError * errorToLog =
        [NSError errorWithDomain: domain
                            code: 0
                        userInfo: @{NSLocalizedDescriptionKey: errorMessageToLog}];

    NSMutableDictionary * additionalDetails = details.mutableCopy;

    if(timeTaken < 1)
    {
        additionalDetails[@"timeTaken"] = [NSString stringWithFormat: @"%0.2fms", timeTaken];
    }
    else
    {
        additionalDetails[@"timeTaken"] = [NSString stringWithFormat: @"%0.2fs", timeTaken];
    }

    [self.delegate HSLogHelper: self
                      logError: errorToLog
                   withDetails: additionalDetails];
#endif
} // End of logError:withDetails:ifTimeTaken:isGreaterThan:

- (void) logEvent: (nonnull NSString*) eventName
      withDetails: (nullable NSDictionary*) details
{
    if(!self.enabled)
    {
        return;
    } // End of not enabled

    if(nil == self.delegate)
    {
        return;
    } // End of delegate is nil

    if(![self.delegate respondsToSelector: @selector(HSLogHelper:logEvent:withDetails:)])
    {
        return;
    } // End of delegate does not implement proper selector

    [self.delegate HSLogHelper: self
                      logEvent: eventName
                   withDetails: details];
} // End of logEvent:withDetails:

- (void) setCrashDetails: (nullable id) value
                  forKey: (nonnull NSString*) key
{
    if(!self.enabled)
    {
        return;
    } // End of not enabled

    if(nil == self.delegate)
    {
        return;
    } // End of delegate is nil

    if(![self.delegate respondsToSelector: @selector(HSLogHelper:setCrashDetails:forKey:)])
    {
        return;
    } // End of delegate does not implement proper selector

    [self.delegate HSLogHelper: self
               setCrashDetails: value
                        forKey: key];
} // End of setCrashDetails:forKey:

@end
