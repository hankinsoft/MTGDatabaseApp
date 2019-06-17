//
//  Card.m
//  Pokemon Trading Cards (TCG) List
//
//  Created by Kyle Hankinson on 10-06-10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "MTGCardSet.h"
#import "MTGCard.h"
#import "AppDelegate.h"
#import "NetworkActivityIndicatorHelper.h"
#import "MTGCardSortOptionsViewController.h"

@implementation MTGCard
{
    NSInteger   multiverseId;
    NSInteger   cardSetId;
    
    NSString    * name;
    UIImage     * image;
    
    // Details
    NSString    * cost;
    NSString    * color;
    NSString    * rarity;
    NSString    * type;
    NSString    * description;
    NSString    * flavorText;
    
    NSInteger   convertedManaCost;
    NSNumber    * collectorsNumber;
}

@synthesize multiverseId, cardSetId, name, image;
// Details
@synthesize cost, color, rarity, type, description, flavorText;

@synthesize convertedManaCost, collectorsNumber;
@synthesize power, toughness;

+ (FMDatabaseQueue*) databaseQueue
{
    return [[AppDelegate instance] dbQueue];
}

+ (NSArray*) listOfMultiverseIds
{
	NSString * query = @"SELECT DISTINCT multiverseId FROM card";

//	NSLog( @"Running query (listOfMultiverseIds): %@", query );

	__block NSMutableArray * ids = [[NSMutableArray alloc] init];
    [[AppDelegate databaseQueue] inDatabase: ^(FMDatabase * database) {
        FMResultSet * results = [database executeQuery: query];

		while ( [results next] )
		{
			NSInteger _id = [results intForColumnIndex: 0];
			[ids addObject: [NSNumber numberWithInteger:_id]];
		}
    }]; // End of query

	return ids;
}

+ (MTGCard*) cardWithMultiverseId: (NSInteger) multiverseId
{
    MTGCard* card = nil;

    NSString * clause = [NSString stringWithFormat: @"multiverseId = %ld", (long)multiverseId];
    NSArray* cards = [self loadCardsWithClause: clause
                                         limit: NSMakeRange(0, 1)];

    card = cards.firstObject;

    return card;
} // End of cardWithMultiverseId

+ (NSArray*) loadCardsWithClause: (NSString*) clause
                           limit: (NSRange) limit
{
    NSString * sortMode = MTGSortModeAscending == [MTGCardSortOptionsViewController sortMode] ? @"ASC" : @"DESC";

    if(nil == clause)
    {
        clause = @"1=1";
    }

    NSString * orderBy = nil;
    switch([MTGCardSortOptionsViewController sortBy])
    {
        case MTGSortByName:
            orderBy = [NSString stringWithFormat: @"card.name %@", sortMode];
            break;
        case MTGSortByPrice:
            orderBy = [NSString stringWithFormat: @"highPrice(card.multiverseId) %@, card.name ASC", sortMode];
            break;
        case MTGSortByConvertedManaCost:
            orderBy = [NSString stringWithFormat: @"CAST(card.convertedManaCost AS INTEGER) %@, card.name ASC", sortMode];
            break;
        case MTGSortByCollectorsNumber:
            orderBy = [NSString stringWithFormat: @"CAST(card.collectorsNumber AS INTEGER) %@, card.name ASC", sortMode];
            break;
        case MTGSortByRarity:
            orderBy = [NSString stringWithFormat: @"rarityIndex(card.rarity) %@, card.name ASC", sortMode];
            break;
        case MTGSortByPower:
            clause = [clause stringByAppendingFormat: @" AND power IS NOT NULL"];
            orderBy = [NSString stringWithFormat: @"CAST(power AS FLOAT) %@, power %@, card.name ASC", sortMode, sortMode];
            break;
        case MTGSortByToughness:
            clause = [clause stringByAppendingFormat: @" AND toughness IS NOT NULL"];
            orderBy = [NSString stringWithFormat: @"CAST(toughness AS FLOAT) %@, toughness %@, card.name ASC", sortMode, sortMode];
            break;
        case MTGSortByReleaseDate:
            orderBy = [NSString stringWithFormat: @"cardSet.releaseDate %@, card.name ASC", sortMode];
            break;
    }

    return [self loadCardsWithClause: clause
                             orderBy: orderBy
                               limit: limit];
} // End of loadCardsWithClause

