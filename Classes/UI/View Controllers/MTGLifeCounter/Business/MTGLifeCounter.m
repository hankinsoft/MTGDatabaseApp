//
//  MTGLifeCounter.m
//  MTG Deck Builder
//
//  Created by kylehankinson on 2018-08-15.
//  Copyright © 2018 Hankinsoft Development, Inc. All rights reserved.
//

#import "MTGLifeCounter.h"

#define kGameState              @"MTGLifeCounter"
#define kLastUpdated            @"lastUpdated"
#define kDefaultLifeTotal       @"defaultLifeTotal"
#define kNumberOfPlayers        @"numberOfPlayers"
#define kPoisonEnabled          @"poisonEnabled"
#define kCommanderEnabled       @"commanderEnabled"
#define kPlayerName             @"playerName"
#define kPlayerLife             @"playerLife"
#define kPlayerPoisonCounters   @"playerPoisonCounters"

@implementation MTGLifeCounter
{
    NSArray<MTGPlayer*>* players;

    NSUInteger      _defaultLifeTotal;
    NSUInteger      _numberOfPlayers;
    BOOL            _poisonEnabled;
    BOOL            _commanderEnabled;

    NSUInteger      lastUpdateTimestamp;
}

+ (MTGLifeCounter*) sharedInstance
{
    // structure used to test whether the block has completed or not
    static dispatch_once_t onceToken = 0;
    
    // initialize sharedObject as nil (first call only)
    __strong static id _sharedObject = nil;
    
    // executes a block object once and only once for the lifetime of an application
    dispatch_once(&onceToken, ^{
        _sharedObject = [[self alloc] init];
    });
    
    // returns the same object each time
    return _sharedObject;
} // End of sharedInstance

- (id) init
{
    self = [super init];
    if(self)
    {
        // Defaults
        _poisonEnabled = false;
        _defaultLifeTotal = 20;
        _numberOfPlayers  = 4;

        NSMutableArray<MTGPlayer*>* tempPlayers = @[].mutableCopy;
        for(NSInteger index = 0; index < kMaxNumberOfPlayers; ++index)
        {
            MTGPlayer * player = [[MTGPlayer alloc] init];
            player.life = _defaultLifeTotal;
            player.name = [NSString stringWithFormat: @"Player %ld", (long)(index + 1)];

            [tempPlayers addObject: player];
        }

        players = tempPlayers;

        // Default to the lowest date
        lastUpdateTimestamp = 0;

        NSDictionary * currentState = [self loadGameStateDictionary];
        [self loadFromJSON: currentState];
    }

    return self;
} // End of init

- (NSDictionary*) loadGameStateDictionary
{
    NSString * gameStateString = [[NSUserDefaults standardUserDefaults] objectForKey: kGameState];
    if(nil == gameStateString || 0 == gameStateString.length)
    {
        return nil;
    } // End of no gameState

    NSData * data = [gameStateString dataUsingEncoding: NSUTF8StringEncoding];
    if(nil == data || 0 == data.length)
    {
        return nil;
    } // End of no gameState

    NSError * error = nil;
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData: data
                                                               options: kNilOptions
                                                                 error: &error];

    if(error)
    {
        return nil;
    }

    return dictionary;
} // End of loadGameStateDictionary

- (void) loadFromJSON: (NSDictionary*) gameState
{
    if(nil == gameState || 0 == gameState.allKeys)
    {
        return;
    } // End of no json

    if(gameState[kDefaultLifeTotal] && [gameState[kDefaultLifeTotal] isKindOfClass: [NSNumber class]])
    {
        _defaultLifeTotal = [gameState[kDefaultLifeTotal] integerValue];
    } // End of lifeTotal

    if(gameState[kPoisonEnabled] && [gameState[kPoisonEnabled] isKindOfClass: [NSNumber class]])
    {
        _poisonEnabled = [gameState[kPoisonEnabled] boolValue];
    } // End of _poisonEnabled

    if(gameState[kCommanderEnabled] && [gameState[kCommanderEnabled] isKindOfClass: [NSNumber class]])
    {
        _commanderEnabled = [gameState[kCommanderEnabled] boolValue];
    } // End of _commanderEnabled

    if(gameState[kNumberOfPlayers] && [gameState[kNumberOfPlayers] isKindOfClass: [NSNumber class]])
    {
        _numberOfPlayers = [gameState[kNumberOfPlayers] integerValue];
    } // End of _numberOfPlayers

    if(gameState[kLastUpdated] && [gameState[kLastUpdated] isKindOfClass: [NSNumber class]])
    {
        lastUpdateTimestamp = [gameState[kLastUpdated] integerValue];
    } // End of lastUpdateTimestamp

    for(NSUInteger index = 0; index < kMaxNumberOfPlayers; ++index)
    {
        MTGPlayer * player = players[index];
        NSString * playerEntry = [NSString stringWithFormat: @"player%ld", (long) index];
        NSMutableDictionary * playerDictionary = [gameState[playerEntry] mutableCopy];

        [self updatePlayer: player
            fromDictionary: playerDictionary];
    }
} // End of loadFromJson

