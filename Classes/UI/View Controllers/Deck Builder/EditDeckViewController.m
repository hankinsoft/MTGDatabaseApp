    //
//  EditDeckViewController.m
//  MTG Deck Builder
//
//  Created by Kyle Hankinson on 11-10-02.
//  Copyright (c) 2011 Hankinsoft. All rights reserved.
//

#import "EditDeckViewController.h"
#import "AppDelegate.h"
#import "MTGTextFieldTableViewCell.h"
#import "CardDetailsViewController.h"

#import "Deck.h"
#import "MTGCardInDeck.h"
#import "MTGCard.h"

@interface EditDeckViewController()

- (void) createCells;
- (void) textFieldDidBeginEditing:(UITextField *)textField;

- (UITableViewCell*) createTextFieldCell: (NSString* ) labelText currentValue: (NSString*) currentValue placeHolder: (NSString*) placeHolder withTag: (int) tag;
- (NSString*) stringForTextField: (NSString*) field inSection: (NSString*) section;

@end

@implementation EditDeckViewController

#define				SECTION_GENERAL                 @"General"
#define				SECTION_GENERAL_NAME            @"Name"

#define				SECTION_DETAILS                 @"Details"
#define             SECTION_DETAILS_INDEX           1

#define				SECTION_CARDS                   @"Cards"
#define             SECTION_CARDS_INDEX             2

@synthesize deck;

static NSString * CellIdentifier = @"EditDeckCellIdentifier";

- (id) init
{
    self = [super initWithNibName: @"EditDeckViewController"
                           bundle: nil];
    if(self)
    {
    }
    
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void) viewDidLoad
{
    [super viewDidLoad];
	[self setTitle: @"Edit Collection"];
    self.navigationController.navigationBar.barStyle = [AppDelegate barButtonStyle];

    UIBarButtonItem * saveBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStylePlain target:self action:@selector(onSave:)];
    self.navigationItem.rightBarButtonItem = saveBarButtonItem;

	// Create our cells
	[self createCells];

    // Keyboard handling
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(keyboardWillShow:)
                                                 name: UIKeyboardWillShowNotification
                                               object: nil];
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(keyboardWillHide:)
                                                 name: UIKeyboardWillHideNotification
                                               object: nil];
    
    keyboardHeight = 0;
    keyboardIsShowing = NO;
} // End of viewDidLoad

- (void) viewWillAppear:(BOOL)animated
{
	// Canceling
	self.navigationItem.backBarButtonItem.title = @"Cancel";
	[super viewWillAppear: animated];
}

#pragma mark -
#pragma mark Keyboard Handling

-(void) keyboardWillShow:(NSNotification *)note
{
    CGRect keyboardBounds;
    [[note.userInfo valueForKey:UIKeyboardBoundsUserInfoKey] getValue: &keyboardBounds];
    keyboardHeight = keyboardBounds.size.height;
    
    if (keyboardIsShowing == NO)
    {
        keyboardIsShowing = YES;
        CGRect frame = self.view.frame;
        frame.size.height -= keyboardHeight;
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationDuration:0.3f];
        self.view.frame = frame;
        [UIView commitAnimations];
        
        [self textFieldDidBeginEditing: selectedTextField];
    }
}

-(void) keyboardWillHide:(NSNotification *)note
{
    if ( keyboardIsShowing )
    {
        // Keyboard is no longer showing
        keyboardIsShowing = NO;
        
        CGRect frame = self.view.frame;
        frame.size.height += keyboardHeight;
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationDuration:0.3f];
        self.view.frame = frame;
        [UIView commitAnimations];
    }
} // End of keyboardWillHide

- (void) textFieldDidBeginEditing:(UITextField *)textField
{
    NSLog( @"Textfield did begin editing" );
    selectedTextField = textField;
    UITableViewCell *cell = (UITableViewCell*) [[textField superview] superview];
    [tableView scrollToRowAtIndexPath: [tableView indexPathForCell:cell] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
}

- (BOOL) textFieldShouldReturn:(UITextField *)aTextField
{
    NSLog( @"Textfield should return called" );
    
    if ( aTextField.tag + 1 < maxTag )
    {
        UITextField * target = (UITextField*)[tableView viewWithTag: aTextField.tag + 1];
		[target becomeFirstResponder];
        
        return NO;
    }
    else
    {
        [aTextField resignFirstResponder];
        return YES;
    }
} // End of textFieldShouldReturn

- (void) createCells
{
	NSMutableDictionary * _editDictionary = [[NSMutableDictionary alloc] init];
	
	// Create our deck cells
	NSMutableArray * _deckCells = [[NSMutableArray alloc] init];
    
	UITableViewCell * cell;
    
    int textFieldTag = 0;

	// Deck Name
    cell = [self createTextFieldCell: SECTION_GENERAL_NAME
                        currentValue: deck.deckName
                         placeHolder: @""
                             withTag: textFieldTag++];

	[_deckCells addObject: cell];

	[_editDictionary setObject: _deckCells forKey: SECTION_GENERAL];

    // Set our details cells
    _deckCells = [[NSMutableArray alloc] init];

    cell = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleValue1 reuseIdentifier:@"ABC"];
    cell.textLabel.text = @"Estimated Value";
    cell.detailTextLabel.text = @"$9.99";
    cell.detailTextLabel.textColor = [[UIColor whiteColor] colorWithAlphaComponent: 0.60];
	[_deckCells addObject: cell];

    cell = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleValue1 reuseIdentifier:@"ABC"];
    cell.textLabel.text = @"Total Lands";
    cell.detailTextLabel.text = @"15";
    cell.detailTextLabel.textColor = [[UIColor whiteColor] colorWithAlphaComponent: 0.60];
	[_deckCells addObject: cell];

    cell = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleValue1 reuseIdentifier:@"ABC"];
    cell.textLabel.text = @"Total Mana Cost";
    cell.detailTextLabel.text = @"15";
    cell.detailTextLabel.textColor = [[UIColor whiteColor] colorWithAlphaComponent: 0.60];
	[_deckCells addObject: cell];

	[_editDictionary setObject: _deckCells forKey: SECTION_DETAILS];
    // End of deck cells

    editCells = [NSMutableDictionary dictionaryWithDictionary: _editDictionary];

    // Set our maxTag
    maxTag = textFieldTag;
}

