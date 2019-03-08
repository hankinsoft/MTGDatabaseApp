//
//  SmartSearch.h
//  MTG Deck Builder
//
//  Created by Kyle Hankinson on 10-08-06.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Deck;

@interface MTGSmartSearch : NSObject<NSCopying>
{
    NSInteger       orderId;
    NSString        * searchName;

	// Used for caching card counts
	NSInteger		databaseVersionCache;
    NSInteger       cachedCount;

    // Clauses
    NSString		* nameLike;
    NSString		* typeLike;
	NSString		* descriptionLike;
	NSString		* artistLike;
	NSString		* setLike;
	NSString		* rarityLike;

    // Array Clauses
    NSArray         * rarityArray;
//    NSArray         * typeArray;

    NSNumber        * setId;

	int				colorAny;
	int				colorAll;
	int				colorExclude;

    Deck            * deck;
}

+ (NSMutableArray*) smartSearchItems;
+ (void) saveSmartSearchItems;
+ (NSArray*) searchWithSmartSearch: (MTGSmartSearch*) smartSearch
                             limit: (NSRange) limit;
+ (NSUInteger) countWithSmartSearch: (MTGSmartSearch*) smartSearch;
+ (MTGSmartSearch*) smartSearchForSetId: (NSInteger) setId;
+ (MTGSmartSearch*) smartSearchForFormat: (NSString*) formatName;
+ (NSString*) escapeString: (NSString*) string;

@property (nonatomic, assign) NSInteger orderId;
@property (nonatomic, retain) NSString  * searchName;
@property (nonatomic, assign) NSInteger cachedCount;

@property (nonatomic, retain) NSString  * nameLike;
@property (nonatomic, retain) NSString  * typeLike;
@property (nonatomic, retain) NSString  * descriptionLike;
@property (nonatomic, retain) NSString  * artistLike;
@property (nonatomic, retain) NSString  * setLike;
@property (nonatomic, retain) NSString  * rarityLike;
@property (nonatomic, retain) NSString  * customClause;
@property (nonatomic, retain) NSString  * andCustomClause;

@property (nonatomic, copy)   NSString * customOrderBy;

// Array clauses
@property (nonatomic, retain) NSArray   * rarityArray;
//@property (nonatomic, retain) NSArray   * typeArray;

@property (nonatomic, retain) NSNumber  * setId;

@property (nonatomic, assign) int		colorAny;
@property (nonatomic, assign) int		colorAll;
@property (nonatomic, assign) int		colorExclude;

@property (nonatomic, retain) NSArray   * formatArray;

@property (nonatomic, retain) NSArray   * abilityAny;

@end
