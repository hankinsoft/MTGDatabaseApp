//
//  RMStoreFramework.h
//  RMStoreFramework
//
//  Created by kylehankinson on 2018-08-27.
//  Copyright © 2018 Robot Media. All rights reserved.
//

#import <Foundation/Foundation.h>

#if TARGET_OS_IPHONE
@import UIKit;
#endif
#if !TARGET_OS_IPHONE && TARGET_OS_MAC
@import AppKit;
#endif

//! Project version number for RMStoreFramework.
FOUNDATION_EXPORT double RMStoreFrameworkVersionNumber;

//! Project version string for RMStoreFramework.
FOUNDATION_EXPORT const unsigned char RMStoreFrameworkVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <RMStoreFramework/PublicHeader.h>
#import "RMStore.h"
#import "RMAppReceipt.h"
#import "RMStoreAppReceiptVerifier.h"
#import "RMStoreKeychainPersistence.h"
#import "RMStoreUserDefaultsPersistence.h"
#import "RMStoreTransaction.h"
