//
//  CardViewController.h
//  MTG Deck Builder
//
//  Created by Kyle Hankinson on 10-06-21.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GHRootViewController.h"

@class MTGCard;

@interface CardDetailsViewController : ShakeToRootViewController <UIWebViewDelegate, UIPopoverControllerDelegate>
{
	UIPopoverController         * popoverController;

	MTGCard				* card;

	UIWebView			* cardDescriptionWebView;
	UIWebView			* costWebView;
	UIWebView			* cardFlavorTextWebView;
    IBOutlet UIWebView  * pricesWebView;

    IBOutlet UILabel    * cardConvertedManaCostLabel;

    IBOutlet UIView         * containerView;
@private
	RevealBlock _revealBlock;
}

- (void) configureRevealBlock:(RevealBlock)revealBlock;

@property (nonatomic, retain) MTGCard * card;

@end
