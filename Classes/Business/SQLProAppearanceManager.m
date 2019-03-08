//
//  SQLProAppearanceManager.m
//  SQLPro (iOS)
//
//  Created by Kyle Hankinson on 2016-11-24.
//  Copyright © 2016 Hankinsoft Development, Inc. All rights reserved.
//

#import "SQLProAppearanceManager.h"
#import "SQLProSettingsManager.h"
#import "HSDividerView.h"
#import "DRPLoadingSpinner.h"

#import "SQLProCollectionView.h"
#import "SQLProTableView.h"
#import "UITableViewCell+SQLProApperance.h"

@import XLForm;

@implementation SQLProAppearanceManager
{
    UIWindow * overlayWindow;
}

+ (NSString*) apperanceUpdatedNotificationName
{
    return @"com.hankinsoft.sqlpro.apperanceUpdated";
} // End of apperanceUpdatedNotificationName

+ (void) postApperanceUpdatedNotification
{
    NSNotificationCenter * nc = [NSNotificationCenter defaultCenter];

    [nc postNotificationName: [self apperanceUpdatedNotificationName]
                      object: nil];
} // End of postApperanceUpdatedNotification

+ (SQLProAppearanceManager*) sharedInstance
{
    // structure used to test whether the block has completed or not
    static dispatch_once_t p = 0;
    
    // initialize sharedObject as nil (first call only)
    __strong static SQLProAppearanceManager* _sharedObject = nil;

    // executes a block object once and only once for the lifetime of an application
    dispatch_once(&p, ^{
        _sharedObject = [[self alloc] init];
    });

    // returns the same object each time
    return _sharedObject;
} // End of sharedInstance

- (void) switchToAlternateTheme
{
    SQLProTheme theme = SQLProThemeNone;
    NSString * editorThemeName = @"WWDC16";

    if(SQLProSettingsManager.sharedInstance.theme == SQLProThemeDark)
    {
        theme = SQLProThemeLight;
        editorThemeName = @"Default";
    }
    else
    {
        theme = SQLProThemeDark;
        editorThemeName = @"WWDC16";
    }

    [[SQLProSettingsManager sharedInstance] setEditorThemeName: editorThemeName];
    [[SQLProSettingsManager sharedInstance] setTheme: theme];
    [[SQLProSettingsManager sharedInstance] updateAndNotify];
    
    [[SQLProAppearanceManager sharedInstance] updateTheme: theme
                                          completionBlock: ^{
        [[SQLProAppearanceManager sharedInstance] redrawAppAndNotify];
    }];
} // End of switchToAlternateTheme

- (void) updateThemeIfRequired
{
    NSUInteger brightness = ABS([UIScreen mainScreen].brightness * 100.0f);

    SQLProTheme theme = SQLProThemeNone;
    NSString * editorThemeName = @"WWDC16";

    if(NSNotFound == SQLProSettingsManager.sharedInstance.autoThemeSwitchPercentage)
    {
        if(SQLProSettingsManager.sharedInstance.theme == SQLProThemeDark)
        {
            theme = SQLProThemeDark;
            editorThemeName = @"WWDC16";
        }
        else
        {
            theme = SQLProThemeLight;
            editorThemeName = @"Default";
        }
    }
    else
    {
        if(brightness > SQLProSettingsManager.sharedInstance.autoThemeSwitchPercentage)
        {
            theme = SQLProThemeLight;
            editorThemeName = @"Default";
        }
        else
        {
            theme = SQLProThemeDark;
            editorThemeName = @"WWDC16";
        }
    } // End of using an auto switch

    if(theme == [SQLProSettingsManager sharedInstance].theme)
    {
        return;
    } // End of theme has not changed

    [[SQLProSettingsManager sharedInstance] setEditorThemeName: editorThemeName];
    [[SQLProSettingsManager sharedInstance] setTheme: theme];
    [[SQLProSettingsManager sharedInstance] updateAndNotify];
   
    [[SQLProAppearanceManager sharedInstance] updateTheme: theme
                                          completionBlock: ^{
        [[SQLProAppearanceManager sharedInstance] redrawAppAndNotify];
    }];
} // End of autoUpdateThemeIfRequired

