//
//  UIColor+Hex.m
//  Coder
//
//  Created by Kyle Hankinson on 2014-05-05.
//  Copyright (c) 2014 com.hankinsoft.osx. All rights reserved.
//

#import "UIColor+Hex.h"

@implementation UIColor (Hex)

- (NSString *) hexadecimalValue
{
    CGFloat red = 0.0, green = 0.0, blue = 0.0, alpha =0.0;
    [self getRed: &red
           green: &green
            blue: &blue
           alpha: &alpha];

    return [NSString stringWithFormat:@"#%02lX%02lX%02lX",
            lroundf(red * 255),
            lroundf(green * 255),
            lroundf(blue * 255)];
}

- (UIImage *) solidImageWithWidth: (CGFloat) width
                           height: (CGFloat) height
{
    CGRect rect = CGRectMake(0.0f, 0.0f, width, height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();

    CGContextSetFillColorWithColor(context, [self CGColor]);
    CGContextFillRect(context, rect);

    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

- (UIColor *) inverseColor
{
    // Note: inverseColor is based on the code found here:
    // https://stackoverflow.com/a/5901586/127853

    CGFloat alpha;

    CGFloat white;
    if ([self getWhite:&white alpha:&alpha]) {
        return [UIColor colorWithWhite:1.0 - white alpha:alpha];
    }
    
    CGFloat hue, saturation, brightness;
    if ([self getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha]) {
        return [UIColor colorWithHue:1.0 - hue saturation:1.0 - saturation brightness:1.0 - brightness alpha:alpha];
    }
    
    CGFloat red, green, blue;
    if ([self getRed:&red green:&green blue:&blue alpha:&alpha]) {
        return [UIColor colorWithRed:1.0 - red green:1.0 - green blue:1.0 - blue alpha:alpha];
    }
    
    return nil;
}

@end
