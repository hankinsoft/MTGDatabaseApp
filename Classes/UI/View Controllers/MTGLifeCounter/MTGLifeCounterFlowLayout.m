//
//  MTGLifeCounterFlowLayout.m
//  MTG Deck Builder
//
//  Created by kylehankinson on 2018-08-14.
//  Copyright © 2018 Hankinsoft Development, Inc. All rights reserved.
//

#import "MTGLifeCounterFlowLayout.h"

@implementation MTGLifeCounterFlowLayout
{
    BOOL showsPoison;
    BOOL commanderEnabled;
}

- (id) init
{
    self = [super init];
    if(self)
    {
        [self setupLayout];
    }
    
    return self;
}

- (CGFloat) calculateHeight
{
    CGFloat height = 140.0; // Base height

    if(showsPoison)
    {
        height += 45.0;
    } // End of showsPoison

    if(commanderEnabled)
    {
        height += 45.0;
    }

    return height;
} // End of calculateHeight

- (id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder: aDecoder];
    if(self)
    {
        [self setupLayout];
    }
    
    return self;
}

- (void) setupLayout
{
    self.minimumInteritemSpacing = 0;
    self.minimumLineSpacing      = 0;
    self.scrollDirection = UICollectionViewScrollDirectionVertical;
} // End of setupLayout

- (void) prepareLayout
{
    [super setItemSize: [self itemSize]];
    [super setSectionInset: [self sectionInset]];
    self.minimumLineSpacing = [self minimumLineSpacing];
    
    [super prepareLayout];
} // End of prepareLayout

- (CGFloat) minimumLineSpacing
{
    return 20.0f;
}

- (UIEdgeInsets) sectionInset
{
    return UIEdgeInsetsMake(20, 0, 0, 0);
}

- (CGFloat) itemWidth
{
    return self.collectionView.frame.size.width - 60;
}

- (CGSize) itemSize
{
    return CGSizeMake(self.itemWidth, [self calculateHeight]);
}

- (void) setItemSize:(CGSize)itemSize
{
    self.itemSize = CGSizeMake(self.itemWidth,
                               [self calculateHeight]);
}

- (CGPoint) targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset
{
    return self.collectionView.contentOffset;
}

- (void) setShowsPoison: (BOOL) _showsPoison
       commanderEnabled: (BOOL) _commanderEnabled;
{
    showsPoison = _showsPoison;
    commanderEnabled = _commanderEnabled;
}

@end
