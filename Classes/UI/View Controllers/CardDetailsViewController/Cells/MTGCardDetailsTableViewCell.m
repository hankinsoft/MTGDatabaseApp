//
//  MTGCardDetailsTableViewCell.m
//  MTG Deck Builder
//
//  Created by kylehankinson on 2018-04-10.
//  Copyright © 2018 Hankinsoft Development, Inc. All rights reserved.
//

#import "MTGCardDetailsTableViewCell.h"

@implementation MTGCardDetailsTableViewCell

- (id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle: style
                reuseIdentifier: reuseIdentifier];
    if(self)
    {
    }
    
    return self;
} // End of init:

- (void) layoutSubviews
{
    self.detailTextLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.detailTextLabel.rightAnchor constraintEqualToAnchor: self.rightAnchor].active = YES;
    [self.detailTextLabel.widthAnchor constraintEqualToAnchor: self.widthAnchor
                                                   multiplier: 0.60f].active = YES;
    [self.detailTextLabel.centerYAnchor constraintEqualToAnchor: self.centerYAnchor].active = YES;

    self.textLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.textLabel.rightAnchor constraintEqualToAnchor: self.detailTextLabel.leftAnchor
                                               constant: -5.0f].active = YES;
    [self.textLabel.centerYAnchor constraintEqualToAnchor: self.centerYAnchor].active = YES;
} // End of layoutSubviews

@end
