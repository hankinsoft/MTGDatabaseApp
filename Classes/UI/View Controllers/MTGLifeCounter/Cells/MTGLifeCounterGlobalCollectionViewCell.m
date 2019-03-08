//
//  MTGLifeCounterGlobalCollectionViewCell.m
//  MTG Deck Builder
//
//  Created by kylehankinson on 2018-08-17.
//  Copyright © 2018 Hankinsoft Development, Inc. All rights reserved.
//

#import "MTGLifeCounterGlobalCollectionViewCell.h"
#import "MTGLifeButton.h"

#define kLifeGainAlertViewTag           (1000000)

@interface MTGLifeCounterGlobalCollectionViewCell()<UITextFieldDelegate>
{
    MTGLifeButton       * minusXLifeButton;
    MTGLifeButton       * minusOneLifeButton;
    MTGLifeButton       * minusFiveLifeButton;
    MTGLifeButton       * addXLifeButton;
    MTGLifeButton       * addOneLifeButton;
    MTGLifeButton       * addFiveLifeButton;
}
@end

@implementation MTGLifeCounterGlobalCollectionViewCell

- (void) awakeFromNib
{
    [super awakeFromNib];
    
    const CGFloat spacing = 8;
    

    minusXLifeButton = [self createLifeButton: @"-X"
                                   titleColor: [UIColor redColor]];

    [self.contentView addSubview: minusXLifeButton];
    [minusXLifeButton.heightAnchor constraintEqualToConstant: 46.0].active = true;
    [minusXLifeButton.widthAnchor constraintEqualToConstant: 46.0].active = true;
    [minusXLifeButton.centerYAnchor constraintEqualToAnchor: self.contentView.centerYAnchor].active = true;
    [minusXLifeButton.leftAnchor constraintEqualToAnchor: self.contentView.leftAnchor].active = true;

    minusOneLifeButton = [self createLifeButton: @"-1"
                                   titleColor: [UIColor redColor]];

    [self.contentView addSubview: minusOneLifeButton];
    [minusOneLifeButton.heightAnchor constraintEqualToConstant: 46.0].active = true;
    [minusOneLifeButton.widthAnchor constraintEqualToConstant: 46.0].active = true;
    [minusOneLifeButton.centerYAnchor constraintEqualToAnchor: self.contentView.centerYAnchor].active = true;
    [minusOneLifeButton.leftAnchor constraintEqualToAnchor: minusXLifeButton.rightAnchor
                                                constant: spacing].active = true;

    minusFiveLifeButton = [self createLifeButton: @"-5"
                                     titleColor: [UIColor redColor]];

    [self.contentView addSubview: minusFiveLifeButton];
    [minusFiveLifeButton.heightAnchor constraintEqualToConstant: 46.0].active = true;
    [minusFiveLifeButton.widthAnchor constraintEqualToConstant: 46.0].active = true;
    [minusFiveLifeButton.centerYAnchor constraintEqualToAnchor: self.contentView.centerYAnchor].active = true;
    [minusFiveLifeButton.leftAnchor constraintEqualToAnchor: minusOneLifeButton.rightAnchor
                                                  constant: spacing].active = true;
    
    addXLifeButton = [self createLifeButton: @"+X"
                                   titleColor: [UIColor greenColor]];
    
    [self.contentView addSubview: addXLifeButton];
    [addXLifeButton.heightAnchor constraintEqualToConstant: 46.0].active = true;
    [addXLifeButton.widthAnchor constraintEqualToConstant: 46.0].active = true;
    [addXLifeButton.centerYAnchor constraintEqualToAnchor: self.contentView.centerYAnchor].active = true;
    [addXLifeButton.leftAnchor constraintEqualToAnchor: minusFiveLifeButton.rightAnchor
                                                constant: spacing].active = true;
    
    addOneLifeButton = [self createLifeButton: @"+1"
                                     titleColor: [UIColor greenColor]];
    
    [self.contentView addSubview: addOneLifeButton];
    [addOneLifeButton.heightAnchor constraintEqualToConstant: 46.0].active = true;
    [addOneLifeButton.widthAnchor constraintEqualToConstant: 46.0].active = true;
    [addOneLifeButton.centerYAnchor constraintEqualToAnchor: self.contentView.centerYAnchor].active = true;
    [addOneLifeButton.leftAnchor constraintEqualToAnchor: addXLifeButton.rightAnchor
                                                  constant: spacing].active = true;

    addFiveLifeButton = [self createLifeButton: @"+5"
                                      titleColor: [UIColor greenColor]];
    
    [self.contentView addSubview: addFiveLifeButton];
    [addFiveLifeButton.heightAnchor constraintEqualToConstant: 46.0].active = true;
    [addFiveLifeButton.widthAnchor constraintEqualToConstant: 46.0].active = true;
    [addFiveLifeButton.centerYAnchor constraintEqualToAnchor: self.contentView.centerYAnchor].active = true;
    [addFiveLifeButton.leftAnchor constraintEqualToAnchor: addOneLifeButton.rightAnchor
                                                   constant: spacing].active = true;

} // End of awakeFromNib

