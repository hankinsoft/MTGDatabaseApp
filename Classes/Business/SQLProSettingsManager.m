//
//  SQLProSettingsManager.m
//  SQLPro (iOS)
//
//  Created by Kyle Hankinson on 2016-11-24.
//  Copyright © 2016 Hankinsoft Development, Inc. All rights reserved.
//

#import "SQLProSettingsManager.h"

#define kTheme                          @"ApplicationPreference-Theme"
#define kSendAnalyticsAndCrashDetails   @"ApplicationPreference-EnableAnalyticsAndCrash"
#define kEnableSampleDatabases          @"ApplicationPreference-EnableSampleDatabases"
#define kEditorThemeName                @"ApplicationPreference-ThemeName"
#define kMainConnectionListMode         @"ApplicationPreference-mainConnectionListMode"

#define kAutoThemeSwitchPercentage      @"ApplicationPreference-AutoThemeSwitchPercentage"

#define kEditorThemeFontName            @"ApplicationPreference-ThemeFontName"

@implementation SQLProSettingsManager

+ (void) initialize
{
    // Setup our user defaults
    NSBundle * mb = [NSBundle mainBundle];
    
    NSString * defaultsFile = [mb pathForResource: @"Defaults"
                                           ofType: @"plist"];

    NSDictionary * appDefaults = [NSDictionary dictionaryWithContentsOfFile: defaultsFile];

    [[NSUserDefaults standardUserDefaults] registerDefaults: appDefaults];
} // End of initialize

+ (NSString*) notificationName
{
    return @"com.hankinsoft.sqlpro.preferencesChangedNotification";
} // End of notificationName

+ (SQLProSettingsManager*) sharedInstance
{
    // structure used to test whether the block has completed or not
    static dispatch_once_t p = 0;
    
    // initialize sharedObject as nil (first call only)
    __strong static SQLProSettingsManager* _sharedObject = nil;

    // executes a block object once and only once for the lifetime of an application
    dispatch_once(&p, ^{
        _sharedObject = [[self alloc] init];
    });
    
    // returns the same object each time
    return _sharedObject;
} // End of sharedInstance

- (instancetype) init
{
    self = [super init];
    if(self)
    {
        NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];

        // Load up our defaults
        _theme = (SQLProTheme) [defaults integerForKey: kTheme];

        _sendAnalyticsAndCrashDetails =
            [defaults boolForKey: kSendAnalyticsAndCrashDetails];

        _editorThemeName =
            [defaults stringForKey: kEditorThemeName];

        _editorThemeFontName =
            [defaults stringForKey: kEditorThemeFontName];

        _mainConnectionListMode =
            [[defaults objectForKey: kMainConnectionListMode] unsignedIntegerValue];

        _autoThemeSwitchPercentage =
            [[defaults objectForKey: kAutoThemeSwitchPercentage] unsignedIntegerValue];

        _displaySampleDatabases =
            [defaults boolForKey: kEnableSampleDatabases];
    } // End of self

    return self;
} // End of init

- (void) updateAndNotify
{
    // Save our defaults
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];

    [defaults setObject: self.editorThemeName
                 forKey: kEditorThemeName];

    [defaults setObject: self.editorThemeFontName
                 forKey: kEditorThemeFontName];

    [defaults setInteger: (SQLProTheme) self.theme
                  forKey: kTheme];

    [defaults setBool: self.sendAnalyticsAndCrashDetails
               forKey: kSendAnalyticsAndCrashDetails];

    [defaults setObject: [NSNumber numberWithUnsignedInteger: self.mainConnectionListMode]
                 forKey: kMainConnectionListMode];

    [defaults setObject: [NSNumber numberWithUnsignedInteger: self.autoThemeSwitchPercentage]
                 forKey: kAutoThemeSwitchPercentage];
    
    [defaults setObject: @(self.displaySampleDatabases)
                 forKey: kEnableSampleDatabases];

    // Sync
    [defaults synchronize];

    // Fire the event
    [[NSNotificationCenter defaultCenter] postNotificationName: [SQLProSettingsManager notificationName]
                                                        object: nil];
} // End of updateAndNotify

@end