+ (NSArray*) loadCardsWithClause: (NSString*) clause
                         orderBy: (NSString*) orderBy
                           limit: (NSRange) limit
{
	NSString * query;

    const NSString * columnsToLoad =
        @"card.multiverseId, card.name, card.cost, card.color, card.type, card.text, card.rarity, card.cardSetId, card.artistId, card.flavorText, card.power, card.toughness, card.convertedManaCost, card.collectorsNumber, card.text";

    query = [[NSString alloc] initWithFormat: @"SELECT %@ FROM card", columnsToLoad];
    if(NSNotFound != [clause rangeOfString: @"format.name" options:NSCaseInsensitiveSearch].location)
    {
        query = [query stringByAppendingString: @" INNER JOIN card_format ON card_format.multiverseId = card.multiverseId INNER JOIN format ON card_format.formatId = format.formatId"];
    }

    if(NSNotFound != [clause rangeOfString: @"cardSet" options:NSCaseInsensitiveSearch].location ||
       NSNotFound != [orderBy rangeOfString: @"cardSet" options:NSCaseInsensitiveSearch].location)
    {
        query = [query stringByAppendingString: @" INNER JOIN cardSet ON cardSet.cardSetId = card.cardSetId"];
    }

    if(0 != clause.length && ![@"1=1" isEqualToString: clause])
    {
        query = [query stringByAppendingFormat: @" WHERE %@", clause];
    }

    // If we have no orderBy
    if(0 != orderBy.length)
    {
        query = [query stringByAppendingFormat: @" ORDER BY %@", orderBy];
    } // End of we have no order by

    query = [query stringByAppendingFormat: @" LIMIT %ld, %ld", (unsigned long)limit.location, (unsigned long)limit.length];

//	NSLog( @"Running query (loadCardsWithClause): %@", query );

	__block NSMutableArray * cards = [[NSMutableArray alloc] init];

    MachTimer * databaseLoadTimer = [MachTimer startTimer];

    [[AppDelegate databaseQueue] inDatabase:
     ^(FMDatabase * database)
    {
        NSError * error = nil;
        FMResultSet * results = [database executeQuery: query
                                                values: nil
                                                 error: &error];

        if(error)
        {
#if DEBUG
            raise(SIGSTOP);
#endif
            NSError * reportError =
                [NSError errorWithDomain: @"mtg.loadCardWithClause:orderBy:limit"
                                    code: 0
                                userInfo: @{NSLocalizedDescriptionKey: error.localizedDescription}];

            [[HSLogHelper sharedInstance] logError: reportError
                                       withDetails: @{@"query": query}];
        } // End of we have an error

        while ([results next])
        {
			NSInteger _id = [results intForColumnIndex: 0];

            NSString * name = [results stringForColumn: @"name"];
			MTGCard * _card = [[MTGCard alloc] initWithMultiverseId: _id
														 name: name];

            _card.cardSetId = [results intForColumn: @"cardSetId"];
            _card.artistId  = [results intForColumn: @"artistId"];
            _card.type      = [results stringForColumn: @"type"];
            _card.rarity    = [results stringForColumn: @"rarity"];
            _card.cost      = [results stringForColumn: @"cost"];
            _card.convertedManaCost = [results intForColumn: @"convertedManaCost"];

            if(![results columnIsNull: @"collectorsNumber"])
            {
                _card.collectorsNumber = [NSNumber numberWithInteger: [results intForColumn: @"collectorsNumber"]];
            }
            
            _card.description = [results stringForColumn: @"text"];

            if(![results columnIsNull: @"power"])
            {
                [_card setPower: [NSNumber numberWithInt: [results intForColumn: @"power"]]];
            }
            
            if(![results columnIsNull: @"toughness"])
            {
                [_card setToughness: [NSNumber numberWithInt: [results intForColumn: @"toughness"]]];
            }

			[cards addObject: _card];
		}
    }]; // End of query

    NSLog(@"SmartSet load of %ld entries took %0.2f.",
          (unsigned long)cards.count, databaseLoadTimer.elapsedSeconds);

    // Special case: Sort by name, we will move columns such as "Ach, Hans, Run!" and _____ to the END.
    MTGSortBy sortBy = MTGCardSortOptionsViewController.sortBy;
    if(MTGSortByName == sortBy)
    {
        MTGSortMode sortBy = [MTGCardSortOptionsViewController sortMode];

        BOOL ascending = sortBy == MTGSortModeAscending;

        [cards sortUsingComparator:
         ^(MTGCard * card1, MTGCard* card2)
         {
             NSString * obj1 = card1.name;
             NSString * obj2 = card2.name;

             /* NSOrderedAscending, NSOrderedSame, NSOrderedDescending */
             BOOL isPunct1 =
                ![[NSCharacterSet alphanumericCharacterSet] characterIsMember:[(NSString*)obj1 characterAtIndex:0]];

             BOOL isPunct2 =
                ![[NSCharacterSet alphanumericCharacterSet] characterIsMember:[(NSString*)obj2 characterAtIndex:0]];

             if (isPunct1 && !isPunct2)
             {
                 return NSOrderedDescending;
             }
             else if (!isPunct1 && isPunct2)
             {
                 return NSOrderedAscending;
             }

             return [obj1 compare: obj2
                          options: NSDiacriticInsensitiveSearch|NSCaseInsensitiveSearch];
         }];

        if(!ascending)
        {
            cards = [[cards reverseObjectEnumerator] allObjects].mutableCopy;
        }
    } // End of sort

//    TOCK(@"Data loading.");

	return cards;
}

