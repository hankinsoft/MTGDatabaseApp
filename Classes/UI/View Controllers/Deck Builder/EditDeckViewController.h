//
//  EditDeckViewController.h
//  MTG Deck Builder
//
//  Created by Kyle Hankinson on 11-10-02.
//  Copyright (c) 2011 Hankinsoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Deck.h"
#import "DeckCardModifierCell.h"

@interface EditDeckViewController : UIViewController<UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, DeckCardModifierCellDelegate>
{
    IBOutlet UITableView * tableView;
	NSDictionary	* editCells;

    Deck            * deck;

    UITextField     * selectedTextField;

    // Keyboard
    unsigned int    maxTag;
    unsigned int    keyboardHeight;
    BOOL            keyboardIsShowing;
} // End of EditDeckViewController

@property(nonatomic,retain) Deck * deck;

@end
