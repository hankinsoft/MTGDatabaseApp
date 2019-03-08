//
//  SmartSearch.m
//  MTG Deck Builder
//
//  Created by Kyle Hankinson on 10-08-06.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import "MTGSmartSearch.h"
#import "AppDelegate.h"
#import "MTGCard.h"

#define	SMART_SEARCH_ITEMS		@"SmartSearchDefaultKey"

@interface MTGSmartSearch ()

+ (NSString*) escapeString: (NSString*) string;
+ (NSString*) buildSmartSearchClause: (MTGSmartSearch*) smartSearch;
+ (NSString*) conditionForColor: (int) colorEnum mode: (NSString*) mode include: (BOOL) include;
+ (void) appendRarityCondition: (NSMutableString*) condition forSmartSearch: (MTGSmartSearch*) search;
+ (void) appendAbilityAny: (NSMutableString*) condition forSmartSearch: (MTGSmartSearch*) search;
//+ (void) appendTypeCondition: (NSMutableString*) condition forSmartSearch: (SmartSearch*) search;

@property (nonatomic, assign) NSInteger databaseVersionCache;

@end

@implementation MTGSmartSearch

@synthesize searchName;
@synthesize orderId;
@synthesize cachedCount;
@synthesize databaseVersionCache;
@synthesize nameLike;
@synthesize typeLike;
@synthesize descriptionLike;
@synthesize artistLike;
@synthesize setLike;
@synthesize rarityLike;

@synthesize rarityArray;//, typeArray;

@synthesize setId;

@synthesize colorAny;
@synthesize colorAll;
@synthesize colorExclude;
@synthesize customClause;
@synthesize andCustomClause;

@synthesize formatArray;
@synthesize abilityAny;

@synthesize customOrderBy;

+ (void) load
{
    [NSKeyedUnarchiver setClass: [MTGSmartSearch class]
                   forClassName: @"SmartSearch"];
} // End of load

#pragma mark -
#pragma mark Allocation

- (id) init
{
    if ( ( self = [super init] ) )
    {
		// Set our version cache. If we are init from coder, this will get rewritten with the coder value.
		databaseVersionCache = [AppDelegate databaseVersion];
        self.setId = nil;
    } // End of super init'ed

    return self;
}

+ (MTGSmartSearch*) smartSearchForSetId: (NSInteger) _setId
{
	MTGSmartSearch * smartSearch = [[MTGSmartSearch alloc] init];
	[smartSearch setSetId: [NSNumber numberWithInteger: _setId]];
	
	return smartSearch;
}

+ (MTGSmartSearch*) smartSearchForFormat: (NSString*) formatName
{
	MTGSmartSearch * smartSearch = [[MTGSmartSearch alloc] init];
	[smartSearch setFormatArray: @[formatName]];

	return smartSearch;
}

#pragma mark Searching
#pragma mark -

