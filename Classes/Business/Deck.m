//
//  Deck.m
//  MTG Deck Builder
//
//  Created by Kyle Hankinson on 11-10-02.
//  Copyright (c) 2011 Hankinsoft. All rights reserved.
//

#import "Deck.h"
#import "MTGCard.h"
#import "MTGCardInDeck.h"
#import "AppDelegate.h"
#import "MTGPriceManager.h"

#define	DECK_KEY		@"DeckNSDefaultKey"

@interface Deck()

- (MTGCardInDeck*) deckCardForMultiverseId: (NSInteger) multiverseId;

@end

@implementation Deck

@synthesize orderId, deckName, cards;


#pragma mark Persistance
#pragma mark -

+ (NSMutableArray*) decks
{
	static NSMutableArray * _decks = nil;
    
	if ( nil == _decks )
	{
		_decks = [[NSMutableArray alloc] init];
        
		NSUserDefaults *currentDefaults = [NSUserDefaults standardUserDefaults];
		NSData *dataRepresentingSavedArray = [currentDefaults objectForKey: DECK_KEY];
        
		if ( dataRepresentingSavedArray != nil )
		{
			NSArray * loadedArray = [NSKeyedUnarchiver unarchiveObjectWithData:dataRepresentingSavedArray];
			[_decks addObjectsFromArray: loadedArray];
		}
    } // End of we had no decks

    return _decks;
} // End of loadDecks

+ (void) saveDecks
{
	// Save our smart search objects
	[[NSUserDefaults standardUserDefaults] setObject: [NSKeyedArchiver archivedDataWithRootObject: [Deck decks]] forKey: DECK_KEY];
}

+ (NSString*) clauseForDeck: (Deck*) deck
{
    NSMutableString * clause = [[NSMutableString alloc] initWithString: @"cardId IN ( -1, "];

    NSUInteger count = [deck.cards count];
    for(NSUInteger i = 0; i < count; ++i)
    {
        MTGCardInDeck * deckCard = [deck.cards objectAtIndex: i];
        [clause appendFormat: @"%ld, ", (long)deckCard.multiverseId];
    } // End of card loop

    return [clause substringToIndex: clause.length - 2];
} // End of clauseForDeck

- (id) init
{
    self = [super init];
    if(self)
    {
        self.cards = [[NSMutableArray alloc] init];
    } // End of self

    return self;
}
- (id) initWithCoder: (NSCoder *)coder
{
    self = [super init];
    if ( self )
    {
        self.deckName =       [coder decodeObjectForKey:  @"deckName"];
        self.orderId  =       [coder decodeIntegerForKey: @"orderId"];
        self.cards    =		  [coder decodeObjectForKey:  @"cards"];

        if(nil == self.cards)
        {
            self.cards = [[NSMutableArray alloc] init];
        }

        // Remove any items that have a count of zero or less (should not happen. But just trying to ensure it).
        for(NSInteger i = self.cards.count - 1; i >= 0; --i)
        {
            MTGCardInDeck * deckCard = [self.cards objectAtIndex: i];
            if(deckCard.count <= 0) [self.cards removeObject: deckCard];
        } // End of loop
    } // End of init
    
    return self;
}

- (void) encodeWithCoder: (NSCoder *)coder
{
    [coder encodeObject: deckName       forKey: @"deckName"];
    [coder encodeInteger: orderId       forKey: @"orderId"];

	[coder encodeObject: cards          forKey: @"cards"];
} // End of encodeWithCoder




- (NSUInteger) addCard: (MTGCard*) card
{
    MTGCardInDeck * deckCard = [self deckCardForMultiverseId: card.multiverseId];
    if(nil == deckCard)
    {
        // Create a new deckCard (initialize count to zero)
        deckCard = [[MTGCardInDeck alloc] init];
        deckCard.multiverseId = card.multiverseId;
        deckCard.count = 0;

        [cards addObject: deckCard];
    } // End of deckCard was nil

    return ++deckCard.count;
} // End of addCardToDeck

- (BOOL) removeCard: (MTGCard*) card
       allowRemoval: (BOOL) allowRemoval
{
    BOOL removedFromDeck = NO;

    MTGCardInDeck * deckCard = [self deckCardForMultiverseId: card.multiverseId];
    if(deckCard && deckCard.count > 0)
    {
        --deckCard.count;

        if(0 == deckCard.count && YES == allowRemoval)
        {
            removedFromDeck = YES;
            [cards removeObject: deckCard];
        }
    } // End of the card is there.

    return removedFromDeck;
}

- (MTGCardInDeck*) deckCardForMultiverseId: (NSInteger) multiverseId
{
    NSUInteger count = [self.cards count];
    for(NSUInteger i = 0; i < count; ++i)
    {
        MTGCardInDeck * temp = [cards objectAtIndex: i];
        if(temp.multiverseId == multiverseId)
        {
            return temp;
        } // End of multiverseId matches
    } // End of loop

    return nil;
} // End of deckCardForMultiverseId

- (NSUInteger) countOfCards
{
    NSUInteger result = 0;
    NSUInteger count = [self.cards count];
    for(NSUInteger i = 0; i < count; ++i)
    {
        MTGCardInDeck * temp = [cards objectAtIndex: i];

        result += temp.count;
    } // End of loop
    
    return result;
} // End of countOfCards

- (NSUInteger) countOfCard: (MTGCard*) card
{
    MTGCardInDeck * deckCard = nil;
    NSUInteger count = [self.cards count];
    for(NSUInteger i = 0; i < count; ++i)
    {
        MTGCardInDeck * temp = [cards objectAtIndex: i];
        if(temp.multiverseId == card.multiverseId)
        {
            deckCard = temp;
        } // End of multiverseId matches
    } // End of loop
    
    if(deckCard)
    {
        return deckCard.count;
    }
    
    return 0;
} // End of countOfCard

- (double) priceForDeck
{
    CGFloat price = 0;

    for(MTGCardInDeck * temp in cards)
    {
        CGFloat pricePerCard = [MTGPriceManager priceForMultiverseId: temp.multiverseId].mediumPrice.doubleValue;
        price += (pricePerCard * temp.count);
    } // End of card loop

    return price;
}

- (int) landsInDeck
{
    __block int landCount = 0;

    weakify(self);
    [[AppDelegate databaseQueue] inDatabase: ^(FMDatabase * database) {
        strongify(self);

        for(MTGCardInDeck * temp in self->cards)
        {
            NSString * landQuery = [NSString stringWithFormat: @"SELECT 1 FROM card WHERE multiverseId = %ld AND type LIKE '%%land%%'", (long) temp.multiverseId];

            FMResultSet * results = [database executeQuery: landQuery];

            while ([results next])
            {
                landCount += temp.count;
            }
        }
    }];// End of query

    return landCount;
} // End of landsInDeck

- (NSUInteger) totalMana
{
    __block NSUInteger manaCost = 0;
    [[AppDelegate databaseQueue] inDatabase: ^(FMDatabase * database) {
        for(MTGCardInDeck * temp in self.cards)
        {
            NSString * manaCostQuery =
                [NSString stringWithFormat: @"SELECT convertedManaCost FROM card WHERE multiverseId = %ld", (long)temp.multiverseId];

            FMResultSet * results = [database executeQuery: manaCostQuery];

            while ([results next])
            {
                NSUInteger convertedManaCost = [results intForColumnIndex: 0];
                manaCost += (convertedManaCost * temp.count);
            }
        }
    }]; // End of query

    return manaCost;
}

@end
