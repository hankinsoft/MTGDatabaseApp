//
//  MTGPlayer.m
//  MTG Deck Builder
//
//  Created by kylehankinson on 2018-08-14.
//  Copyright © 2018 Hankinsoft Development, Inc. All rights reserved.
//

#import "MTGPlayer.h"

@implementation MTGPlayer
{
    NSInteger commanderDamage[kMaxNumberOfPlayers];
}

- (id) init
{
    self = [super init];
    if(self)
    {
        for(NSInteger index = 0; index < kMaxNumberOfPlayers; ++index)
        {
            commanderDamage[index] = 0;
        }
    } // End of self
    
    return self;
}

- (NSInteger) commanderDamageForPlayerIndex: (NSUInteger) playerIndex
{
    return commanderDamage[playerIndex];
}

- (void) setCommanderDamage: (NSInteger) _commanderDamage
             forPlayerIndex: (NSUInteger) playerIndex
{
    commanderDamage[playerIndex] = _commanderDamage;
}

- (void) setName: (NSString *) name
{
    // Validate our name
    if(![name isKindOfClass: [NSString class]])
    {
        name = nil;
    }
    
    _name = name;
} // End of setName:

@end