+ (NSString*) buildSmartSearchClause: (MTGSmartSearch*) smartSearch
{
    if(nil != smartSearch.customClause)
    {
        return smartSearch.customClause;
    }

	// We need to build up our query
	NSMutableString * queryCondition = [[NSMutableString alloc] init];

    if ( nil != smartSearch.nameLike && [smartSearch.nameLike length] > 0 )
	{
        [queryCondition appendFormat: @" card.name LIKE '%%%@%%' AND", [MTGSmartSearch escapeString: smartSearch.nameLike]];
    }

    // Add our type condition
//    [SmartSearch appendTypeCondition: queryCondition forSmartSearch: smartSearch];

	if ( nil != smartSearch.typeLike && [smartSearch.typeLike length] > 0 )
    {
        [queryCondition appendFormat: @" card.type LIKE '%%%@%%' AND", [MTGSmartSearch escapeString: smartSearch.typeLike]];
    }

	if ( nil != smartSearch.descriptionLike && [smartSearch.descriptionLike length] > 0 )
    {
        [queryCondition appendFormat: @" card.text LIKE '%%%@%%' AND", [MTGSmartSearch escapeString: smartSearch.descriptionLike]];
    }

	if ( nil != smartSearch.setLike && [smartSearch.setLike length] > 0 )
    {
        [queryCondition appendFormat: @" cardSet.name LIKE '%%%@%%' AND", [MTGSmartSearch escapeString: smartSearch.setLike]];
    }

    // Add our rarity condition
    [MTGSmartSearch appendRarityCondition: queryCondition
                        forSmartSearch: smartSearch];

    // Add our format conditions
    [MTGSmartSearch appendFormatCondition: queryCondition
                        forSmartSearch: smartSearch];
    
    // Ability
    [MTGSmartSearch appendAbilityAny: queryCondition
                   forSmartSearch: smartSearch];

	if ( nil != smartSearch.artistLike && [smartSearch.artistLike length] > 0 )
    {
        [queryCondition appendFormat: @" card.artist LIKE '%%%@%%' AND", [MTGSmartSearch escapeString: smartSearch.artistLike]];
    }

    if ( nil != smartSearch.setId )
    {
        NSLog( @"Set id: %d", [smartSearch.setId intValue] );
        [queryCondition appendFormat: @" card.cardSetId = %d AND", [smartSearch.setId intValue]];
    }

	NSString * colorAnyCondition =
        [MTGSmartSearch conditionForColor: smartSearch.colorAny
                                  mode: @"OR"
                               include: YES];

	if ( colorAnyCondition )
	{
		[queryCondition appendFormat: @" ( %@ ) AND", colorAnyCondition];
	}

	NSString * colorAllCondition =
        [MTGSmartSearch conditionForColor: smartSearch.colorAll
                                  mode: @"AND"
                               include: YES];

	if ( colorAllCondition )
	{
		[queryCondition appendFormat: @" ( %@ ) AND", colorAllCondition];
	}

	NSString * colorExcludeCondition =
        [MTGSmartSearch conditionForColor: smartSearch.colorExclude
                                  mode: @"AND"
                               include: NO];

	if ( colorExcludeCondition )
	{
		[queryCondition appendFormat: @" ( %@ ) AND", colorExcludeCondition];
	}

    // If we have a condition, then we will need to remove the final AND. Otherwise, we will just set our condition to be
    // 1=1
    if ( [queryCondition length] > 0 )
    {
        // Remove the final and
        [queryCondition replaceCharactersInRange: NSMakeRange ( [queryCondition length] - 4, 4 ) withString: @""];
    }
    else
    {
        [queryCondition appendString: @"1=1"];
    }

    if(smartSearch.andCustomClause.length > 0)
    {
        return [NSString stringWithFormat: @"(%@) AND (%@)",
                          queryCondition,
                          smartSearch.andCustomClause];
    } // End of andCustomClause

    return queryCondition;
}

+ (NSString*) conditionForColor: (int) colorEnum mode: (NSString*) mode include: (BOOL) include
{
	// If we will match ANY of the colors
	if ( 0 != colorEnum )
	{
		NSMutableString * colorCondition = [[NSMutableString alloc] init];
        NSString * includeMethod;
        if(include)
        {
            includeMethod = @"LIKE";
        }
        else
        {
            includeMethod = @"NOT LIKE";
        }
		
		if ( colorEnum & CARD_WHITE )
		{
			[colorCondition appendFormat: @" card.cost %@ '%%W%%' %@", includeMethod, mode];
		}
		if ( colorEnum & CARD_BLUE )
		{
			[colorCondition appendFormat: @" card.cost %@ '%%U%%' %@", includeMethod, mode];
		}
		if ( colorEnum & CARD_BLACK )
		{
			[colorCondition appendFormat: @" card.cost %@ '%%B%%' %@", includeMethod, mode];
		}
		if ( colorEnum & CARD_RED )
		{
			[colorCondition appendFormat: @" card.cost %@ '%%R%%' %@", includeMethod, mode];
		}
		if ( colorEnum & CARD_GREEN )
		{
			[colorCondition appendFormat: @" card.cost %@ '%%G%%' %@", includeMethod, mode];
		}

		if ( [colorCondition length] > 0 )
		{
			// Remove the final ' MODE'
			[colorCondition replaceCharactersInRange: NSMakeRange ( [colorCondition length] - [mode length], [mode length] ) withString: @""];
			return colorCondition;
		}
		else
		{
			NSAssert ( true, @"This should never happen. If a color was set, one of the if statements should of been hit" );
			return nil;
		}
	}

	return nil;
}

