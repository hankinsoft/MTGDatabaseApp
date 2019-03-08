//
//  MTGEDHButton.m
//  MTG Deck Builder
//
//  Created by kylehankinson on 2018-08-16.
//  Copyright © 2018 Hankinsoft Development, Inc. All rights reserved.
//

#import "MTGEDHButton.h"

@implementation MTGEDHButton

- (void) drawRect: (CGRect) rect
{
    //// General Declarations
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //// Color Declarations
    UIColor* fillColor = [UIColor colorWithRed: 0 green: 0 blue: 0 alpha: 1];
    
    //// Bezier 2 Drawing
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, 1, 0.9);
    CGContextScaleCTM(context, 1.05, 1.05);
    
    UIBezierPath* bezier2Path = [UIBezierPath bezierPath];
    [bezier2Path moveToPoint: CGPointMake(41.44, 8.23)];
    [bezier2Path addCurveToPoint: CGPointMake(21.46, 45.96) controlPoint1: CGPointMake(41.46, 8.32) controlPoint2: CGPointMake(47.21, 39.79)];
    [bezier2Path addCurveToPoint: CGPointMake(21.03, 45.98) controlPoint1: CGPointMake(21.33, 46) controlPoint2: CGPointMake(21.18, 46.01)];
    [bezier2Path addLineToPoint: CGPointMake(21.03, 45.98)];
    [bezier2Path addCurveToPoint: CGPointMake(0.43, 8.27) controlPoint1: CGPointMake(-4.35, 39.95) controlPoint2: CGPointMake(0.26, 9.38)];
    [bezier2Path addCurveToPoint: CGPointMake(0.46, 8.14) controlPoint1: CGPointMake(0.44, 8.23) controlPoint2: CGPointMake(0.45, 8.18)];
    [bezier2Path addCurveToPoint: CGPointMake(1.39, 7.65) controlPoint1: CGPointMake(0.58, 7.76) controlPoint2: CGPointMake(1, 7.54)];
    [bezier2Path addLineToPoint: CGPointMake(1.39, 7.65)];
    [bezier2Path addCurveToPoint: CGPointMake(20.34, 0.29) controlPoint1: CGPointMake(10.9, 10.34) controlPoint2: CGPointMake(19.71, 0.98)];
    [bezier2Path addCurveToPoint: CGPointMake(20.45, 0.18) controlPoint1: CGPointMake(20.37, 0.25) controlPoint2: CGPointMake(20.41, 0.21)];
    [bezier2Path addCurveToPoint: CGPointMake(21.51, 0.25) controlPoint1: CGPointMake(20.76, -0.08) controlPoint2: CGPointMake(21.24, -0.05)];
    [bezier2Path addLineToPoint: CGPointMake(21.51, 0.25)];
    [bezier2Path addCurveToPoint: CGPointMake(40.45, 7.66) controlPoint1: CGPointMake(21.53, 0.28) controlPoint2: CGPointMake(30.61, 10.41)];
    [bezier2Path addCurveToPoint: CGPointMake(40.58, 7.63) controlPoint1: CGPointMake(40.49, 7.65) controlPoint2: CGPointMake(40.53, 7.64)];
    [bezier2Path addCurveToPoint: CGPointMake(41.44, 8.22) controlPoint1: CGPointMake(40.99, 7.57) controlPoint2: CGPointMake(41.37, 7.83)];
    [bezier2Path addLineToPoint: CGPointMake(41.44, 8.23)];
    [bezier2Path closePath];
    [bezier2Path moveToPoint: CGPointMake(38.78, 10.96)];
    [bezier2Path addCurveToPoint: CGPointMake(25.73, 7.53) controlPoint1: CGPointMake(34.18, 11.53) controlPoint2: CGPointMake(29.62, 9.98)];
    [bezier2Path addCurveToPoint: CGPointMake(20.95, 3.86) controlPoint1: CGPointMake(24.14, 6.52) controlPoint2: CGPointMake(22.43, 5.23)];
    [bezier2Path addCurveToPoint: CGPointMake(15.8, 7.68) controlPoint1: CGPointMake(19.35, 5.31) controlPoint2: CGPointMake(17.4, 6.72)];
    [bezier2Path addCurveToPoint: CGPointMake(3.17, 10.92) controlPoint1: CGPointMake(12, 9.97) controlPoint2: CGPointMake(7.61, 11.38)];
    [bezier2Path addCurveToPoint: CGPointMake(4.09, 24.65) controlPoint1: CGPointMake(2.8, 15.48) controlPoint2: CGPointMake(3.07, 20.26)];
    [bezier2Path addCurveToPoint: CGPointMake(21.16, 43.04) controlPoint1: CGPointMake(6.23, 33.81) controlPoint2: CGPointMake(11.51, 40.53)];
    [bezier2Path addCurveToPoint: CGPointMake(38.04, 23.82) controlPoint1: CGPointMake(30.79, 40.08) controlPoint2: CGPointMake(36.05, 33.14)];
    [bezier2Path addCurveToPoint: CGPointMake(38.78, 10.96) controlPoint1: CGPointMake(38.86, 20.01) controlPoint2: CGPointMake(39.18, 15.15)];
    [bezier2Path closePath];
    bezier2Path.usesEvenOddFillRule = YES;
    [UIColor.whiteColor setFill];
    [bezier2Path fill];
    
    CGContextRestoreGState(context);
    
    
    //// Bezier Drawing
    UIBezierPath* bezierPath = [UIBezierPath bezierPath];
    [bezierPath moveToPoint: CGPointMake(42.47, 11.17)];
    [bezierPath addCurveToPoint: CGPointMake(23.44, 47.26) controlPoint1: CGPointMake(42.48, 11.26) controlPoint2: CGPointMake(47.96, 41.36)];
    [bezierPath addCurveToPoint: CGPointMake(23.03, 47.28) controlPoint1: CGPointMake(23.31, 47.3) controlPoint2: CGPointMake(23.17, 47.31)];
    [bezierPath addLineToPoint: CGPointMake(23.03, 47.28)];
    [bezierPath addCurveToPoint: CGPointMake(3.41, 11.21) controlPoint1: CGPointMake(-1.14, 41.51) controlPoint2: CGPointMake(3.25, 12.27)];
    [bezierPath addCurveToPoint: CGPointMake(3.44, 11.08) controlPoint1: CGPointMake(3.42, 11.17) controlPoint2: CGPointMake(3.43, 11.13)];
    [bezierPath addCurveToPoint: CGPointMake(4.33, 10.62) controlPoint1: CGPointMake(3.55, 10.72) controlPoint2: CGPointMake(3.95, 10.51)];
    [bezierPath addLineToPoint: CGPointMake(4.33, 10.62)];
    [bezierPath addCurveToPoint: CGPointMake(22.37, 3.58) controlPoint1: CGPointMake(13.38, 13.19) controlPoint2: CGPointMake(21.77, 4.24)];
    [bezierPath addCurveToPoint: CGPointMake(22.47, 3.47) controlPoint1: CGPointMake(22.4, 3.54) controlPoint2: CGPointMake(22.44, 3.5)];
    [bezierPath addCurveToPoint: CGPointMake(23.48, 3.54) controlPoint1: CGPointMake(22.77, 3.22) controlPoint2: CGPointMake(23.22, 3.25)];
    [bezierPath addLineToPoint: CGPointMake(23.48, 3.54)];
    [bezierPath addCurveToPoint: CGPointMake(41.52, 10.63) controlPoint1: CGPointMake(23.51, 3.57) controlPoint2: CGPointMake(32.15, 13.26)];
    [bezierPath addCurveToPoint: CGPointMake(41.65, 10.6) controlPoint1: CGPointMake(41.56, 10.62) controlPoint2: CGPointMake(41.6, 10.61)];
    [bezierPath addCurveToPoint: CGPointMake(42.47, 11.17) controlPoint1: CGPointMake(42.04, 10.54) controlPoint2: CGPointMake(42.4, 10.79)];
    [bezierPath addLineToPoint: CGPointMake(42.47, 11.17)];
    [bezierPath closePath];
    [bezierPath moveToPoint: CGPointMake(39.93, 13.78)];
    [bezierPath addCurveToPoint: CGPointMake(27.51, 10.5) controlPoint1: CGPointMake(35.55, 14.33) controlPoint2: CGPointMake(31.21, 12.85)];
    [bezierPath addCurveToPoint: CGPointMake(22.95, 6.99) controlPoint1: CGPointMake(25.99, 9.54) controlPoint2: CGPointMake(24.36, 8.31)];
    [bezierPath addCurveToPoint: CGPointMake(18.05, 10.65) controlPoint1: CGPointMake(21.42, 8.38) controlPoint2: CGPointMake(19.57, 9.73)];
    [bezierPath addCurveToPoint: CGPointMake(6.02, 13.74) controlPoint1: CGPointMake(14.43, 12.83) controlPoint2: CGPointMake(10.24, 14.19)];
    [bezierPath addCurveToPoint: CGPointMake(6.9, 26.88) controlPoint1: CGPointMake(5.66, 18.1) controlPoint2: CGPointMake(5.92, 22.68)];
    [bezierPath addCurveToPoint: CGPointMake(23.15, 44.47) controlPoint1: CGPointMake(8.94, 35.64) controlPoint2: CGPointMake(13.96, 42.07)];
    [bezierPath addCurveToPoint: CGPointMake(39.23, 26.09) controlPoint1: CGPointMake(32.32, 41.64) controlPoint2: CGPointMake(37.33, 35)];
    [bezierPath addCurveToPoint: CGPointMake(39.93, 13.78) controlPoint1: CGPointMake(40.01, 22.44) controlPoint2: CGPointMake(40.31, 17.79)];
    [bezierPath closePath];
    bezierPath.usesEvenOddFillRule = YES;
    [fillColor setFill];
    [bezierPath fill];
}

@end
