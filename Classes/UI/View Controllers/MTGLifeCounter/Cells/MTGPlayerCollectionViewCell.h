//
//  MTGPlayerCollectionViewCell.h
//  MTG Deck Builder
//
//  Created by kylehankinson on 2018-08-14.
//  Copyright © 2018 Hankinsoft Development, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MTGPlayer;
@class MTGPlayerCollectionViewCell;

@protocol MTGPlayerCollectionViewCellDelegate<NSObject>

- (void) playerCollectionViewCell: (MTGPlayerCollectionViewCell*) cell
                wantsEDHForPlayer: (MTGPlayer*) player;

@end

@interface MTGPlayerCollectionViewCell : UICollectionViewCell

- (void) setPlayer: (MTGPlayer*) mtgPlayer;

- (void) willDisplayWithPoison: (BOOL) withPoison
                    edhEnabled: (BOOL) edhEnabled;

@property(nonatomic,weak) id<MTGPlayerCollectionViewCellDelegate> delegate;

@end
