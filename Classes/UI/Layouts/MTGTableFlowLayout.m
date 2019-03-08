//
//  MTGTableFlowLayout.m
//  MTG Deck Builder
//
//  Created by Kyle Hankinson on 2018-03-15.
//  Copyright © 2018 Hankinsoft Development, Inc. All rights reserved.
//

#import "MTGTableFlowLayout.h"

@implementation MTGTableFlowLayout

#define kItemHeight (100.0f)

- (id) init
{
    self = [super init];
    if(self)
    {
        [self setupLayout];
    }
    
    return self;
}

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
    self.minimumLineSpacing = 0;
    
    [super prepareLayout];
} // End of prepareLayout

- (CGFloat) itemWidth
{
    return self.collectionView.frame.size.width;
}

- (CGSize) itemSize
{
    return CGSizeMake(self.collectionView.frame.size.width,
                      kItemHeight);
}

- (void) setItemSize:(CGSize)itemSize
{
    self.itemSize = CGSizeMake(self.collectionView.frame.size.width,
                               kItemHeight);
}

- (CGPoint) targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset
{
    return self.collectionView.contentOffset;
}

@end

