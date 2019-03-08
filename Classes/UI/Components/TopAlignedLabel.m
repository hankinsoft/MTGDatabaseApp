//
//  TopAlignedLabel.m
//  MTG Deck Builder
//
//  Created by Kyle Hankinson on 2018-03-15.
//  Copyright © 2018 Hankinsoft Development, Inc. All rights reserved.
//

#import "TopAlignedLabel.h"

@implementation TopAlignedLabel

- (void)drawTextInRect: (CGRect)rect
{
    if (self.text)
    {
        CGSize labelStringSize = [self.text boundingRectWithSize:CGSizeMake(CGRectGetWidth(self.frame), CGFLOAT_MAX)
                                                         options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                                      attributes:@{NSFontAttributeName:self.font}
                                                         context:nil].size;
        [super drawTextInRect:CGRectMake(0, 0, ceilf(CGRectGetWidth(self.frame)),ceilf(labelStringSize.height))];
    }
    else
    {
        [super drawTextInRect:rect];
    }
}

- (void) prepareForInterfaceBuilder
{
    [super prepareForInterfaceBuilder];
    self.layer.borderWidth = 1;
    self.layer.borderColor = [UIColor blackColor].CGColor;
}

@end
