//
//  DeckCard.h
//  MTG Deck Builder
//
//  Created by Kyle Hankinson on 11-10-02.
//  Copyright (c) 2011 Hankinsoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MTGCardInDeck : NSObject
{
    NSInteger   multiverseId;
    NSInteger   count;
}

@property(nonatomic,assign) NSInteger multiverseId;
@property(nonatomic,assign) NSInteger count;

@end