- (void) displayScreenshotOverlay
{
    UIImageView * screenshotImageView = nil;

    UIWindow * mainWindow = [UIApplication sharedApplication].keyWindow;
    UIView * drawView = mainWindow.rootViewController.view;

    CGFloat height = drawView.frame.size.height;
    CGFloat width  = drawView.frame.size.width;

    UIGraphicsBeginImageContext(CGSizeMake(width,
                                           height));
    
    [drawView drawViewHierarchyInRect: CGRectMake(0, 0,
                                                  width,
                                                  height)
                   afterScreenUpdates: NO];

    UIImage * screenshot = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    screenshotImageView = [[UIImageView alloc] initWithFrame: drawView.frame];
#if todo
    screenshotImageView.layer.borderColor = [UIColor blueColor].CGColor;
    screenshotImageView.layer.borderWidth = 1;
#endif
    [screenshotImageView setImage: screenshot];

    overlayWindow = [[UIWindow alloc] initWithFrame: drawView.frame];
#if todo
    overlayWindow.layer.borderColor = [UIColor redColor].CGColor;
    overlayWindow.layer.borderWidth = 1;
#endif
    overlayWindow.windowLevel = UIWindowLevelAlert + 1;
    [overlayWindow addSubview: screenshotImageView];
    [overlayWindow makeKeyAndVisible];
} // End of displayScreenshotOverlay

- (void) hideScreenshotOverlay
{
    // Remove it
    [overlayWindow setHidden: YES];
    overlayWindow = nil;
} // End of

- (void) redrawAppAndNotify
{
    // Post a notification
    [SQLProAppearanceManager postApperanceUpdatedNotification];

    // Redraw all of our views
    NSArray *windows = [UIApplication sharedApplication].windows;

    for (UIWindow *window in windows)
    {
        if(window == overlayWindow)
        {
            continue;
        }

        for (UIView *view in window.subviews)
        {
            [view removeFromSuperview];
            [window addSubview: view];
        }

        for (UIView *view in window.rootViewController.view.subviews)
        {
            [view removeFromSuperview];
            [window.rootViewController.view addSubview: view];
        }
    } // End of windows enumeration
} // End of redrawApp

- (UIColor*) destructiveColor
{
    return [UIColor colorWithRed: 0.8
                           green: 0.1
                            blue: 0.1
                           alpha: 1];
} // End of destructiveColor

- (UIColor*) darkTableBackgroundColor
{
    // #2B2B2B
    UIColor * darkBackgroundColor =
        [UIColor colorWithRed: 43.0f / 255.0f
                        green: 43.0f / 255.0f
                         blue: 43.0f / 255.0f
                        alpha: 1.0f];
    
    return darkBackgroundColor;
} // End of darkTableBackgroundColor

- (UIColor*) darkTableViewCellBackgroundColor
{
    return [UIColor colorWithRed: 53.0f / 255.0f
                           green: 53.0f / 255.0f
                            blue: 53.0f / 255.0f
                           alpha: 1];
} // End of darkTableViewCellBackgroundColor

- (UIColor*) darkTableViewCellTextColor
{
    return [UIColor whiteColor];
} // End of darkTableViewCellTextColor

- (UIColor*) darkTableViewSeparatorColor
{
    return [UIColor colorWithRed: 57.0f / 255.0f
                           green: 57.0f / 255.0f
                            blue: 57.0f / 255.0f
                           alpha: 1];
} // End of darkTableViewSeparatorColor

- (UIColor*) lightTableBackgroundColor
{
    UIColor * lightBackgroundColor =
        [UIColor colorWithRed: 239.0f / 255.0f
                        green: 239.0f / 255.0f
                         blue: 244.0f / 255.0f
                        alpha: 1.0f];
    
    return lightBackgroundColor;
} // End of lightTableBackgroundColor

- (UIColor*) lightTableViewCellBackgroundColor
{
    return [UIColor whiteColor];
} // End of lightTableViewCellBackgroundColor