+ (NSUInteger) countCardWithClause: (NSString*) clause
{
    NSString * query;

    // Note: Don't need an order by for a count
    if(NSNotFound != [clause rangeOfString: @"format.name" options:NSCaseInsensitiveSearch].location)
    {
        query = [[NSString alloc] initWithFormat: @"SELECT COUNT(card.multiverseId) FROM card JOIN cardSet ON cardSet.cardSetId = card.cardSetId INNER JOIN card_format ON card_format.multiverseId = card.multiverseId INNER JOIN format ON card_format.formatId = format.formatId WHERE %@",
                 clause];
    }
    else
    {
        query = [[NSString alloc] initWithFormat: @"SELECT COUNT(card.multiverseId) FROM card JOIN cardSet ON cardSet.cardSetId = card.cardSetId WHERE %@",
						clause];
    }

//	NSLog( @"Running query (countCardsWithClause): %@", query );

    __block NSInteger count = 0;
    [[AppDelegate databaseQueue] inDatabase: ^(FMDatabase * database) {
        NSError * error = nil;
        FMResultSet * results = [database executeQuery: query
                                                values: nil
                                                 error: &error];

        if(error)
        {
            NSError * reportError =
                [NSError errorWithDomain: @"mtg.countCardWithClause"
                                    code: 0
                                userInfo: @{NSLocalizedDescriptionKey: error.localizedDescription}];

            [[HSLogHelper sharedInstance] logError: reportError
                                       withDetails: @{@"query": query}];
        } // End of we have an error

        while ([results next])
        {
			count = [results intForColumnIndex: 0];
		}
    }]; // End of query

    return count;
}

- (NSString*) color
{
	if ( 0 == [color length] )
	{
		return @"Colorless";
	}

	return color;
}

- (NSString*) HTMLSetIcon
{
    MTGCardSet * cardSet = [MTGCardSet cardSetById: self.cardSetId];

    NSString * fileName = [NSString stringWithFormat: @"setImage-%@%@.png", cardSet.shortName, [self.rarity isEqualToString: @"Land"] ? @"C" : self.rarity];

    NSString * bundleIconPath = [[NSBundle mainBundle] pathForResource: fileName ofType: nil];
    
    // If the file does not exist, then
    if([[NSFileManager defaultManager] fileExistsAtPath: bundleIconPath])
    {
        return [NSString stringWithFormat: @"<img src=\"file://%@\" />", bundleIconPath];
    }

	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory , NSUserDomainMask, YES);
	NSString *documentsDir = [paths objectAtIndex:0];

    NSString * tempIconPath   = [documentsDir stringByAppendingPathComponent: fileName];
    if([[NSFileManager defaultManager] fileExistsAtPath: tempIconPath])
    {
        return [NSString stringWithFormat: @"<img src=\"file://%@\" />", tempIconPath];
    }
    
    NSLog(@"Unknown file: %@", fileName);
    return @"";
}

- (id) initWithMultiverseId: (NSInteger)_id name: (NSString*)_name
{
    self = [super init];
	if ( self )
	{
		[self setMultiverseId: _id];
		[self setName: _name];
	}

	return self;
}

#pragma mark -
#pragma mark NSAttributedString

