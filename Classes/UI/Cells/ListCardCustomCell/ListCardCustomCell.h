//
//  FirstViewCustomCell.h
//  Scandit
//
//  Created by Chaman Sharma on 08/01/13.
//  Copyright (c) 2013 umar chhipa. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MTGCard;

@interface ListCardCustomCell : UICollectionViewCell
{
}

- (void) startAnimating;
- (void) stopAnimating: (BOOL) spinnerOnly;
- (void) populateWithCard: (MTGCard*) mtgCard
                indexPath: (NSIndexPath*) indexPath;

@property(nonatomic,retain)IBOutlet UILabel  * cardCollectorsNumberLabel;

@property(nonatomic,retain)IBOutlet UIImageView * cardImageView;
@property(nonatomic,retain)IBOutlet UIImageView * setImageView;;
@property(nonatomic,retain)IBOutlet UIView *dragView;

@property(nonatomic,retain)IBOutlet UILabel   * cardNameLabel;
@property(nonatomic,retain)IBOutlet UILabel   * typeLabel;
@property(nonatomic,retain)IBOutlet UILabel   * rulesLabel;
@property(nonatomic,retain)IBOutlet UILabel   * lowPriceLabel;
@property(nonatomic,retain)IBOutlet UILabel   * mediumPriceLabel;
@property(nonatomic,retain)IBOutlet UILabel   * highPriceLabel;

@end
