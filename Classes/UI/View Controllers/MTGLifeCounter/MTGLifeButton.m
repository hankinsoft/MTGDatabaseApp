//
//  MTGLifeButton.m
//  MTG Deck Builder
//
//  Created by kylehankinson on 2018-08-14.
//  Copyright © 2018 Hankinsoft Development, Inc. All rights reserved.
//

#import "MTGLifeButton.h"

@implementation MTGLifeButton

- (void) drawRect: (CGRect) rect
{
    return;

    // Rob mentioned the borders made the buttons look hard to hit, so they have been removed. Code just kept
    // around for references.
#if DRAW_BORDERS
    //// General Declarations
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //// Color Declarations
    UIColor* color3 = [UIColor colorWithRed: 0.129 green: 0.129 blue: 0.129 alpha: 1];
    UIColor* addLife = [UIColor colorWithRed: 0.215 green: 1 blue: 0.039 alpha: 1];
    
    //// Rectangle Drawing
    UIBezierPath* rectanglePath = [UIBezierPath bezierPathWithRoundedRect: CGRectMake(3, 9, 39, 39) cornerRadius: 4];
    [color3 setFill];
    [rectanglePath fill];
    [UIColor.grayColor setStroke];
    rectanglePath.lineWidth = 1;
    [rectanglePath stroke];
#endif
}

@end
