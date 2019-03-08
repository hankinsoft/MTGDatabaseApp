//
//  CardSet.h
//  Pokemon Trading Cards (TCG) List
//
//  Created by Kyle Hankinson on 10-06-06.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface MTGCardSet : NSObject
{
}

@property (nonatomic, assign) NSInteger	setId;
@property (nonatomic, retain) NSString	* name;
@property (nonatomic, retain) NSString  * shortName;
@property (nonatomic, assign) NSInteger	cardCount;
@property (nonatomic, copy)   NSDate	* releaseDate;
@property (nonatomic, copy)   NSString	* block;
@property (nonatomic, copy)   NSString  * type;

+ (NSArray*) allCardSets;
+ (MTGCardSet*) cardSetById: (NSUInteger) cardSetId;

@end
