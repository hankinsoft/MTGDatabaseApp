//
//  DeckCardModifierCell.h
//  MTG Deck Builder
//
//  Created by Kyle Hankinson on 12-05-26.
//  Copyright (c) 2012 Hankinsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DeckCardModifierCell;

@protocol DeckCardModifierCellDelegate <NSObject>
@required

- (void) deckCardModifierIncrease: (DeckCardModifierCell*) sender;
- (void) deckCardModifierDecreased: (DeckCardModifierCell*) sender;

@end

@interface DeckCardModifierCell : UITableViewCell

@property(nonatomic, retain) id<DeckCardModifierCellDelegate> delegate;
@property(nonatomic, assign) NSInteger multiverseId;

@end
