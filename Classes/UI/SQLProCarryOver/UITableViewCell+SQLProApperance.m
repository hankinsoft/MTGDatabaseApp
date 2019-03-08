//
//  UITableViewCell+SQLProApperance.m
//  SQLPro (iOS)
//
//  Created by Kyle Hankinson on 2016-11-25.
//  Copyright © 2016 Hankinsoft Development, Inc. All rights reserved.
//

#import "UITableViewCell+SQLProApperance.h"
#import "SQLProAppearanceManager.h"
#import <objc/runtime.h>

static char kUITableViewCellIsDark;

static char kUITableViewCellLightTextColor;
static char kUITableViewCellDarkTextColor;

@implementation UITableViewCell (SQLProApperance)

- (void) setLightTextColor: (UIColor *) lightTextColor
{
    objc_setAssociatedObject(self,
                             &kUITableViewCellLightTextColor,
                             lightTextColor,
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
} // End of setKeyboardSelection

- (UIColor*) lightTextColor
{
    id result = objc_getAssociatedObject(self, &kUITableViewCellLightTextColor);
    return result;
} // End of keyboardSelection

- (void) setDarkTextColor: (UIColor *) darkTextColor
{
    objc_setAssociatedObject(self,
                             &kUITableViewCellDarkTextColor,
                             darkTextColor,
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
} // End of setKeyboardSelection

- (UIColor*) darkTextColor
{
    id result = objc_getAssociatedObject(self, &kUITableViewCellDarkTextColor);
    return result;
} // End of keyboardSelection

- (BOOL) darkUI
{
    id result = objc_getAssociatedObject(self, &kUITableViewCellIsDark);
    if(nil == result || ![result isKindOfClass: [NSNumber class]])
    {
        return NO;
    }

    return [result boolValue];
} // End of darkUI is set

- (void) setDarkUI: (BOOL) darkUI
{
    objc_setAssociatedObject(self,
                             &kUITableViewCellIsDark,
                             @(darkUI),
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);

    if(darkUI)
    {
        self.backgroundColor =
            [[SQLProAppearanceManager sharedInstance] darkTableViewCellBackgroundColor];

        if(nil == self.darkTextColor)
        {
            self.textLabel.textColor =
                [[SQLProAppearanceManager sharedInstance] darkTableViewCellTextColor];
        }
        else
        {
            self.textLabel.textColor = self.darkTextColor;
        }
    }
    else
    {
        self.backgroundColor =
            [[SQLProAppearanceManager sharedInstance] lightTableViewCellBackgroundColor];

        if(nil == self.lightTextColor)
        {
            self.textLabel.textColor =
                [[SQLProAppearanceManager sharedInstance] lightTableViewCellTextColor];
        }
        else
        {
            self.textLabel.textColor = self.lightTextColor;
        }
    }
} // End of setBackgroundColor

@end
