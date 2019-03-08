//
//  MTGLargeGridFlowLayout.m
//  MTG Deck Builder
//
//  Created by Kyle Hankinson on 2018-03-21.
//  Copyright © 2018 Hankinsoft Development, Inc. All rights reserved.
//

#import "MTGLargeGridFlowLayout.h"

@implementation MTGLargeGridFlowLayout

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
    self.minimumInteritemSpacing = 1;
    self.scrollDirection = UICollectionViewScrollDirectionVertical;
} // End of setupLayout

- (void) prepareLayout
{
    [super prepareLayout];
    [super setSectionInset: [self sectionInset]];
    
    self.minimumLineSpacing = 7.5;
} // End of prepareLayout

- (CGFloat) calculateWidth
{
    CGFloat newWidth = self.collectionView.frame.size.width - 40;
    return newWidth;
} // End of calcualteWidth

- (CGFloat) calculateHeight
{
    CGFloat requiredWith = [self calculateWidth];
    CGFloat multiplier = requiredWith / 155;

    CGFloat calculatedHeight = 220 * multiplier;

    return calculatedHeight;
} // End of calculateHeight

- (CGSize) itemSize
{
    return CGSizeMake(self.calculateWidth, self.calculateHeight);
}

- (void) setItemSize:(CGSize)itemSize
{
    super.itemSize = CGSizeMake(self.calculateWidth, self.calculateHeight);
}

- (UIEdgeInsets) sectionInset
{
    CGFloat cellWidth =
    //((UICollectionViewFlowLayout *) collectionViewLayout).itemSize.width;
        self.calculateWidth + self.minimumInteritemSpacing;

    NSInteger numberOfCells =
        self.collectionView.frame.size.width / (cellWidth);

    CGFloat edgeInsets =
        (self.collectionView.frame.size.width - (numberOfCells * cellWidth)) / (numberOfCells + 1);

    if(edgeInsets < 1 && numberOfCells > 1)
    {
        --numberOfCells;
        edgeInsets =
            (self.collectionView.frame.size.width - (numberOfCells * cellWidth)) / (numberOfCells + 1);
    }

    UIEdgeInsets result = UIEdgeInsetsMake(10, edgeInsets, 0, edgeInsets);

    return result;
}

- (void) setSectionInset: (UIEdgeInsets) sectionInset
{
    super.sectionInset = [self sectionInset];
}

@end
