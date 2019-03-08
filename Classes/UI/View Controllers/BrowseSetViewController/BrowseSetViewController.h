//
//  BrowseSetViewController.h
//  MTG Deck Builder
//
//  Created by Kyle Hankinson on 10-08-04.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CardGridViewController.h"
#import "GHRootViewController.h"

@class MTGCardSet;

@interface BrowseSetViewController : ShakeToRootViewController <UITableViewDelegate, UITableViewDataSource>
{
	IBOutlet UITableView	* tableView;

	NSArray					* cardSets;
	MTGCardSet					* selectedCardSet;
    NSArray					* cardSetCellCache;

	// Search stuff
	NSMutableArray			* searchResultCells;
	NSMutableArray			* searchResultSets;
@private
	
}

- (id)initWithRevealBlock: (RevealBlock) revealBlock;

@end
