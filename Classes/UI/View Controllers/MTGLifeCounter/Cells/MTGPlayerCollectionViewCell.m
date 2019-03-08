//
//  MTGPlayerCollectionViewCell.m
//  MTG Deck Builder
//
//  Created by kylehankinson on 2018-08-14.
//  Copyright © 2018 Hankinsoft Development, Inc. All rights reserved.
//

#import "MTGPlayerCollectionViewCell.h"
#import "MTGPlayer.h"
#import "MTGLifeCounter.h"

@interface MTGPlayerCollectionViewCell()
{
}

@property(nonatomic,retain) IBOutlet UIView         * poisonView;
@property(nonatomic,retain) IBOutlet UIView         * commanderView;

@property(nonatomic,retain) IBOutlet UILabel        * playerNameLabel;
@property(nonatomic,retain) IBOutlet UILabel        * playerLifeLabel;
@property(nonatomic,retain) IBOutlet UILabel        * playerPoisonCountersLabel;

@end

@implementation MTGPlayerCollectionViewCell
{
    MTGPlayer * player;
}

static UIColor * backgroundColor;

+ (void) load
{
    backgroundColor = [UIColor colorWithRed: 33.0 / 255.0f
                                      green: 33.0 / 255.0f
                                       blue: 33.0 / 255.0f
                                      alpha: 1];
} // End of load

- (void) awakeFromNib
{
    [super awakeFromNib];

    self.contentView.layer.cornerRadius = 16.0f;
    self.contentView.layer.borderWidth = 1.0f;
    self.contentView.layer.borderColor = [UIColor darkGrayColor].CGColor;
    self.contentView.layer.backgroundColor = backgroundColor.CGColor;
    self.contentView.layer.masksToBounds = YES;
    
    self.layer.masksToBounds = YES;

    [_poisonView removeFromSuperview];
    _poisonView.translatesAutoresizingMaskIntoConstraints = false;
    _poisonView.backgroundColor = backgroundColor;

    [_commanderView removeFromSuperview];
    _commanderView.translatesAutoresizingMaskIntoConstraints = false;
    _commanderView.backgroundColor = backgroundColor;
    
    UITapGestureRecognizer * tapGesture =
        [[UITapGestureRecognizer alloc] initWithTarget: self
                                                action: @selector(commanderViewTapped:)];
    
    [_commanderView addGestureRecognizer: tapGesture];
}

- (void) commanderViewTapped: (id) sender
{
    if(self.delegate && [self.delegate respondsToSelector: @selector(playerCollectionViewCell:wantsEDHForPlayer:)])
    {
        [self.delegate playerCollectionViewCell: self
                              wantsEDHForPlayer: player];
    }
} // End of commanderViewTapped:

- (void) setPlayer: (MTGPlayer *)mtgPlayer
{
    player = mtgPlayer;
    [self updateDisplay];
} // End of setPlayer

- (void) updateDisplay
{
    _playerNameLabel.text = player.name;
    _playerLifeLabel.text = [NSString stringWithFormat: @"%ld", (long) player.life];
    _playerPoisonCountersLabel.text = [NSString stringWithFormat: @"%ld", (long) player.poisonCounters];
} // End of updateDisplay

- (IBAction) onLifeCounterMinus1: (id)sender
{
    player.life -= 1;
    [self updateDisplay];
    
    [MTGLifeCounter.sharedInstance save];
} // End of onLifeCounterMinus1:

- (IBAction) onLifeCounterMinus5: (id)sender
{
    player.life -= 5;
    [self updateDisplay];
    
    [MTGLifeCounter.sharedInstance save];
} // End of onLifeCounterMinus5:

- (IBAction) onLifeCounterAdd1: (id)sender
{
    player.life += 1;
    [self updateDisplay];
    
    [MTGLifeCounter.sharedInstance save];
} // End of onLifeCounterAdd1:

- (IBAction) onLifeCounterAdd5: (id)sender
{
    player.life += 5;
    [self updateDisplay];
    
    [MTGLifeCounter.sharedInstance save];
} // End of onLifeCounterAdd5:

- (IBAction) onPoisonCounterMinus1: (id)sender
{
    player.poisonCounters -= 1;
    [self updateDisplay];
    
    [MTGLifeCounter.sharedInstance save];
} // End of onPoisonCounterMinus1:

- (IBAction) onPoisonCounterAdd1: (id)sender
{
    player.poisonCounters += 1;
    [self updateDisplay];
    
    [MTGLifeCounter.sharedInstance save];
} // End of onPoisonCounterMinus1:

- (void) willDisplayWithPoison: (BOOL) withPoison
                    edhEnabled: (BOOL) edhEnabled
{
    if(withPoison)
    {
        if(nil == _poisonView.superview)
        {
            [self.contentView addSubview: _poisonView];
            [_poisonView.leftAnchor constraintEqualToAnchor: self.contentView.leftAnchor].active = true;
            [_poisonView.rightAnchor constraintEqualToAnchor: self.contentView.rightAnchor].active = true;
            [_poisonView.topAnchor constraintEqualToAnchor: self.contentView.topAnchor
                                                  constant: 115].active = true;
        }
    }
    else if(_poisonView.superview)
    {
        [_poisonView removeFromSuperview];
    }

    if(edhEnabled)
    {
        if(nil == _commanderView.superview)
        {
            [self.contentView addSubview: _commanderView];
            [_commanderView.leftAnchor constraintEqualToAnchor: self.contentView.leftAnchor].active = true;
            [_commanderView.rightAnchor constraintEqualToAnchor: self.contentView.rightAnchor].active = true;
            [_commanderView.bottomAnchor constraintEqualToAnchor: self.contentView.bottomAnchor].active = true;
        }
    }
    else if(_commanderView.superview)
    {
        [_commanderView removeFromSuperview];
    }
} // End of willDisplayWithPoison:

@end
