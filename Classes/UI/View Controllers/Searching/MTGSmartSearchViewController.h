//
//  SearchViewController.h
//  MTG Deck Builder
//
//  Created by Kyle Hankinson on 10-06-20.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CardGridViewController.h"
#import "MTGEditSmartSearchViewController.h"

#import "GHRootViewController.h"

@class SearchHelper;
@class MTGSmartSearch;

@interface MTGSmartSearchViewController : UIViewController <UITableViewDelegate, UITableViewDataSource,UIPopoverControllerDelegate>
{
	SearchHelper					* searchHelper;

    UITableView                     * tableView;
	IBOutlet UIBarButtonItem		* addButton;
    IBOutlet UIBarButtonItem        * editButton;

    MTGSmartSearch                     * selectedSmartSearch;
@private
	RevealBlock _revealBlock;
}

- (id)initWithRevealBlock:(RevealBlock)revealBlock;

- (IBAction) onEdit: (id) sender;
- (IBAction) onAdd: (id) sender;

@property (nonatomic, retain) IBOutlet UITableView              * tableView;

@end