#pragma mark Table view data source

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	if ( 0 == section )
	{
		return SECTION_GENERAL;
	}
    else if ( 1 == section )
    {
        return SECTION_DETAILS;
    }
    else if ( 2 == section)
    {
        return [NSString stringWithFormat: @"%lu Card%@", (unsigned long)[deck countOfCards], 1 == [deck countOfCards] ? @"" : @"s"];
    } // End of section
    
    return @"";
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView
{
    // Return the number of sections.
    return 3;
}

- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section
{
    if(section != SECTION_CARDS_INDEX)
    {
        NSString * key = [self tableView:aTableView titleForHeaderInSection:section];
        NSArray * cells = [editCells objectForKey: key];
	
        return [cells count];
    }
    else
    {
        return deck.cards.count;
    }
}


- (UITableViewCell *)tableView:(UITableView *)aTableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section != SECTION_CARDS_INDEX && indexPath.section != SECTION_DETAILS_INDEX )
    {
        NSString * key = [self tableView:aTableView titleForHeaderInSection:indexPath.section];
        NSArray * cells = [editCells objectForKey: key];

        return [cells objectAtIndex: indexPath.row];
    } // End of anything but cards
    else if(indexPath.section == SECTION_DETAILS_INDEX)
    {
        NSString * key = [self tableView:aTableView titleForHeaderInSection:indexPath.section];
        NSArray * cells = [editCells objectForKey: key];

        UITableViewCell * cell = [cells objectAtIndex: indexPath.row];
        if([cell.textLabel.text isEqualToString: @"Estimated Value"])
        {
            // alloc formatter
            NSNumberFormatter *currencyStyle = [[NSNumberFormatter alloc] init];
            
            // set options.
            [currencyStyle setFormatterBehavior:NSNumberFormatterBehavior10_4];
            [currencyStyle setNumberStyle:NSNumberFormatterCurrencyStyle];
            cell.detailTextLabel.text = [currencyStyle stringFromNumber: [NSNumber numberWithDouble: [deck priceForDeck]]];
        } // End of price
        else if([cell.textLabel.text isEqualToString: @"Total Lands"])
        {
            cell.detailTextLabel.text = [NSString stringWithFormat: @"%d", [deck landsInDeck]];
        } // End of Total Lands
        else if([cell.textLabel.text isEqualToString: @"Total Mana Cost"])
        {
            cell.detailTextLabel.text = [NSString stringWithFormat: @"%lu", (unsigned long)[deck totalMana]];
        }
        return cell;
    } // End of 
    // Our cards
    else if(indexPath.section == SECTION_CARDS_INDEX)
    {
        static NSString *CellIdentifier = @"DeckCard";
        
        DeckCardModifierCell * cell = [aTableView dequeueReusableCellWithIdentifier: CellIdentifier];
        if(nil == cell)
        {
            cell = [[DeckCardModifierCell alloc] initWithStyle: UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
            cell.delegate = self;
        }

        MTGCardInDeck * deckCard = [deck.cards objectAtIndex: indexPath.row];
        cell.multiverseId = deckCard.multiverseId;
        cell.textLabel.text = 
            [NSString stringWithFormat: @"%ldx %@", (long)deckCard.count, [MTGCard cardWithMultiverseId: deckCard.multiverseId].name];
        return cell;
    } // End of our cards
    
    return nil;
}

#pragma mark -
#pragma mark Table view delegate