- (UIColor*) lightTableViewCellTextColor
{
    return [UIColor blackColor];
} // End of lightTableViewCellTextColor

- (UIColor*) lightTableViewSeparatorColor
{
    return [UIColor colorWithRed: 230.0f / 255.0f
                           green: 230.0f / 255.0f
                            blue: 230.0f / 255.0f
                           alpha: 1];
} // End of lightTableViewSeparatorColor

- (void) updateTheme: (SQLProTheme) theme
     completionBlock: (void (^)(void)) completionBlock
{
    if(SQLProThemeDark == theme)
    {
        [self makeUIDark];
    }
    else if(SQLProThemeLight == theme)
    {
        [self makeUILight];
    }

    if(NULL != completionBlock)
    {
        completionBlock();
    } // End of we have a completionBlock

    UIWindow * window = [[[UIApplication sharedApplication] delegate] window];
    [window.rootViewController setNeedsStatusBarAppearanceUpdate];
} // End of updateTheme:

- (void) makeUILight
{
    [[UITableViewCell appearance] setDarkUI: NO];

    [self updatePasscode: NO];

    [[UISwitch appearance] setOnTintColor: nil];
    [[UISlider appearance] setTintColor: nil];
    [[UISegmentedControl appearance] setTintColor: nil];

    [self updateBackgroundColors: [UIColor groupTableViewBackgroundColor]
             tableSeparatorColor: [self lightTableViewSeparatorColor]
        tableCellBackgroundColor: [UIColor whiteColor]
               keyboardApperance: UIKeyboardAppearanceLight
                    toolbarColor: [UIColor whiteColor]
                toolbarFontColor: [UIColor blackColor]
                toolbarTintColor: nil
                 tabBarTintColor: nil
                     cursorColor: [UIColor lightGrayColor]
                    spinnerColor: [UIColor darkGrayColor]
                          isDark: NO];
} // End of makeUILight

- (void) makeUIDark
{
    UIColor * darkBackgroundColor = [self darkTableBackgroundColor];

    UIColor * toolbarColor =
        [UIColor colorWithRed: 33.0f / 255.0f
                        green: 33.0f / 255.0f
                         blue: 33.0f / 255.0f
                        alpha: 1.0f];

    UIColor * toolbarTintColor =
        [UIColor colorWithRed: 165.0f / 255.0f
                        green: 165.0f / 255.0f
                         blue: 165.0f / 255.0f
                        alpha: 1.0f];

    [[UITableViewCell appearance] setDarkUI: YES];

    [self updatePasscode: YES];

    // hex #43b4fa
    UIColor * tintColor =
        [UIColor colorWithRed: 67.0f  / 255.0f
                        green: 180.0f / 255.0f
                         blue: 250.0f / 255.0f
                        alpha: 1.0f];

    [[UISwitch appearance] setOnTintColor: tintColor];
    [[UISlider appearance] setTintColor: tintColor];

    [[UISegmentedControl appearance] setTintColor:
        [UIColor colorWithRed: 165.0f / 255.0f
                        green: 165.0f / 255.0f
                         blue: 165.0f / 255.0f
                        alpha: 1.0f]];

    [self updateBackgroundColors: darkBackgroundColor
             tableSeparatorColor: [self darkTableViewSeparatorColor]
        tableCellBackgroundColor: [self darkTableViewCellBackgroundColor]
               keyboardApperance: UIKeyboardAppearanceDark
                    toolbarColor: toolbarColor
                toolbarFontColor: [UIColor whiteColor]
                toolbarTintColor: toolbarTintColor
                 tabBarTintColor: [UIColor whiteColor]
                     cursorColor: tintColor
                    spinnerColor: [UIColor darkGrayColor]
                          isDark: YES];
} // End of makeUIDark

