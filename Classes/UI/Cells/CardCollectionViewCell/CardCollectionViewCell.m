//
//  CardCollectionViewCell.m
//  MTG Deck Builder
//
//  Created by Kyle Hankinson on 2014-09-22.
//  Copyright (c) 2014 Hankinsoft Development, Inc. All rights reserved.
//

#import "CardCollectionViewCell.h"

@implementation CardCollectionViewCell
{
    IBOutlet UIActivityIndicatorView         * loadingActivityIndicatorView;
}

@synthesize cardImageView, cardNameLabel;

- (void) stopAnimating: (BOOL) spinnerOnly
{
    [loadingActivityIndicatorView stopAnimating];
    
    if(!spinnerOnly)
    {
        [cardNameLabel setHidden: YES];
    }
} // End of stopAnimating

- (void) startAnimating
{
    [loadingActivityIndicatorView startAnimating];
    [cardNameLabel setHidden: NO];
}

- (void) awakeFromNib
{
    [super awakeFromNib];

    self.contentView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.contentView.translatesAutoresizingMaskIntoConstraints = YES;
} // End of awakeFromNib

@end
