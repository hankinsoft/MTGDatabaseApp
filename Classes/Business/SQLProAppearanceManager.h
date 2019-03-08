//
//  SQLProAppearanceManager.h
//  SQLPro (iOS)
//
//  Created by Kyle Hankinson on 2016-11-24.
//  Copyright © 2016 Hankinsoft Development, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum
{
    SQLProThemeNone  = 0,
    SQLProThemeLight = 1,
    SQLProThemeDark  = 2,
} SQLProTheme;

@interface SQLProAppearanceManager : NSObject

+ (NSString*) apperanceUpdatedNotificationName;
+ (void) postApperanceUpdatedNotification;

+ (SQLProAppearanceManager*) sharedInstance;

- (void) switchToAlternateTheme;
- (void) updateThemeIfRequired;

- (void) redrawAppAndNotify;

- (UIColor*) destructiveColor;

- (UIColor*) darkTableBackgroundColor;
- (UIColor*) darkTableViewCellBackgroundColor;
- (UIColor*) darkTableViewCellTextColor;
- (UIColor*) darkTableViewSeparatorColor;

- (UIColor*) lightTableBackgroundColor;
- (UIColor*) lightTableViewCellBackgroundColor;
- (UIColor*) lightTableViewCellTextColor;
- (UIColor*) lightTableViewSeparatorColor;

- (void) updateTheme: (SQLProTheme) theme
     completionBlock: (void (^)(void)) completionBlock;

@end
