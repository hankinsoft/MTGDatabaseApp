//
//  MTGCardImageTableViewCell.m
//  MTG Deck Builder
//
//  Created by kylehankinson on 2018-04-09.
//  Copyright © 2018 Hankinsoft Development, Inc. All rights reserved.
//

#import "MTGCardImageTableViewCell.h"

@implementation MTGCardImageTableViewCell

- (id) initWithStyle: (UITableViewCellStyle) style
     reuseIdentifier: (NSString *) reuseIdentifier
{
    self = [super initWithStyle: style
                reuseIdentifier: reuseIdentifier];

    if(self)
    {
        _cardImageView = [[UIImageView alloc] init];
        _cardImageView.contentMode = UIViewContentModeScaleAspectFit;
        _cardImageView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview: _cardImageView];
        [_cardImageView.centerYAnchor constraintEqualToAnchor: self.centerYAnchor].active = YES;
        [_cardImageView.centerXAnchor constraintEqualToAnchor: self.centerXAnchor].active = YES;
        [_cardImageView.heightAnchor constraintEqualToAnchor: self.heightAnchor
                                                    constant: -10.0f].active = YES;
        [_cardImageView.widthAnchor constraintEqualToAnchor: _cardImageView.heightAnchor
                                                 multiplier: 0.75f].active = YES;
    }

    return self;
}

@end
