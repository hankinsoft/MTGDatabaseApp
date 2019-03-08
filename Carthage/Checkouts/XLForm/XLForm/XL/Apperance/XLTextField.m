//
//  XLTextField.m
//  XLForm
//
//  Created by Kyle Hankinson on 2016-11-28.
//  Copyright © 2016 XLForm. All rights reserved.
//

#import "XLTextField.h"

@implementation XLTextField

+ (void) load
{
    [[XLTextField appearance] setTextColorEnabled: [UIColor blackColor]];
    [[XLTextField appearance] setTextColorDisabled: [UIColor grayColor]];
} // End of load

- (void) setBackgroundColor:(UIColor *)backgroundColor
{
    [super setBackgroundColor: backgroundColor];
}

- (void) setBackground:(UIImage *)background
{
    [super setBackground: background];
}

- (UIColor*) textColorEnabled
{
    return [[XLTextField appearance] textColorEnabled];
} // End of textColorEnabled

- (UIColor*) textColorDisabled
{
    return [[XLTextField appearance] textColorDisabled];
} // End of textColorDisabled

- (void) setTextColor: (UIColor *) textColor
{
    [super setTextColor: textColor];
} // End of setTextColor:

@end
