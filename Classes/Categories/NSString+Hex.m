//
//  NSString+Hex.m
//  HSCore
//
//  Created by Kyle Hankinson on 2016-12-09.
//  Copyright © 2016 Hankinsoft Development, Inc. All rights reserved.
//

#import "NSString+Hex.h"

@implementation NSString (Hex)

- (UIColor*) hexToColor
{
    return [self hexToColorWithAlpha: 1.0];
}

- (UIColor*) hexToColorWithAlpha: (float) alpha
{
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString: self];

    if('#' == [self characterAtIndex: 0])
    {
        [scanner setScanLocation: 1]; // bypass '#' character
    } // End of we need to bypass the # character

    [scanner scanHexInt: &rgbValue];

#if TARGET_OS_IPHONE
    return [UIColor colorWithRed: ((rgbValue & 0xFF0000) >> 16)/255.0
                           green: ((rgbValue & 0xFF00) >> 8)/255.0
                            blue: (rgbValue & 0xFF)/255.0
                           alpha: alpha];
#else
    return [NSColor colorWithCalibratedRed: ((rgbValue & 0xFF0000) >> 16)/255.0
                                     green: ((rgbValue & 0xFF00) >> 8)/255.0
                                      blue: (rgbValue & 0xFF)/255.0
                                     alpha: alpha];
#endif
}

@end