+ (NSArray*) searchWithSmartSearch: (MTGSmartSearch*) smartSearch
                             limit: (NSRange) limit
{
    if(0 == smartSearch.customOrderBy.length)
    {
        NSString * searchClause =
            [MTGSmartSearch buildSmartSearchClause: smartSearch];

        return [MTGCard loadCardsWithClause: searchClause
                                      limit: limit];
    }
    else
    {
        NSString * searchClause =
            [MTGSmartSearch buildSmartSearchClause: smartSearch];

        return [MTGCard loadCardsWithClause: searchClause
                                    orderBy: smartSearch.customOrderBy
                                      limit: limit];
    }
}

+ (NSUInteger) countWithSmartSearch: (MTGSmartSearch*) smartSearch
{
    NSUInteger result =
        [MTGCard countCardWithClause: [MTGSmartSearch buildSmartSearchClause: smartSearch]];

    return result;
}

#pragma mark Persistance
#pragma mark -

+ (NSMutableArray*) smartSearchItems
{
	static NSMutableArray * smartSearchItems = nil;

	if ( nil == smartSearchItems )
	{
		smartSearchItems = [[NSMutableArray alloc] init];

		NSUserDefaults *currentDefaults = [NSUserDefaults standardUserDefaults];
		NSData *dataRepresentingSavedArray = [currentDefaults objectForKey: SMART_SEARCH_ITEMS];

		if ( dataRepresentingSavedArray != nil )
		{
			NSArray * loadedArray = [NSKeyedUnarchiver unarchiveObjectWithData:dataRepresentingSavedArray];
			[smartSearchItems addObjectsFromArray: loadedArray];
		}

		// Smart search item
		MTGSmartSearch * smartSearch = nil;

		// If we have no items, then add our defaults
		if ( 0 == [smartSearchItems count] )
		{
			// Add our smart search item
			smartSearch = [[MTGSmartSearch alloc] init];
			smartSearch.searchName = @"All Cards";
			[smartSearch setCachedCount:
             //[SmartSearch countWithSmartSearch: smartSearch]
             17729
             ];
            [smartSearch setDatabaseVersionCache:[AppDelegate databaseVersion]];
			[smartSearchItems addObject: smartSearch];

			smartSearch = [[MTGSmartSearch alloc] init];
			smartSearch.searchName = @"Avatars";
			[smartSearch setNameLike: @"avatar"];
			[smartSearch setCachedCount:
             //[SmartSearch countWithSmartSearch: smartSearch]
             12
             ];
            [smartSearch setDatabaseVersionCache:[AppDelegate databaseVersion]];
			[smartSearchItems addObject: smartSearch];

			smartSearch = [[MTGSmartSearch alloc] init];
			smartSearch.searchName = @"Legendaries";
            [smartSearch setTypeLike: @"Legendary"];
			[smartSearch setCachedCount:
             //[SmartSearch countWithSmartSearch: smartSearch]
             656
             ];
            [smartSearch setDatabaseVersionCache:[AppDelegate databaseVersion]];
			[smartSearchItems addObject: smartSearch];

			smartSearch = [[MTGSmartSearch alloc] init];
			smartSearch.searchName = @"Black Rares";
			[smartSearch setColorAll: CARD_BLACK];
			[smartSearch setRarityArray: [NSArray arrayWithObjects: @"Rare", @"Mythic Rare", nil]];
			[smartSearch setCachedCount:
             904
             //[SmartSearch countWithSmartSearch: smartSearch]
             ];
            [smartSearch setDatabaseVersionCache:[AppDelegate databaseVersion]];
			[smartSearchItems addObject: smartSearch];
		} // End of we have no items
	} // End of not loaded

    return smartSearchItems;
} // End of loadSmartSearchItems

+ (void) saveSmartSearchItems
{
	// Save our smart search objects
	[[NSUserDefaults standardUserDefaults] setObject: [NSKeyedArchiver archivedDataWithRootObject: [MTGSmartSearch smartSearchItems]] forKey: SMART_SEARCH_ITEMS];
}

