//
//  MTGLifeCounterEDHCollectionViewCell.h
//  MTG Deck Builder
//
//  Created by kylehankinson on 2018-08-17.
//  Copyright © 2018 Hankinsoft Development, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol MTGLifeCounterEDHCollectionViewCellDelegate <NSObject>

- (void) addCommaderDamageForIndexPath: (NSIndexPath*) indexPath;
- (void) removeCommaderDamageForIndexPath: (NSIndexPath*) indexPath;

@end

@interface MTGLifeCounterEDHCollectionViewCell : UICollectionViewCell

- (void) setDamage: (NSInteger) damage
             title: (NSString*) title
         indexPath: (NSIndexPath*) indexPath;

@property(nonatomic,weak) id<MTGLifeCounterEDHCollectionViewCellDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
