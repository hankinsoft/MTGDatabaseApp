//
//  MTGLifeCounterGlobalCollectionViewCell.h
//  MTG Deck Builder
//
//  Created by kylehankinson on 2018-08-17.
//  Copyright © 2018 Hankinsoft Development, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol MTGLifeCounterGlobalCollectionViewCell <NSObject>

- (void) mtgLifeCounterGlobalDamage: (NSInteger) damage;

@end

@interface MTGLifeCounterGlobalCollectionViewCell : UICollectionViewCell

@property(nonatomic,weak) id<MTGLifeCounterGlobalCollectionViewCell> delegate;

@end

NS_ASSUME_NONNULL_END
