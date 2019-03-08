//
//  Deck.h
//  MTG Deck Builder
//
//  Created by Kyle Hankinson on 11-10-02.
//  Copyright (c) 2011 Hankinsoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MTGCard;

@interface Deck : NSObject
{
}

@property (nonatomic, assign) NSInteger       orderId;
@property (nonatomic, retain) NSString        * deckName;
@property (nonatomic, retain) NSMutableArray  * cards;

+ (NSMutableArray*) decks;
+ (void) saveDecks;
+ (NSString*) clauseForDeck: (Deck*) deck;

- (NSUInteger) addCard: (MTGCard*) card;
- (BOOL) removeCard: (MTGCard*) card
       allowRemoval: (BOOL) allowRemoval;

- (NSUInteger) countOfCards;
- (NSUInteger) countOfCard: (MTGCard*) card;

- (double) priceForDeck;
- (int) landsInDeck;
- (NSUInteger) totalMana;

@end