- (MTGLifeButton*) createLifeButton: (NSString*) title
                         titleColor: (UIColor*) titleColor
{
    MTGLifeButton * lifeButton = [MTGLifeButton buttonWithType: UIButtonTypeCustom];
    lifeButton.translatesAutoresizingMaskIntoConstraints = false;
    [lifeButton setTitle: title
                forState: UIControlStateNormal];
    [lifeButton setTitleColor: titleColor
                     forState: UIControlStateNormal];

    [lifeButton addTarget: self
                   action: @selector(onButtonAction:)
         forControlEvents: UIControlEventTouchUpInside];
    
    return lifeButton;
} // End of createLifeButton:action:

- (void) onButtonAction: (id) sender
{
    // No delegate, do nothing.
    if(!_delegate || ![_delegate respondsToSelector: @selector(mtgLifeCounterGlobalDamage:)])
    {
        return;
    } // End of delegate not implemented

    if(sender == addXLifeButton || sender == minusXLifeButton)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: sender == addXLifeButton ? @"Gain life" : @"Loose life"
                                                        message: sender == addXLifeButton ? @"How much life is everyone gaining?" : @"How much life is everyone loosing?"
                                                       delegate: self
                                              cancelButtonTitle: @"Cancel"
                                              otherButtonTitles: @"OK"
                              , nil];

        if(sender == addXLifeButton)
        {
            alert.tag = kLifeGainAlertViewTag;
        }

        alert.alertViewStyle = UIAlertViewStylePlainTextInput;
        [[alert textFieldAtIndex:0] setDelegate:self];
        [[alert textFieldAtIndex:0] setKeyboardType:UIKeyboardTypeNumberPad];
        [[alert textFieldAtIndex:0] becomeFirstResponder];
        [alert show];

        return;
    }

    NSInteger damage = 0;
    
    if(sender == minusOneLifeButton)
    {
        damage = 1;
    }
    else if(sender == minusFiveLifeButton)
    {
        damage = 5;
    }
    else if(sender == addOneLifeButton)
    {
        damage = -1;
    }
    else if(sender == addFiveLifeButton)
    {
        damage = -5;
    }

    // Do our damage
    [self.delegate mtgLifeCounterGlobalDamage: damage];
} // End of onButtonAction

- (void)   alertView: (UIAlertView *) alertView
clickedButtonAtIndex: (NSInteger)buttonIndex
{
    if (buttonIndex != alertView.cancelButtonIndex)
    {
        NSString * damageString = [alertView textFieldAtIndex: 0].text;
        NSInteger damage = [damageString integerValue];

        // If its life gain, we need to reverse the direction.
        if(kLifeGainAlertViewTag == alertView.tag)
        {
            damage = -damage;
        }

        // Do our damage
        [self.delegate mtgLifeCounterGlobalDamage: damage];
    }
}

@end
