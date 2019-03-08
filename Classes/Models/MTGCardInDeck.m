//
//  DeckCard.m
//  MTG Deck Builder
//
//  Created by Kyle Hankinson on 11-10-02.
//  Copyright (c) 2011 Hankinsoft. All rights reserved.
//

#import "MTGCardInDeck.h"

@implementation MTGCardInDeck

@synthesize multiverseId, count;

+ (void) load
{
    [NSKeyedUnarchiver setClass: [MTGCardInDeck class]
                   forClassName: @"DeckCard"];
} // End of load

- (id) initWithCoder: (NSCoder *)coder
{
    self = [super init];
    if ( self )
    {
        self.multiverseId   = [coder decodeIntegerForKey: @"multiverseId"];
        self.count          = [coder decodeIntegerForKey: @"count"];
    } // End of init

    return self;
}

- (void) encodeWithCoder: (NSCoder *)coder
{
    [coder encodeInteger: multiverseId  forKey: @"multiverseId"];
    [coder encodeInteger: count         forKey: @"count"];
} // End of encodeWithCoder

@end
