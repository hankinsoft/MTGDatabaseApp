//
//  HSDividerView.m
//  SQLPro (iOS)
//
//  Created by Kyle Hankinson on 2017-06-02.
//  Copyright © 2017 Hankinsoft Development, Inc. All rights reserved.
//

#import "HSDividerView.h"

@implementation HSDividerView

+ (void) initialize
{
    static dispatch_once_t onceToken = 0;
    dispatch_once(&onceToken, ^{
        [HSDividerView appearance].dividerColor =
            [UIColor colorWithRed: 108.0 / 255.0
                            green: 108.0 / 255.0
                             blue: 108.0 / 255.0
                            alpha: 1];
    });
} // End of initialize

- (id) init
{
    self = [super init];
    if(self)
    {
        [self customInit];
    }
    
    return self;
}

- (id) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame: frame];
    if(self)
    {
        [self customInit];
    }
    
    return self;
} // End of initWithFrame:

- (id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder: aDecoder];
    if(self)
    {
        [self customInit];
    }
    
    return self;
}

- (void) customInit
{
    self.dividerColor = [HSDividerView appearance].dividerColor;
}

- (void) dealloc
{
} // End of dealloc

- (void) themeChanged
{
    self.dividerColor = [HSDividerView appearance].dividerColor;
    [self setNeedsDisplay];
} // End of themeChanged

- (void) drawRect: (CGRect) rect
{
    [super drawRect: rect];

    CGRect dividerRect = CGRectZero;
    
    if(HSDividerViewDividerPositionNone == self.dividerPosition)
    {
        // None is do nothing
        return;
    }
    else if(HSDividerViewDividerPositionBottom == self.dividerPosition)
    {
        dividerRect =
            CGRectMake(0, self.frame.size.height - 1, self.frame.size.width, 1);
    }
    else if(HSDividerViewDividerPositionLeft == self.dividerPosition)
    {
        dividerRect =
            CGRectMake(0, 0, 1, self.frame.size.height);
    }
    else if(HSDividerViewDividerPositionRight == self.dividerPosition)
    {
        dividerRect =
            CGRectMake(self.frame.size.width - 1, 0, 1, self.frame.size.height);
    }
    // Top is default
    else
    {
        dividerRect =
            CGRectMake(0, 0, self.frame.size.width, 1);
    }

    UIColor * dividerColor = self.dividerColor;
    [dividerColor setFill];
    UIRectFill(dividerRect);
}

@end
