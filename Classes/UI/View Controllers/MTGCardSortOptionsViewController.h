//
//  MTGCardSortOptionsViewController.h
//  MTG Deck Builder
//
//  Created by Kyle Hankinson on 11-07-14.
//  Copyright 2011 Hankinsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum MTGSortMode
{
    MTGSortModeAscending = 0,
    MTGSortModeDescending = 1,
} MTGSortMode;

typedef enum MTGSortBy
{
    MTGSortByName                   = 0,
    MTGSortByCollectorsNumber       = 1,
    MTGSortByConvertedManaCost      = 2,
    MTGSortByPrice                  = 3,
    MTGSortByRarity                 = 4,
    MTGSortByPower                  = 5,
    MTGSortByToughness              = 6
} MTGSortBy;

@protocol CardSortOptionsProtocol

- (void) sortingChanged;
- (void) scrollingChanged;

@end

@interface MTGCardSortOptionsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
{
	id<CardSortOptionsProtocol> delegate;
}

+ (NSDictionary*) sortDictionary;
+ (MTGSortMode) sortMode;
+ (MTGSortBy) sortBy;

@property (nonatomic, retain) id<CardSortOptionsProtocol> delegate;

@end