- (void) updateBackgroundColors: (UIColor*) backgroundColor
            tableSeparatorColor: (UIColor*) tableSeparatorColor
       tableCellBackgroundColor: (UIColor*) tableCellBackgroundColor
              keyboardApperance: (UIKeyboardAppearance) keyboardApperance
                   toolbarColor: (UIColor*) toolbarColor
               toolbarFontColor: (UIColor*) toolbarFontColor
               toolbarTintColor: (UIColor*) toolbarTintColor
                tabBarTintColor: (UIColor*) tabBarTintColor
                    cursorColor: (UIColor*) cursorColor
                   spinnerColor: (UIColor*) spinnerColor
                         isDark: (BOOL) isDark
{
    [UINavigationBar appearance].barStyle = UIBarStyleDefault;
    [UINavigationBar appearance].translucent = NO;

    [UITabBar appearance].barStyle = UIBarStyleDefault;
    [UITabBar appearance].translucent = NO;

    if(isDark)
    {
        [[UINavigationBar appearance] setBackgroundImage: [UIImage new]
                                           forBarMetrics: UIBarMetricsDefault];
        
        UIColor * borderColor = [@"#3d3d3d" hexToColor];
        UIImage * borderImage = [borderColor solidImageWithWidth: 1
                                                          height: 1];

        [[UINavigationBar appearance] setShadowImage: borderImage];

        [[UITabBar appearance] setBackgroundImage: [UIImage new]];
        [[UITabBar appearance] setShadowImage: borderImage];
    }
    else
    {
        [UINavigationBar appearance].shadowImage = nil;
        [[UINavigationBar appearance] setBackgroundImage: nil
                                           forBarMetrics: UIBarMetricsDefault];

        [UITabBar appearance].shadowImage = nil;
        [[UITabBar appearance] setBackgroundImage: nil];
    }

    [UITextField appearance].keyboardAppearance = keyboardApperance;
//    [UITextView appearance].keyboardAppearance  = keyboardApperance;

    UIFont * toolbarFont = [UIFont boldSystemFontOfSize: 17];
    NSMutableDictionary * titleTextAttributes = @{
        NSForegroundColorAttributeName: toolbarFontColor,
        NSFontAttributeName: toolbarFont
    }.mutableCopy;

    if(isDark)
    {
        NSShadow *shadow = [[NSShadow alloc] init];
        shadow.shadowColor = [UIColor colorWithWhite:.0f alpha:1.f];
        shadow.shadowOffset = CGSizeMake(0, -1);

        titleTextAttributes[NSShadowAttributeName] = shadow;
    } // End of light

    [[UINavigationBar appearance] setTitleTextAttributes: titleTextAttributes];
    [[UINavigationBar appearance] setBarTintColor: toolbarColor];
    [[UINavigationBar appearance] setTintColor: toolbarTintColor];

    [[UIToolbar appearance] setBarTintColor: toolbarColor];
    [[UIToolbar appearance] setTintColor: toolbarTintColor];

    [[UITabBar appearance] setTintColor: tabBarTintColor];
    [[UITabBar appearance] setBarTintColor: toolbarColor];

    [[SQLProTableView appearance] setBackgroundColor: backgroundColor];
    [[UITableView appearance] setSeparatorColor: tableSeparatorColor];
    [[UITableViewCell appearance] setBackgroundColor: tableCellBackgroundColor];
    [[SQLProCollectionView appearance] setBackgroundColor: backgroundColor];
    [[UITableView appearance] setBackgroundColor: backgroundColor];
//    [[UIScrollView appearance] setBackgroundColor: backgroundColor];

    [[UIRefreshControl appearance] setBackgroundColor: backgroundColor];

    [[UITextField appearance] setTintColor: cursorColor];
    [[DRPLoadingSpinner appearance] setColorSequence: @[ spinnerColor ]];

    if(isDark)
    {
        [[XLTextField appearance] setTextColorEnabled: [UIColor lightGrayColor]];
        [[XLTextField appearance] setTextColorDisabled: [UIColor lightGrayColor]];
        [[XLLabel appearance] setTextColorEnabled: [UIColor whiteColor]];
        [[XLLabel appearance] setTextColorDisabled: [UIColor whiteColor]];
        [[XLFormTextFieldCell appearance] setTintColor: [UIColor whiteColor]];

        [[UILabel appearance] setTintColor: [UIColor whiteColor]];
        UIView *selectionColor = [[UIView alloc] init];
        selectionColor.backgroundColor = [UIColor darkGrayColor];

        [[UITableViewCell appearance] setSelectedBackgroundView: selectionColor];
        [[UIScrollView appearance] setIndicatorStyle: UIScrollViewIndicatorStyleWhite];
    }
    else
    {
        [[XLTextField appearance] setTextColorEnabled: [UIColor blackColor]];
        [[XLTextField appearance] setTextColorDisabled: [UIColor blackColor]];
        [[XLLabel appearance] setTextColorEnabled: [UIColor blackColor]];
        [[XLLabel appearance] setTextColorDisabled: [UIColor blackColor]];
        [[XLFormTextFieldCell appearance] setTintColor: [UIColor blackColor]];

        [[UILabel appearance] setTintColor: [UIColor blackColor]];
        [[UITableViewCell appearance] setSelectedBackgroundView: nil];
        [[UIScrollView appearance] setIndicatorStyle: UIScrollViewIndicatorStyleBlack];
    }
}

