//
//  CardCollectionViewCell.h
//  MTG Deck Builder
//
//  Created by Kyle Hankinson on 2014-09-22.
//  Copyright (c) 2014 Hankinsoft Development, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CardCollectionViewCell : UICollectionViewCell

- (void) startAnimating;
- (void) stopAnimating: (BOOL) spinnerOnly;

@property(nonatomic,retain) IBOutlet UILabel     * cardNameLabel;
@property(nonatomic,retain) IBOutlet UIImageView * cardImageView;

@end