- (void) save
{
    NSMutableDictionary * gameState = [self loadGameStateDictionary].mutableCopy;
    if(nil == gameState)
    {
        gameState = @{}.mutableCopy;
    } // End of no gameState

    // Update our lastUpdateTimestamp
    lastUpdateTimestamp = [NSDate date].timeIntervalSince1970;

    // Set our values
    gameState[kDefaultLifeTotal] = @(_defaultLifeTotal);
    gameState[kPoisonEnabled] = @(_poisonEnabled);
    gameState[kCommanderEnabled] = @(_commanderEnabled);
    gameState[kNumberOfPlayers] = @(_numberOfPlayers);
    gameState[kLastUpdated] = @(lastUpdateTimestamp);

    for(NSUInteger index = 0; index < kMaxNumberOfPlayers; ++index)
    {
        MTGPlayer * player = players[index];
        NSString * playerEntry = [NSString stringWithFormat: @"player%ld", (long) index];
        NSMutableDictionary * playerDictionary = [gameState[playerEntry] mutableCopy];

        if(nil == playerDictionary)
        {
            playerDictionary = @{}.mutableCopy;
        } // End of no playerDictionary

        [self updateDictionary: playerDictionary
                     forPlayer: player];

        // Set our gamestate
        gameState[playerEntry] = playerDictionary;
    }

    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject: gameState
                                                       options: NSJSONWritingPrettyPrinted
                                                         error: &error];
    if(error)
    {
        return;
    } // End of we had an error

    NSString * jsonString = [[NSString alloc] initWithData: jsonData
                                                  encoding: NSUTF8StringEncoding];

    [[NSUserDefaults standardUserDefaults] setObject: jsonString
                                              forKey: kGameState];

    // Save
    [[NSUserDefaults standardUserDefaults] synchronize];
} // End of save

- (NSUInteger) lastUpdateTimestamp
{
    return lastUpdateTimestamp;
} // End of lastUpdateTimestamp

- (void) updateDictionary: (NSMutableDictionary*) playerDictionary
                forPlayer: (MTGPlayer*) player
{
    playerDictionary[kPlayerName] = player.name;
    playerDictionary[kPlayerLife] = @(player.life);
    playerDictionary[kPlayerPoisonCounters] = @(player.poisonCounters);

    for(NSInteger index = 0; index < kMaxNumberOfPlayers; ++index)
    {
        NSString * commanderDamageKey = [NSString stringWithFormat: @"commanderDamage%ld", (long)index];
        NSInteger commanderDamage = [player commanderDamageForPlayerIndex: index];

        playerDictionary[commanderDamageKey] = @(commanderDamage);
    } // End of player enumeration
} // End of updateDictionary:forPlayer

- (void) updatePlayer: (MTGPlayer*) player
       fromDictionary: (NSDictionary*) playerDictionary
{
    // Default values
    player.life = _defaultLifeTotal;
    player.poisonCounters = 0;

    // Make sure player name is a string -- sometimes this was [NSNull null] and calling length caused an issue.
    if([playerDictionary[kPlayerName] isKindOfClass: [NSString class]] && [playerDictionary[kPlayerName] length])
    {
        player.name = playerDictionary[kPlayerName];
    } // End of a name is set

    if(playerDictionary[kPlayerLife])
    {
        player.life = [playerDictionary[kPlayerLife] integerValue];
    }

    if(playerDictionary[kPlayerPoisonCounters])
    {
        player.poisonCounters = [playerDictionary[kPlayerPoisonCounters] integerValue];
    }

    for(NSInteger index = 0; index < kMaxNumberOfPlayers; ++index)
    {
        NSString * commanderDamageKey = [NSString stringWithFormat: @"commanderDamage%ld", (long) index];
        NSInteger commanderDamage = 0;

        if(playerDictionary[commanderDamageKey])
        {
            commanderDamage = [playerDictionary[commanderDamageKey] integerValue];
        }

        [player setCommanderDamage: commanderDamage
                    forPlayerIndex: index];
    } // End of player enumeration
} // End of updatePlayer:fromDictionary:

- (void) resetGameState
{
    for(MTGPlayer * player in players)
    {
        player.life = _defaultLifeTotal;
        player.poisonCounters = 0;

        // Clear commander damage
        for(NSInteger index = 0; index < kMaxNumberOfPlayers; ++index)
        {
            [player setCommanderDamage: 0
                        forPlayerIndex: index];
        } // End of player number loop
    } // End of player name
} // End of resetGameState

- (BOOL) poisonEnabled
{
    return _poisonEnabled;
} // End of poisonEnabled

- (void) setPoisonEnabled: (BOOL) posionEnabled
{
    _poisonEnabled = posionEnabled;
}

- (BOOL) commanderEnabled
{
    return _commanderEnabled;
}

- (void) setCommanderEnabled: (BOOL) commanderEnabled
{
    _commanderEnabled = commanderEnabled;
} // End of setCommanderEnabled

- (NSUInteger) defaultLifeTotal
{
    return _defaultLifeTotal;
}

- (void) setDefaultLifeTotal: (NSUInteger) defaultLifeTotal
{
    _defaultLifeTotal = defaultLifeTotal;
}

- (NSInteger) numberOfPlayers
{
    return _numberOfPlayers;
} // End of numberOfPlayers

- (void) setNumberOfPlayers: (NSInteger) numberOfPlayers
{
    _numberOfPlayers = numberOfPlayers;
}

- (NSArray<MTGPlayer*>*) players
{
    return players;
} // End of players

@end
