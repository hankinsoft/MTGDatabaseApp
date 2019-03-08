//
//  MTGPlayer.h
//  MTG Deck Builder
//
//  Created by kylehankinson on 2018-08-14.
//  Copyright © 2018 Hankinsoft Development, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kMaxNumberOfPlayers     10

@interface MTGPlayer : NSObject

@property(nonatomic,copy) NSString * name;
@property(nonatomic,assign) NSInteger life;
@property(nonatomic,assign) NSInteger poisonCounters;

- (NSInteger) commanderDamageForPlayerIndex: (NSUInteger) playerIndex;
- (void) setCommanderDamage: (NSInteger) commanderDamage
                  forPlayerIndex: (NSUInteger) playerIndex;

@end
