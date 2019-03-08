//
//  SQLProLogHelperDelegate.h
//  SQLPro for MSSQL
//
//  Created by Kyle Hankinson on 2016-12-01.
//  Copyright © 2016 Hankinsoft Development, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
@import AppCenter;
@import AppCenterAnalytics;
@import AppCenterCrashes;

@interface SQLProLogHelperDelegate : NSObject<HSLogHelperDelegate, MSCrashesDelegate>

+ (instancetype) sharedInstance;
- (DDFileLogger*) fileLogger;

@end
