//
//  MTGLifeCounter.h
//  MTG Deck Builder
//
//  Created by kylehankinson on 2018-08-15.
//  Copyright © 2018 Hankinsoft Development, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MTGPlayer.h"

@interface MTGLifeCounter : NSObject

+ (MTGLifeCounter*) sharedInstance;

- (void) save;
- (void) resetGameState;

- (NSUInteger) lastUpdateTimestamp;

- (BOOL) poisonEnabled;
- (void) setPoisonEnabled: (BOOL) posionEnabled;

- (BOOL) commanderEnabled;
- (void) setCommanderEnabled: (BOOL) commanderEnabled;

- (NSUInteger) defaultLifeTotal;
- (void) setDefaultLifeTotal: (NSUInteger) defaultLifeTotal;

- (NSInteger) numberOfPlayers;
- (void) setNumberOfPlayers: (NSInteger) numberOfPlayers;

- (NSArray<MTGPlayer*>*) players;

@property(nonatomic,assign) BOOL gameRoomEnabled;
@property(nonatomic,copy)   NSString * gameRoomName;

@end
