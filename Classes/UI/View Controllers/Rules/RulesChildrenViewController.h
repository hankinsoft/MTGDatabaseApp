//
//  RulesChildrenViewController.h
//  MTG Deck Builder
//
//  Created by Kyle Hankinson on 12-06-04.
//  Copyright (c) 2012 Hankinsoft. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Children;

@interface RulesChildrenViewController : ShakeToRootViewController<UITableViewDataSource, UITableViewDelegate>
{
    IBOutlet UITableView * tableView;
    
    NSArray * cellArray;
}

@property(nonatomic,retain) Children * children;

@end
