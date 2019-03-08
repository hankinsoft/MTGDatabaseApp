//
//  MTGLifeCounterEDHCollectionViewCell.m
//  MTG Deck Builder
//
//  Created by kylehankinson on 2018-08-17.
//  Copyright © 2018 Hankinsoft Development, Inc. All rights reserved.
//

#import "MTGLifeCounterEDHCollectionViewCell.h"
#import "SQLProAppearanceManager.h"

@interface MTGLifeCounterEDHCollectionViewCell()

@property(nonatomic,retain) IBOutlet UILabel * damageLabel;
@property(nonatomic,retain) IBOutlet UILabel * titleLabel;

@end

@implementation MTGLifeCounterEDHCollectionViewCell
{
    NSIndexPath * indexPath;
}

- (void) awakeFromNib
{
    [super awakeFromNib];
} // End of awakeFromNib

- (void) setDamage: (NSInteger) damage
             title: (NSString*) title
         indexPath: (NSIndexPath*) _indexPath
{
    self.damageLabel.text = [NSString stringWithFormat: @"%ld", (long)damage];
    self.titleLabel.text = title;
    indexPath = _indexPath;
} // End of setDamage:title:indexPath:

- (IBAction) onAddCommangerDamage: (id) sender
{
    [self.delegate addCommaderDamageForIndexPath: indexPath];
} // End of onAddCommangerDamage:

- (IBAction) onRemoveCommangerDamage: (id) sender
{
    [self.delegate removeCommaderDamageForIndexPath: indexPath];
} // End of onRemoveCommangerDamage:

@end