- (void)      tableView: (UITableView *) aTableView
didSelectRowAtIndexPath: (NSIndexPath *) indexPath
{
    [aTableView deselectRowAtIndexPath: indexPath
                              animated: YES];

    if(indexPath.section != SECTION_CARDS_INDEX)
    {
        return;
    }

    DeckCardModifierCell * cell = (DeckCardModifierCell*) [tableView cellForRowAtIndexPath: indexPath];

    MTGCard * selectedCard = [MTGCard cardWithMultiverseId: cell.multiverseId];

    CardDetailsViewController * cardViewController = [[CardDetailsViewController alloc] init];
    cardViewController.card = selectedCard;
    
    MTGNavigationController * navController = [[MTGNavigationController alloc] initWithRootViewController: cardViewController];
    
    navController.modalPresentationStyle = UIModalPresentationFormSheet;
    navController.modalTransitionStyle   = UIModalTransitionStyleCoverVertical;
    
    if([AppDelegate isIPad])
    {
        navController.preferredContentSize = CGSizeMake(540, 620);
    }
    else
    {
        navController.preferredContentSize = CGSizeMake(320, 620);
    }
    
    [self presentViewController: navController
                       animated: YES
                     completion: nil];
}

#pragma mark -

- (void) onSave: (id) sender
{
	if ( nil != selectedTextField )
	{
		// Kill the keyboard
		[selectedTextField resignFirstResponder];
	}
    
	// General
	[self.deck setDeckName: [self stringForTextField: SECTION_GENERAL_NAME inSection: SECTION_GENERAL]];

	// Save it
	[Deck saveDecks];

	// Pop to the root
	[self.navigationController popToRootViewControllerAnimated: YES];
} // End of onSave



/// <Summary>
/// Loops though our cached items trying to find one with the proper field and section, returning
/// the text of the textfield (or null if nothing was found).
/// </Summary>
- (NSString*) stringForTextField: (NSString*) field inSection: (NSString*) section
{
	NSArray * cells = [editCells objectForKey: section];
	if ( !cells )
	{
		return nil;
	}
    
	for ( int i = 0; i < [cells count]; ++i )
	{
		UITableViewCell * cell = [cells objectAtIndex: i];
		if ( [cell.textLabel.text isEqualToString: field] )
		{
			return [(MTGTextFieldTableViewCell*)cell textField].text;
		}
	} // End of for loop
	
	return nil;
} // End of stringForTextField

- (UITableViewCell*) createTextFieldCell: (NSString* ) labelText
                            currentValue: (NSString*) currentValue
                             placeHolder: (NSString*) placeHolder withTag: (int) tag
{
	MTGTextFieldTableViewCell * cell = [[MTGTextFieldTableViewCell alloc] initWithStyle: UITableViewCellStyleDefault
                                                                      reuseIdentifier: CellIdentifier];

	cell.textField.borderStyle = UITextBorderStyleNone;
	cell.textLabel.text = labelText;
    cell.textField.delegate = self;
	cell.textField.text = currentValue;
    cell.textField.textColor = [[UIColor whiteColor] colorWithAlphaComponent: 0.60];
	cell.textField.placeholder = placeHolder;
    cell.textField.tag = tag;
	cell.textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    
    return cell;
}

#pragma mark -
#pragma mark ???

- (void) deckCardModifierIncrease: (DeckCardModifierCell*) sender
{
    DeckCardModifierCell * cell = (DeckCardModifierCell*)sender;

    MTGCard* card = [MTGCard cardWithMultiverseId: cell.multiverseId];
    [deck addCard: card];
    [tableView reloadData];
}

- (void) deckCardModifierDecreased: (DeckCardModifierCell*) sender
{
    DeckCardModifierCell * cell = (DeckCardModifierCell*)sender;
    
    MTGCard* card = [MTGCard cardWithMultiverseId: cell.multiverseId];

    BOOL needsUpdate = YES;

    NSIndexPath * indexPath = [tableView indexPathForCell: cell];
    if(nil == indexPath)
    {
        return;
    } // End of no indexPath

    [tableView beginUpdates];

    NSLog(@"Before remove: %ld [%ld] cards", (long)deck.countOfCards, (long)deck.cards.count);

    // If we have removed the card completely, then we can remove the row.
    if([deck removeCard: card
           allowRemoval: YES])
    {
        NSLog(@"After (with:removeCard:allowRemoval) remove: %ld [%ld] cards", (long)deck.countOfCards, (long)deck.cards.count);
        needsUpdate = NO;

        [tableView deleteRowsAtIndexPaths: [NSArray arrayWithObject: indexPath]
                         withRowAnimation: UITableViewRowAnimationAutomatic];
    } // End of no cards left
    else
    {
        NSLog(@"After (without:removeCard:allowRemoval) remove: %ld [%ld] cards", (long)deck.countOfCards, (long)deck.cards.count);
    }

    [tableView endUpdates];
    
    if(needsUpdate)
    {
        [tableView reloadRowsAtIndexPaths: @[indexPath]
                         withRowAnimation: UITableViewRowAnimationNone];
    }

    UITableViewHeaderFooterView *header = [tableView headerViewForSection: indexPath.section];
    header.textLabel.text = [self tableView: tableView titleForHeaderInSection: indexPath.section];
}

#pragma mark -

@end
