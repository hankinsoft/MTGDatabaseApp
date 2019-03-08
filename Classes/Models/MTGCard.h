//
//  Card.h
//  Pokemon Trading Cards (TCG) List
//
//  Created by Kyle Hankinson on 10-06-10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

enum ColorEnum
{
	CARD_WHITE		=	0x0001,
	CARD_BLUE		=	0x0002,
	CARD_BLACK		=	0x0004,
	CARD_RED		=	0x0008,
	CARD_GREEN		=	0x0010
};

@interface MTGCard : NSObject
{
}

+ (MTGCard*) cardWithMultiverseId: (NSInteger) multiverseId;

+ (NSArray*) loadCardsWithClause: (NSString*) clause
                           limit: (NSRange) limit;

+ (NSArray*) loadCardsWithClause: (NSString*) clause
                         orderBy: (NSString*) orderBy
                           limit: (NSRange) limit;;

+ (NSArray*) listOfMultiverseIds;
+ (NSUInteger) countCardWithClause: (NSString*) clause;

- (id) initWithMultiverseId: (NSInteger) multiverseId
                       name: (NSString*) name;

- (NSAttributedString*) castingCostAttributedString;
- (NSAttributedString*) rulesAttributedString;

@property (nonatomic, assign) NSInteger multiverseId;
@property (nonatomic, assign) NSInteger cardSetId;
@property (nonatomic, retain) NSString	* name;
@property (nonatomic, retain) UIImage	* image;

// Details
@property (nonatomic, retain) NSString * cost;
@property (nonatomic, retain) NSString * color;
@property (nonatomic, retain) NSString * rarity;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSString * description;
@property (nonatomic, assign) NSUInteger artistId;
@property (nonatomic, retain) NSString * flavorText;
@property (nonatomic, assign) NSInteger convertedManaCost;
@property (nonatomic, retain) NSNumber * collectorsNumber;

@property (nonatomic, copy)   NSNumber * power;
@property (nonatomic, copy)   NSNumber * toughness;

@end
