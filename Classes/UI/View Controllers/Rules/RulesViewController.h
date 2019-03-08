//
//  RulesViewController.h
//  MTG Deck Builder
//
//  Created by Kyle Hankinson on 12-06-01.
//  Copyright (c) 2012 Hankinsoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GHRootViewController.h"
@class MTGRules;

@interface RulesViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>
{
    IBOutlet UITableView * tableView;
    NSArray * rules;
@private
	RevealBlock _revealBlock;
}

- (id)initWithRevealBlock:(RevealBlock)revealBlock;

@end