- (void) updatePasscode: (BOOL) isDark
{
    UIColor * backgroundColor = nil;
    UIColor * buttonColor = nil;
    UIColor * titleColor  = nil;

    buttonColor =
        [UIColor colorWithRed: 165.0f / 255.0f
                        green: 165.0f / 255.0f
                         blue: 165.0f / 255.0f
                        alpha: 1.0f];

    UIColor * buttonTitleColor = nil;

    if(isDark)
    {
        backgroundColor  = [self darkTableBackgroundColor];
        titleColor       = [UIColor whiteColor];
        buttonTitleColor = [UIColor whiteColor];

        [HSDividerView appearance].dividerColor =
            [UIColor colorWithRed: 108.0 / 255.0
                            green: 108.0 / 255.0
                             blue: 108.0 / 255.0
                            alpha: 1];
    } // End of isDark
    else
    {
        backgroundColor  = [UIColor whiteColor];
        titleColor       = [UIColor blackColor];
        buttonTitleColor = [UIColor blackColor];

        [HSDividerView appearance].dividerColor =
            [UIColor colorWithRed: 225.0 / 255.0
                            green: 225.0 / 255.0
                             blue: 225.0 / 255.0
                            alpha: 1];
    } // End of !dark
    
    (void) backgroundColor;
    (void) titleColor;
    (void) buttonTitleColor;

#if todo
    // Passcode screen
    [[PasscodeBackgroundView appearance] setBackgroundColor: backgroundColor];
    [[PasscodeSignPlaceholderView appearance] setBackgroundColor: backgroundColor];
    [[PasscodeSignPlaceholderContainerView appearance] setBackgroundColor: backgroundColor];
    
    [[PasscodeTitleLabel appearance] setTextColor: titleColor];

    [[PasscodeSignButton appearance] setBorderColor: buttonColor];
    
    [[PasscodeSignButton appearance] setHighlightBackgroundColor: buttonColor];

    [[PasscodeSignButton appearance] setTitleColor: buttonTitleColor
                                          forState: UIControlStateNormal];
    
    [[PasscodeSignButton appearance] setTitleColor: buttonTitleColor
                                          forState: UIControlStateHighlighted];
    
    [[PasscodeSignButton appearance] setTitleColor: buttonTitleColor
                                          forState: UIControlStateDisabled];
    
    [[PasscodeButton appearance] setTitleColor: buttonTitleColor
                                      forState: UIControlStateNormal];
    
    [[PasscodeButton appearance] setTitleColor: [UIColor darkGrayColor]
                                      forState: UIControlStateDisabled];
    
    [[PasscodeSignPlaceholderView appearance] setErrorColor: backgroundColor];
    [[PasscodeSignPlaceholderView appearance] setActiveColor: buttonColor];
    [[PasscodeSignPlaceholderView appearance] setInactiveColor: backgroundColor];
#endif
} // End of updatePasscodeDark

@end