- (id) initWithCoder: (NSCoder *)coder
{
    self = [super init];
    if ( self )
    {
        self.searchName =       [coder decodeObjectForKey:  @"searchName"];
        self.orderId =          [coder decodeIntegerForKey: @"orderId"];
        self.nameLike =			[coder decodeObjectForKey:  @"nameLike"];
        self.typeLike =			[coder decodeObjectForKey:  @"typeLike"];
		self.descriptionLike =  [coder decodeObjectForKey:  @"descriptionLike"];
		self.artistLike =		[coder decodeObjectForKey:  @"artistLike"];
		self.setLike =			[coder decodeObjectForKey:  @"setLike"];
		self.rarityLike	=		[coder decodeObjectForKey:  @"rarityLike"];

        if ( nil == [coder decodeObjectForKey: @"setId"] )
        {
            self.setId = nil;
        }
        else
        {
            self.setId =        [coder decodeObjectForKey:        @"setId"];
        }

		self.colorAny =             [coder decodeIntForKey:     @"colorAny"];
		self.colorAll =             [coder decodeIntForKey:     @"colorAll"];
		self.colorExclude =			[coder decodeIntForKey:     @"colorExclude"];

		self.databaseVersionCache = [coder decodeIntForKey: @"databaseVersionCache"];
		
		// If the database version has changed, then we will recalculate the count. Otherwise, we will load it
		// from the coder.
		if ( databaseVersionCache < [AppDelegate databaseVersion] )
		{
			// Also update our database version while we are at it.
			databaseVersionCache = [AppDelegate databaseVersion];
			self.cachedCount = [MTGSmartSearch countWithSmartSearch: self];
		}
		else
		{
			self.cachedCount = [coder decodeIntForKey: @"cachedCount"];
		}

        self.rarityArray =      [coder decodeObjectForKey: @"rarityArray"];

        if (
            // If we currently have no rarity array, but we do have a rarityLike then we
            // need to update it so that our array contains the like.
            ( nil == self.rarityArray || 0 == [self.rarityArray count] ) &&
            ( nil != self.rarityLike && [self.rarityLike length] > 0 ) )
        {
            [self setRarityArray: [NSArray arrayWithObjects: self.rarityLike, nil]];
            self.rarityLike = nil;
        } // End of update rarityArray

        // Setup our format array
        self.formatArray =      [coder decodeObjectForKey: @"formatArray"];
        self.abilityAny  =      [coder decodeObjectForKey: @"abilityAny"];

/*
        self.typeArray =        [coder decodeObjectForKey: @"typeArray"];
        if (
            // If we currently have no type array, but we do have a typeLike then we
            // need to update it so that our array contains the like.
            ( nil == self.typeArray || 0 == [self.typeArray count] ) &&
            ( nil != self.typeLike && [self.typeLike length] > 0 ) )
        {
            [self setTypeArray: [NSArray arrayWithObjects: self.typeLike, nil]];
            self.typeLike = nil;
        } // End of update rarityArray
*/
    } // End of init

    return self;
}

- (void) encodeWithCoder: (NSCoder *)coder
{
    [coder encodeObject: searchName     forKey: @"searchName"];
    [coder encodeInteger: orderId       forKey: @"orderId"];

	[coder encodeObject: nameLike       forKey: @"nameLike"];
	[coder encodeObject: typeLike       forKey: @"typeLike"];
	[coder encodeObject: descriptionLike forKey: @"descriptionLike"];
	[coder encodeObject: artistLike     forKey: @"artistLike"];
	[coder encodeObject: setLike        forKey: @"setLike"];
	[coder encodeObject: rarityLike     forKey: @"rarityLike"];

    [coder encodeObject: setId          forKey: @"setId"];

	[coder encodeInt: colorAny          forKey: @"colorAny"];
	[coder encodeInt: colorAll          forKey: @"colorAll"];
	[coder encodeInt: colorExclude      forKey: @"colorExclude"];

	[coder encodeInteger: databaseVersionCache forKey: @"databaseVersionCache"];
	[coder encodeInteger: cachedCount       forKey: @"cachedCount"];

    [coder encodeObject: rarityArray    forKey: @"rarityArray"];
    [coder encodeObject: formatArray    forKey: @"formatArray"];
    [coder encodeObject: abilityAny     forKey: @"abilityAny"];
} // End of encodeWithCoder

