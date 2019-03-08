//
//  CardSet.m
//  Pokemon Trading Cards (TCG) List
//
//  Created by Kyle Hankinson on 10-06-06.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "MTGCardSet.h"
#import "AppDelegate.h"
#import "MTGCardSetIconHelper.h"

@implementation MTGCardSet
@synthesize setId, name, shortName, cardCount, releaseDate, block;

- (id) initWithId: (NSInteger) _id
             name: (NSString*) _name
        shortName: (NSString*) _shortName
             type: (NSString*) _type
        cardCount: (NSInteger) _cardCount
{
	if ( self = [super init] )
	{
		[self setSetId: _id];
		[self setName: _name];
		[self setShortName: _shortName];
		[self setCardCount: _cardCount];
        [self setType: _type];
	}

	return self;
}

+ (FMDatabaseQueue*) databaseQueue
{
	return [(AppDelegate *)[[UIApplication sharedApplication] delegate] dbQueue];
}

+ (NSArray*) allCardSets
{
    static NSArray * result = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSLog(@"Start loading cardSets");

        NSMutableArray * cardSets = [[NSMutableArray alloc] init];

        TICK;

        [[AppDelegate databaseQueue] inDatabase: ^(FMDatabase * database) {
            NSString * query = @"SELECT cardSetId, name, shortName, cardCount, releaseDate, block, type FROM cardSet ORDER BY name ASC";
            FMResultSet * results = [database executeQuery: query];

            if(nil == results && nil != database.lastError)
            {
                NSLog(@"Failed to execute query: %@.\r\nError: %@.",
                      query,
                      database.lastError.localizedDescription);
            }

            while([results next])
            {
                MTGCardSet * cardSet = [[MTGCardSet alloc] initWithId: [results intForColumn: @"cardSetId"]
                                                           name: [results objectForColumnName: @"name"]
                                                      shortName: [results objectForColumnName: @"shortName"]
                                                           type: [results stringForColumn: @"type"]
                                                      cardCount: [results intForColumn: @"cardCount"]];
                cardSet.releaseDate = [results dateForColumn: @"releaseDate"];
                cardSet.block       = [results stringForColumn: @"block"];

                [cardSets addObject: cardSet];
            } // End of results loop
        }];

        NSString * loadMessage = [NSString stringWithFormat: @"Finished loading %lu cardSets", (unsigned long)cardSets.count];
        TOCK(loadMessage);
        result = cardSets;
    });

	return result;
} // End of allCardSets

+ (MTGCardSet*) cardSetById: (NSUInteger) cardSetId
{
    for(MTGCardSet * cardSet in [self allCardSets])
    {
        if(cardSet.setId == cardSetId)
        {
            return cardSet;
        }
    }
    
    return nil;
} // End of cardSetById:

@end