- (NSAttributedString*) castingCostAttributedString
{
    NSMutableAttributedString * outString = [[NSAttributedString alloc] initWithString: self.cost].mutableCopy;

#define SIZE        @"14"

    NSDictionary * replaceDictonary =
    @{
      @"{TAP}":@"cost_" SIZE "_tap",
      @"{T}":@"cost_" SIZE "_t",
      @"{S}i}":@"cost_" SIZE "_snow",
      @"{U}":@"cost_" SIZE "_blue",
      @"{W}":@"cost_" SIZE "_white",
      @"{B}":@"cost_" SIZE "_black",
      @"{G}":@"cost_" SIZE "_green",
      @"{R}":@"cost_" SIZE "_red",
      @"{S}":@"cost_" SIZE "_snow",
      
      @"{CHAOS}":@"cost_" SIZE "_chaos",
      @"{Infinity}":@"cost_" SIZE "_infinite",
      @"{C}":@"cost_" SIZE "_c",
      @"{X}":@"cost_" SIZE "_x",
      @"{0}":@"cost_" SIZE "_0",
      @"{1}":@"cost_" SIZE "_1",
      @"{2}":@"cost_" SIZE "_2",
      @"{3}":@"cost_" SIZE "_3",
      @"{4}":@"cost_" SIZE "_4",
      @"{5}":@"cost_" SIZE "_5",
      @"{6}":@"cost_" SIZE "_6",
      @"{7}":@"cost_" SIZE "_7",
      @"{8}":@"cost_" SIZE "_8",
      @"{9}":@"cost_" SIZE "_9",
      @"{10}":@"cost_" SIZE "_10",
      @"{11}":@"cost_" SIZE "_11",
      @"{12}":@"cost_" SIZE "_12",
      @"{13}":@"cost_" SIZE "_13",
      @"{14}":@"cost_" SIZE "_14",
      @"{15}":@"cost_" SIZE "_15",
      @"{16}":@"cost_" SIZE "_16",
      @"{17}":@"cost_" SIZE "_17",
      @"{18}":@"cost_" SIZE "_18",
      @"{19}":@"cost_" SIZE "_19",
      @"{20}":@"cost_" SIZE "_20",
      
      @"{100}":@"cost_" SIZE "_100",
      @"{1000000}":@"cost_" SIZE "_1000000",
      
      @"{2/W}":@"cost_" SIZE "_2-white",
      @"{2/R}":@"cost_" SIZE "_2-red",
      @"{2/G}":@"cost_" SIZE "_2-green",
      @"{2/U}":@"cost_" SIZE "_2-blue",
      @"{2/B}":@"cost_" SIZE "_2-black",
      
      @"{{U/P}}":@"cost_" SIZE "_blue-phyrexian",
      @"{{R/P}}":@"cost_" SIZE "_red-phyrexian",
      @"{{G/P}}":@"cost_" SIZE "_green-phyrexian",
      @"{{W/P}}":@"cost_" SIZE "_white-phyrexian",
      @"{{B/P}}":@"cost_" SIZE "_black-phyrexian",
      
      @"{U/B}":@"cost_" SIZE "_blue-black",
      @"{B/R}":@"cost_" SIZE "_black-red",
      @"{W/U}":@"cost_" SIZE "_white-blue",
      @"{W/B}":@"cost_" SIZE "_white-black",
      @"{G/W}":@"cost_" SIZE "_green-white",
      @"{G/U}":@"cost_" SIZE "_green-blue"
    };

    NSRange foundRange;
    for(NSString * key in replaceDictonary.allKeys)
    {
        NSString * replaceWith = replaceDictonary[key];
        while (NSNotFound != ((foundRange = [outString.mutableString rangeOfString: key
                                                                           options: NSCaseInsensitiveSearch]).location))
        {
            [outString replaceCharactersInRange: foundRange
                           withAttributedString: [MTGCard attributedStringForImageNamed: replaceWith]];
        }
    }
    
    return outString;
} // End of castingCostAttributedString