- (id) copyWithZone:(NSZone *)zone
{
    MTGSmartSearch * newSearch = [[MTGSmartSearch alloc] init];

    newSearch.searchName = self.searchName;
    newSearch.orderId    = self.orderId;
    newSearch.nameLike   = self.nameLike;
    newSearch.typeLike   = self.typeLike;
    newSearch.descriptionLike = self.descriptionLike;
    newSearch.artistLike = self.artistLike;
    newSearch.setLike    = self.setLike;
    newSearch.rarityLike = self.rarityLike;

    newSearch.setId = self.setId;
    
    newSearch.colorAny = self.colorAny;
    newSearch.colorAll = self.colorAll;
    newSearch.colorExclude = self.colorExclude;

    newSearch.databaseVersionCache = self.databaseVersionCache;
    
    newSearch.rarityArray = [self.rarityArray copyWithZone: zone];

    // Setup our format array
    newSearch.formatArray = [self.formatArray copyWithZone: zone];
    newSearch.abilityAny  = [self.abilityAny copyWithZone: zone];

    return newSearch;
} // End of copyWithZone

+ (NSString*) escapeString: (NSString*) string
{
	return [string stringByReplacingOccurrencesOfString: @"'"
                                             withString: @"''"
                                                options: 0
                                                  range: NSMakeRange(0, [string length])];
}

+ (void) appendRarityCondition: (NSMutableString*) condition
                forSmartSearch: (MTGSmartSearch*) search
{
    // If our rarity array contains nothing, or contains everything, then we have no additional
    // condition needed.
    if ( nil == search.rarityArray || 0 == [search.rarityArray count] )
    {
        return;
    }

    NSString * temp = [NSString stringWithFormat: @" ( card.rarity = '%@' ) AND ", 
            [search.rarityArray componentsJoinedByString: @"' OR card.rarity = '"]];

    [condition appendString: temp];
} // End of appendRarityCondition

+ (void) appendFormatCondition: (NSMutableString*) condition
                forSmartSearch: (MTGSmartSearch*) search
{
    // If our format array contains nothing, or contains everything, then we have no additional
    // condition needed.
    if ( nil == search.formatArray || 0 == [search.formatArray count] )
    {
        return;
    }

    NSString * temp = [NSString stringWithFormat: @" ( format.name = '%@' ) AND ",
                       [search.formatArray componentsJoinedByString: @"' OR format.name = '"]];

    [condition appendString: temp];
} // End of appendFormatCondition


+ (void) appendAbilityAny: (NSMutableString*) condition
           forSmartSearch: (MTGSmartSearch*) search
{
    // If our format array contains nothing, or contains everything, then we have no additional
    // condition needed.
    if ( nil == search.abilityAny || 0 == [search.abilityAny count] )
    {
        return;
    }

    NSMutableArray * abilityArray = [NSMutableArray array];
    for(NSString * ability in search.abilityAny)
    {
        [abilityArray addObject: [NSString stringWithFormat: @"card.text LIKE '%%%@%%'", ability]];
    }

    NSString * temp =
        [NSString stringWithFormat: @" ( %@ ) AND ",
            [abilityArray componentsJoinedByString: @" OR "]];

    [condition appendString: temp];
} // End of appendAbilityAny

/*
+ (void) appendTypeCondition: (NSMutableString*) condition forSmartSearch: (SmartSearch*) search
{
    // If our rarity array contains nothing, or contains everything, then we have no additional
    // condition needed.
    if ( nil == search.typeArray || 0 == [search.typeArray count] )
    {
        return;
    }
    
    NSString * temp = [NSString stringWithFormat: @" ( card.type LIKE '%%%@%%' ) AND ", 
                       [search.typeArray componentsJoinedByString: @"%%' AND card.type LIKE '%%"]];
    
    [condition appendString: temp];
} // End of appendTypeCondition
*/
#pragma mark -

@end
