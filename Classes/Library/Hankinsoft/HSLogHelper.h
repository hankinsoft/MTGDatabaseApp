//
//  HSLogHelper.h
//  HSShared
//
//  Created by Kyle Hankinson on 2015-12-18.
//  Copyright © 2015 Hankinsoft Development, Inc. All rights reserved.
//

@import Foundation;

#if TARGET_OS_IPHONE

#import <UIKit/UIKit.h>

#else

#import <Cocoa/Cocoa.h>

#endif

@class HSLogHelper;

@protocol HSLogHelperDelegate<NSObject>

- (void) HSLogHelper: (nonnull HSLogHelper*) logHelper
          logMessage: (nonnull NSString*) logMessage;

- (void) HSLogHelper: (nonnull HSLogHelper*) logHelper
            logEvent: (nonnull NSString*) eventName
         withDetails: (nullable NSDictionary*) details;

- (void) HSLogHelper: (nonnull HSLogHelper*) logHelper
            logError: (nonnull NSError*) errorToLog
         withDetails: (nullable NSDictionary*) details;

- (void) HSLogHelper: (nonnull HSLogHelper*) logHelper
     setCrashDetails: (nullable id) value
              forKey: (nullable NSString*) key;

- (void) HSLogHelper: (nonnull HSLogHelper*) logHelper
            logLogin: (nonnull NSString*) loginMethod
             success: (BOOL) success
             details: (nullable NSDictionary*) details;

- (void) HSLogHelper: (nonnull HSLogHelper*) logHelper
logPurchaseWithPrice: (nonnull NSDecimalNumber*) purchasePrice
            currency: (nonnull NSString*) currency
             success: (BOOL) success
            itemName: (nonnull NSString*) itemName
            itemType: (nonnull NSString*) itemType
              itemId: (nonnull NSString*) itemId
    customAttributes: (nullable NSDictionary*) customAttributes;

@end

@interface HSLogHelper : NSObject

+ (nonnull HSLogHelper*) sharedInstance;

- (void) logMessage: (nonnull NSString*) messageToLog, ...;

- (void) logLogin: (nonnull NSString*) loginMethod
          success: (BOOL) success
          details: (nullable NSDictionary*) details;

- (void) logPurchaseWithPrice: (nonnull NSDecimalNumber*) purchasePrice
                     currency: (nonnull NSString*) currency
                      success: (BOOL) success
                     itemName: (nonnull NSString*) itemName
                     itemType: (nonnull NSString*) itemType
                       itemId: (nonnull NSString*) itemId
             customAttributes: (nullable NSDictionary*) customAttributes;

- (void) logError: (nonnull NSError*) errorToLog
      withDetails: (nullable NSDictionary*) details;

- (void) logErrorMessage: (nonnull NSString*) errorMessageToLog
              withDomain: (nullable NSString*) domain
             withDetails: (nullable NSDictionary*) details
             ifTimeTaken: (CGFloat) timeTaken
          isGreatherThan: (CGFloat) expectedTime;

- (void) logEvent: (nonnull NSString*) eventName
         withDetails: (nullable NSDictionary*) details;

- (void) setCrashDetails: (nullable id) value
                  forKey: (nonnull NSString*) key;

@property(nonatomic,assign)         BOOL enabled;
@property(nonatomic,weak,nullable)  id<HSLogHelperDelegate> delegate;

@end
