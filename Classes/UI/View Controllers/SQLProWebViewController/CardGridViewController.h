//
//  DetailViewController.h
//  MTG Deck Builder
//
//  Created by Kyle Hankinson on 10-06-15.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MTGCardSortOptionsViewController.h"
#import "GHRootViewController.h"

@class UICard;
@class MTGSmartSearch;
@class MBProgressHUD;

@interface CardGridViewController : ShakeToRootViewController <UIPopoverControllerDelegate, 													CardSortOptionsProtocol, UISearchBarDelegate>
{
}

- (id) initWithRevealBlock: (RevealBlock) revealBlock;

@property (nonatomic, retain) MTGSmartSearch           * smartSearch;

@end
