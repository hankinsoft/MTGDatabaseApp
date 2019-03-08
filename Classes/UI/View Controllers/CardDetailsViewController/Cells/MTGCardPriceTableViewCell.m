//
//  MTGCardPriceTableViewCell.m
//  MTG Deck Builder
//
//  Created by kylehankinson on 2018-04-13.
//  Copyright © 2018 Hankinsoft Development, Inc. All rights reserved.
//

#import "MTGCardPriceTableViewCell.h"

@implementation MTGCardPriceTableViewCell

- (id) initWithStyle: (UITableViewCellStyle) style
     reuseIdentifier: (NSString *) reuseIdentifier
{
    self = [super initWithStyle: style
                reuseIdentifier: reuseIdentifier];
    if(self)
    {
        _priceTextLabel = [[UILabel alloc] init];
        _priceTextLabel.textAlignment = NSTextAlignmentRight;
        [self addSubview: _priceTextLabel];
    }

    return self;
} // End of initWithSty

- (void) layoutSubviews
{
    [super layoutSubviews];

    _priceTextLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [_priceTextLabel.centerYAnchor constraintEqualToAnchor: self.centerYAnchor].active = YES;
    [_priceTextLabel.rightAnchor constraintEqualToAnchor: self.rightAnchor
                                                constant: -40.0f].active = YES;
    [_priceTextLabel.widthAnchor constraintEqualToConstant: 120.0f].active = YES;
} // End of layoutSubviews

@end
