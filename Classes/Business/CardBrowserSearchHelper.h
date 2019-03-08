//
//  CardBrowserSearchHelper.h
//  MTG Deck Builder
//
//  Created by Kyle Hankinson on 2014-09-22.
//  Copyright (c) 2014 Hankinsoft Development, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
@class MTGSmartSearch;
@protocol CardBrowserSearchHelper <NSObject>

- (void) finishedSearchingWithCards: (NSArray*) cards
                       hasMoreCards: (BOOL) hasMoreCards;

@end

@interface CardBrowserSearchHelper : NSObject

- (void) cancel;
- (void) beginSearchWithSmartSearch: (MTGSmartSearch*) smartSearch;

@property(nonatomic,retain) id<CardBrowserSearchHelper> delegate;

@end
