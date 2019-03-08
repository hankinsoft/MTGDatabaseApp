//
//  UIPositionedTextLabelViewCell.m
//  MTG Deck Builder
//
//  Created by Kyle Hankinson on 11-06-23.
//  Copyright 2011 Hankinsoft. All rights reserved.
//

#import "UIPositionedTextLabelViewCell.h"

@implementation UIPositionedTextLabelViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void) setSelected: (BOOL)selected
            animated:(BOOL)animated
{
    [super setSelected: selected
              animated: animated];
}

#pragma mark -
#pragma mark Laying out subviews

- (void) layoutSubviews
{
	// Super layout
	[super layoutSubviews];
    
    if(!self.detailTextLabel.superview)
    {
        [self.contentView addSubview: self.detailTextLabel];
        
    }
    
    UIView * contentView = self.contentView;

    CGFloat offset = -self.layoutMargins.right;
    self.detailTextLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.detailTextLabel.rightAnchor constraintEqualToAnchor: contentView.rightAnchor
                                                     constant: offset].active = YES;
    [self.detailTextLabel.leftAnchor constraintEqualToAnchor: self.textLabel.rightAnchor
                                                    constant: offset].active = YES;
    [self.detailTextLabel.centerYAnchor constraintEqualToAnchor: self.textLabel.centerYAnchor].active = YES;
    [self.detailTextLabel.heightAnchor constraintEqualToAnchor: self.textLabel.heightAnchor].active = YES;
} // End of layoutSubviews

@end
