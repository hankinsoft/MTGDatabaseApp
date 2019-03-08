//
//  MTGGridFlowLayout.m
//  MTG Deck Builder
//
//  Created by Kyle Hankinson on 2018-03-09.
//  Copyright © 2018 Hankinsoft Development, Inc. All rights reserved.
//

#import "MTGGridFlowLayout.h"

@implementation MTGGridFlowLayout

static CGFloat kCellWidth = 0;
static CGFloat kCellHeight = 0;

+ (void) initialize
{
    if([AppDelegate isIPad])
    {
        kCellWidth = 155;
        kCellHeight = 220;
    }
    else
    {
        kCellWidth = 155;
        kCellHeight = 220;
    }
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

- (CGSize) itemSize
{
    return CGSizeMake(kCellWidth, kCellHeight);
}

- (void) setItemSize:(CGSize)itemSize
{
    super.itemSize = CGSizeMake(kCellWidth, kCellHeight);
}

- (UIEdgeInsets) sectionInset
{
    CGFloat cellWidth =
    //((UICollectionViewFlowLayout *) collectionViewLayout).itemSize.width;
        kCellWidth + self.minimumInteritemSpacing;

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

