//
//  DeckBuilderViewController.h
//  MTG Deck Builder
//
//  Created by Kyle Hankinson on 11-10-02.
//  Copyright (c) 2011 Hankinsoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GHRootViewController.h"

@interface DeckBuilderViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>
{
    IBOutlet UITableView            * tableView;
	IBOutlet UIBarButtonItem		* addButton;
    IBOutlet UIBarButtonItem        * editButton;
@private
	RevealBlock _revealBlock;
}

- (id)initWithRevealBlock:(RevealBlock)revealBlock;

@end
