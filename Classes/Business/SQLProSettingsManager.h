//
//  SQLProSettingsManager.h
//  SQLPro (iOS)
//
//  Created by Kyle Hankinson on 2016-11-24.
//  Copyright © 2016 Hankinsoft Development, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SQLProAppearanceManager.h"

@interface SQLProSettingsManager : NSObject

+ (SQLProSettingsManager*) sharedInstance;
+ (NSString*) notificationName;
- (void) updateAndNotify;

@property(nonatomic,assign) NSUInteger  mainConnectionListMode;
@property(nonatomic,assign) BOOL        sendAnalyticsAndCrashDetails;
@property(nonatomic,assign) BOOL        displaySampleDatabases;
@property(nonatomic,assign) NSUInteger  autoThemeSwitchPercentage;
@property(nonatomic,assign) SQLProTheme theme;
@property(nonatomic,copy)   NSString    * editorThemeName;
@property(nonatomic,copy)   NSString    * editorThemeFontName;

@end
