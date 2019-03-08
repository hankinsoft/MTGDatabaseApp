//
//  DeckCardModifierCell.m
//  MTG Deck Builder
//
//  Created by Kyle Hankinson on 12-05-26.
//  Copyright (c) 2012 Hankinsoft. All rights reserved.
//

#import "DeckCardModifierCell.h"

@implementation DeckCardModifierCell
{
    NSLayoutConstraint  * rightLayoutConstraint;
}

@synthesize multiverseId, delegate;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        CGFloat offset = self.layoutMargins.right;

        UIButton * addButton = [UIButton buttonWithType: UIButtonTypeCustom];
        addButton.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:addButton];
        [addButton addTarget:self action:@selector(onAddButton:) forControlEvents:UIControlEventTouchUpInside];
        [addButton setImage: [UIImage imageNamed:@"Add.png"] forState:UIControlStateNormal];
        
        [addButton.heightAnchor constraintEqualToConstant: 22.0f].active = YES;
        [addButton.widthAnchor constraintEqualToConstant: 22.0f].active = YES;

        if (@available(iOS 11.0, *))
        {
            rightLayoutConstraint = [addButton.rightAnchor constraintEqualToAnchor: self.safeAreaLayoutGuide.rightAnchor
                                                                          constant: -offset];
        }
        else
        {
            rightLayoutConstraint = [addButton.rightAnchor constraintEqualToAnchor: self.rightAnchor
                                                                          constant: -offset];
        }

        rightLayoutConstraint.active = YES;
        [addButton.centerYAnchor constraintEqualToAnchor: self.centerYAnchor].active = YES;

        UIButton * removeButton = [UIButton buttonWithType: UIButtonTypeCustom];
        [removeButton addTarget:self action:@selector(onRemoveButton:) forControlEvents:UIControlEventTouchUpInside];
        [removeButton setImage: [UIImage imageNamed:@"Remove.png"] forState:UIControlStateNormal];

        removeButton.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview: removeButton];

        [removeButton.heightAnchor constraintEqualToConstant: 22.0f].active = YES;
        [removeButton.widthAnchor constraintEqualToConstant: 22.0f].active = YES;
        [removeButton.rightAnchor constraintEqualToAnchor: addButton.leftAnchor
                                              constant: -10].active = YES;
        
        [removeButton.centerYAnchor constraintEqualToAnchor: self.centerYAnchor].active = YES;
    }
    return self;
}

- (void) layoutSubviews
{
    [super layoutSubviews];

    CGFloat offset = -self.layoutMargins.right;
    if(self.accessoryType == UITableViewCellAccessoryDisclosureIndicator)
    {
        offset -= 30.0f;
    }
    
    rightLayoutConstraint.constant = offset;
}

- (void) setSelected: (BOOL) selected
            animated: (BOOL) animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void) onRemoveButton: (id) sender
{
    [delegate deckCardModifierDecreased: self];
}

- (void) onAddButton: (id) sender
{
    [delegate deckCardModifierIncrease: self];
}

@end