- (NSAttributedString*) rulesAttributedString
{
    // Handle an empty string
    if(nil == self.description || 0 == self.description.length)
    {
        return [[NSAttributedString alloc] init];
    } // End of empty string

    NSMutableAttributedString * outString = [[NSAttributedString alloc] initWithString: self.description].mutableCopy;
    
    NSRange foundRange;
    while (NSNotFound != ((foundRange = [outString.mutableString rangeOfString: @"\r\n\r\n"
                                                                       options: NSCaseInsensitiveSearch]).location))
    {
        [outString.mutableString replaceCharactersInRange: foundRange
                                               withString: @"\r\n"];
    }
    while (NSNotFound != ((foundRange = [outString.mutableString rangeOfString: @"\n\n"
                                                                       options: NSCaseInsensitiveSearch]).location))
    {
        [outString.mutableString replaceCharactersInRange: foundRange
                                               withString: @"\n"];
    }

#define SIZE_RULES        @"10"

    NSDictionary * replaceDictonary =
    @{
      @"{TAP}":@"cost_" SIZE_RULES "_tap",
      @"{T}":@"cost_" SIZE_RULES "_t",
      @"{S}i}":@"cost_" SIZE_RULES "_snow",
      @"{U}":@"cost_" SIZE_RULES "_blue",
      @"{W}":@"cost_" SIZE_RULES "_white",
      @"{B}":@"cost_" SIZE_RULES "_black",
      @"{G}":@"cost_" SIZE_RULES "_green",
      @"{R}":@"cost_" SIZE_RULES "_red",
      @"{S}":@"cost_" SIZE_RULES "_snow",

      @"{CHAOS}":@"cost_" SIZE_RULES "_chaos",
      @"{Infinity}":@"cost_" SIZE_RULES "_infinite",
      @"{X}":@"cost_" SIZE_RULES "_x",
      @"{C}":@"cost_" SIZE_RULES "_c",
      @"{0}":@"cost_" SIZE_RULES "_0",
      @"{1}":@"cost_" SIZE_RULES "_1",
      @"{2}":@"cost_" SIZE_RULES "_2",
      @"{3}":@"cost_" SIZE_RULES "_3",
      @"{4}":@"cost_" SIZE_RULES "_4",
      @"{5}":@"cost_" SIZE_RULES "_5",
      @"{6}":@"cost_" SIZE_RULES "_6",
      @"{7}":@"cost_" SIZE_RULES "_7",
      @"{8}":@"cost_" SIZE_RULES "_8",
      @"{9}":@"cost_" SIZE_RULES "_9",
      @"{10}":@"cost_" SIZE_RULES "_10",
      @"{11}":@"cost_" SIZE_RULES "_11",
      @"{12}":@"cost_" SIZE_RULES "_12",
      @"{13}":@"cost_" SIZE_RULES "_13",
      @"{14}":@"cost_" SIZE_RULES "_14",
      @"{15}":@"cost_" SIZE_RULES "_15",
      @"{16}":@"cost_" SIZE_RULES "_16",
      @"{17}":@"cost_" SIZE_RULES "_17",
      @"{18}":@"cost_" SIZE_RULES "_18",
      @"{19}":@"cost_" SIZE_RULES "_19",
      @"{20}":@"cost_" SIZE_RULES "_20",
      @"{100}":@"cost_" SIZE_RULES "_100",
      @"{1000000}":@"cost_" SIZE_RULES "_1000000",
      
      @"{2/W}":@"cost_" SIZE_RULES "_2-white",
      @"{2/R}":@"cost_" SIZE_RULES "_2-red",
      @"{2/G}":@"cost_" SIZE_RULES "_2-green",
      @"{2/U}":@"cost_" SIZE_RULES "_2-blue",
      @"{2/B}":@"cost_" SIZE_RULES "_2-black",

      @"{{U/P}}":@"cost_" SIZE_RULES "_blue-phyrexian",
      @"{{R/P}}":@"cost_" SIZE_RULES "_red-phyrexian",
      @"{{G/P}}":@"cost_" SIZE_RULES "_green-phyrexian",
      @"{{W/P}}":@"cost_" SIZE_RULES "_white-phyrexian",
      @"{{B/P}}":@"cost_" SIZE_RULES "_black-phyrexian",

      @"{(U/B)}":@"cost_" SIZE_RULES "_blue-black",
      @"{(B/R)}":@"cost_" SIZE_RULES "_black-red",
      @"{(W/U)}":@"cost_" SIZE_RULES "_white-blue",
      @"{(W/B)}":@"cost_" SIZE_RULES "_white-black",
      @"{{G/W}}":@"cost_" SIZE_RULES "_green-white",
      @"{{G/U}}":@"cost_" SIZE_RULES "_green-blue"
      };

    for(NSString * key in replaceDictonary.allKeys)
    {
        NSString * replaceWith = replaceDictonary[key];
        while (NSNotFound != ((foundRange = [outString.mutableString rangeOfString: key
                                                                           options: NSCaseInsensitiveSearch]).location))
        {
            [outString replaceCharactersInRange: foundRange
                           withAttributedString: [MTGCard attributedStringForImageNamed: replaceWith]];
        }
    }

    if(outString.length && ![outString.string hasSuffix: @"."])
    {
        [outString.mutableString appendString: @"."];
    } // End of need to end with period

    return outString;
}

+ (NSAttributedString*) attributedStringForImageNamed: (NSString*) imageName
{
    UIImage * image = [UIImage imageNamed: imageName];
    if(nil == image)
    {
        return [[NSAttributedString alloc] initWithString: imageName];
    }

    NSTextAttachment *textAttachment = [[NSTextAttachment alloc] init];
    textAttachment.image = image;
    if(textAttachment.bounds.size.height > 14)
    {
        textAttachment.bounds = CGRectMake(0, 0, 14, 14);
    }

    NSAttributedString *attrStringWithImage =
        [NSAttributedString attributedStringWithAttachment: textAttachment];

    return attrStringWithImage;
} // End of attributedStringForImageNamed

@end
