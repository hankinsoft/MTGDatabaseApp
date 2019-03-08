//
//  MTGEditSmartSearchViewController.h
//  MTG Deck Builder
//
//  Created by Kyle Hankinson on 10-08-06.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MTGSmartSearch;

@interface MTGEditSmartSearchViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>
{
    UITableView     * tableView;
    MTGSmartSearch     * smartSearch;

	NSDictionary	* editCells;

    UITextField     * selectedTextField;

    // Keyboard
    unsigned int    maxTag;
    unsigned int    keyboardHeight;
    BOOL            keyboardIsShowing;
}

@property (nonatomic, retain) IBOutlet UITableView * tableView;
@property (nonatomic, retain) MTGSmartSearch * smartSearch;

@end
