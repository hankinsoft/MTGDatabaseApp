//
//  BrowseFormatViewController.h
//  MTG Deck Builder
//
//  Created by Kyle Hankinson on 2013-05-29.
//
//

#import <UIKit/UIKit.h>
#import "GHRootViewController.h"

@interface BrowseFormatViewController : ShakeToRootViewController
{
@private
	RevealBlock _revealBlock;
}

- (id)initWithRevealBlock:(RevealBlock)revealBlock;
- (void) loadFormats;

@end
