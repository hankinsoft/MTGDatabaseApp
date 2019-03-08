//
//  SmartSearchViewController.m
//  MTG Deck Builder
//
//  Created by Kyle Hankinson on 10-08-06.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import "MTGEditSmartSearchViewController.h"
#import "MTGSmartSearch.h"
#import "MTGTextFieldTableViewCell.h"
#import "UIColorSelectorTableViewCell.h"
#import "UIMultiCheckboxViewController.h"
#import "UIPositionedTextLabelViewCell.h"

#import "AppDelegate.h"

#define				SECTION_GENERAL                 @"General"
#define				SECTION_GENERAL_NAME            @"Search Name"

#define				SECTION_CARD_DETAIL             @"Card Details"
#define				SECTION_CARD_DETAIL_NAME        @"Name"
#define				SECTION_CARD_DETAIL_TYPE        @"Type"
#define				SECTION_CARD_DETAIL_DESCRIPTION	@"Description"
#define				SECTION_CARD_DETAIL_SET         @"Expansion"
#define				SECTION_CARD_DETAIL_COLOR_ANY	@"Color (match any)"
#define				SECTION_CARD_DETAIL_COLOR_ALL	@"Color (match all)"
#define				SECTION_CARD_DETAIL_COLOR_EXCLUDE	@"Color (exclude)"
#define				SECTION_CARD_DETAIL_RARITY      @"Rarity"
#define				SECTION_CARD_DETAIL_FORMAT      @"Format"
#define				SECTION_CARD_DETAIL_ABILITY     @"Ability"
#define				SECTION_CARD_DETAIL_ARTIST      @"Artist"

#define				SECTION_SORT                    @"Sorting"
#define				SECTION_SORT_SORTBY             @"Sort By"

@interface MTGEditSmartSearchViewController ()

- (UITableViewCell*) createTextFieldCell: (NSString* ) labelText
                            currentValue: (NSString*) currentValue
                             placeHolder: (NSString*) placeHolder
                                 withTag: (int) tag;

- (NSString*) stringForTextField: (NSString*) field inSection: (NSString*) section;
- (UITableViewCell*) cellForField: (NSString*) field inSection: (NSString*) section;
- (int) valueForColorField: (NSString*) field inSection: (NSString*) section;

- (void) createCells;

// Checkbox array values
- (NSArray*) checkboxesForRarity;
- (NSArray*) checkboxesForAbility;

//- (NSArray*) checkboxesForType;
- (void) updateRarity:(id)object;
- (void) updateFormat:(id)object;

@property (nonatomic, retain) NSDictionary			* editCells;
@property (nonatomic, retain) UITextField           * selectedTextField;
@property (nonatomic, assign) unsigned int          keyboardHeight;
@property (nonatomic, assign) BOOL                  keyboardIsShowing;
@property (nonatomic, assign) unsigned int          maxTag;

@end

@implementation MTGEditSmartSearchViewController

@synthesize tableView;
@synthesize selectedTextField;
@synthesize smartSearch;
@synthesize editCells;;

@synthesize keyboardHeight, keyboardIsShowing, maxTag;

static NSString * CellIdentifier = @"EditCellIdentifier";

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
//	[self setTitle: @"Edit Search"];

    UIBarButtonItem * saveBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStylePlain target:self action:@selector(onSave:)];
    UIBarButtonItem * removeBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Delete" style:UIBarButtonItemStylePlain target:self action:@selector(onDelete:)];

    self.navigationItem.rightBarButtonItems = @[
                                                saveBarButtonItem,
                                                removeBarButtonItem
                                                ];

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
    self.navigationController.parentViewController.title = @"Cancel";

	[super viewWillAppear: animated];
}

- (UITableViewCell*) createTextFieldCell: (NSString* ) labelText
                            currentValue: (NSString*) currentValue
                             placeHolder: (NSString*) placeHolder
                                 withTag: (int) tag
{
	MTGTextFieldTableViewCell * cell = [[MTGTextFieldTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier: CellIdentifier];

	cell.textField.borderStyle = UITextBorderStyleNone;
	cell.textLabel.text = labelText;
    cell.textField.delegate = self;
	cell.textField.text = currentValue;
	cell.textField.placeholder = placeHolder;
    cell.textField.tag = tag;
	cell.textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    cell.textField.spellCheckingType = UITextSpellCheckingTypeNo;
    cell.textField.textColor = [[UIColor whiteColor] colorWithAlphaComponent: 0.60];

    return cell;
}

- (void) createCells
{
	NSMutableDictionary * _editDictionary = [[NSMutableDictionary alloc] init];
	
	// Create our search cells
	NSMutableArray * _searchCells = [[NSMutableArray alloc] init];

	UITableViewCell * cell;

    int textFieldTag = 0;

	// Search Name
    cell = [self createTextFieldCell: SECTION_GENERAL_NAME
                        currentValue: smartSearch.searchName
                         placeHolder: @""
                             withTag: textFieldTag++];
	[_searchCells addObject: cell];

	[_editDictionary setObject: _searchCells forKey: SECTION_GENERAL];
	_searchCells = [[NSMutableArray alloc] init];
	
	// Name
    cell = [self createTextFieldCell: SECTION_CARD_DETAIL_NAME
                        currentValue: smartSearch.nameLike
                         placeHolder: @""
                             withTag: textFieldTag++];
	[_searchCells addObject: cell];
/*
	// Type
	cell = [[UIPositionedTextLabelViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier: @"Type"];
    cell.textLabel.text = SECTION_CARD_DETAIL_TYPE;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.detailTextLabel.text = [smartSearch.typeArray componentsJoinedByString: @", "];
*/
    cell = [self createTextFieldCell: SECTION_CARD_DETAIL_TYPE
                        currentValue: smartSearch.typeLike
                         placeHolder: @""
                             withTag: textFieldTag++];
    [_searchCells addObject: cell];

	// Description
	cell = [self createTextFieldCell: SECTION_CARD_DETAIL_DESCRIPTION
                        currentValue: smartSearch.descriptionLike
                         placeHolder: @""
                             withTag: textFieldTag++];
	[_searchCells addObject: cell];
	
	// Set
	cell = [self createTextFieldCell: SECTION_CARD_DETAIL_SET
                        currentValue: smartSearch.setLike
                         placeHolder: @""
                             withTag: textFieldTag++];
	[_searchCells addObject: cell];

	// Color
	cell = [[UIColorSelectorTableViewCell alloc] initWithStyle: UITableViewCellStyleSubtitle
                                               reuseIdentifier: CellIdentifier];
	cell.textLabel.text = SECTION_CARD_DETAIL_COLOR_ANY;
	[(UIColorSelectorTableViewCell*)cell setValue: smartSearch.colorAny];
    cell.detailTextLabel.textColor = [[UIColor whiteColor] colorWithAlphaComponent: 0.60];
	[_searchCells addObject: cell];

	cell = [[UIColorSelectorTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier: CellIdentifier];
	cell.textLabel.text = SECTION_CARD_DETAIL_COLOR_ALL;
	[(UIColorSelectorTableViewCell*)cell setValue: smartSearch.colorAll];
    cell.detailTextLabel.textColor = [[UIColor whiteColor] colorWithAlphaComponent: 0.60];
	[_searchCells addObject: cell];

	cell = [[UIColorSelectorTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier: CellIdentifier];
	cell.textLabel.text = SECTION_CARD_DETAIL_COLOR_EXCLUDE;
	[(UIColorSelectorTableViewCell*)cell setValue: smartSearch.colorExclude];
    cell.detailTextLabel.textColor = [[UIColor whiteColor] colorWithAlphaComponent: 0.60];
	[_searchCells addObject: cell];

	// Rarity
	cell = [[UIPositionedTextLabelViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier: @"Rarity"];
    cell.textLabel.text = SECTION_CARD_DETAIL_RARITY;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.detailTextLabel.text = [smartSearch.rarityArray componentsJoinedByString: @", "];
    cell.detailTextLabel.textColor = [[UIColor whiteColor] colorWithAlphaComponent: 0.60];

	[_searchCells addObject: cell];
    
	// Format
	cell = [[UIPositionedTextLabelViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier: @"Format"];
    cell.textLabel.text = SECTION_CARD_DETAIL_FORMAT;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.detailTextLabel.text = [smartSearch.formatArray componentsJoinedByString: @", "];
    cell.detailTextLabel.textColor = [[UIColor whiteColor] colorWithAlphaComponent: 0.60];
	[_searchCells addObject: cell];

	// Ability
	cell = [[UIPositionedTextLabelViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier: @"Ability"];
    cell.textLabel.text = SECTION_CARD_DETAIL_ABILITY;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.detailTextLabel.text = [smartSearch.abilityAny componentsJoinedByString: @", "];
    cell.detailTextLabel.textColor = [[UIColor whiteColor] colorWithAlphaComponent: 0.60];
	[_searchCells addObject: cell];


	// Artist
	cell = [self createTextFieldCell: SECTION_CARD_DETAIL_ARTIST
                        currentValue: smartSearch.artistLike
                         placeHolder: @"" withTag: textFieldTag++];
	[_searchCells addObject: cell];
	[_editDictionary setObject: _searchCells forKey: SECTION_CARD_DETAIL];

	_searchCells = [[NSMutableArray alloc] init];

	// Sort by
	cell = [self createTextFieldCell: SECTION_SORT_SORTBY
                        currentValue: nil
                         placeHolder: @""
                             withTag: textFieldTag++];
	[_searchCells addObject: cell];

	[_editDictionary setObject: _searchCells forKey: SECTION_SORT];

	[self setEditCells: _editDictionary];

    // Set our maxTag
    self.maxTag = textFieldTag;
}

- (void) displaySetPicker
{
	UIMultiCheckboxViewController * multiCheckboxViewController = [[UIMultiCheckboxViewController alloc] initWithNibName:@"UIMultiCheckboxViewController" bundle: nil];

   	[self.navigationController pushViewController: multiCheckboxViewController
                                         animated: YES];
} // End of DisplaySetPicker

/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}
*/

#pragma mark -
#pragma mark Buttons

- (void) onSave: (id) sender
{
	if ( nil != selectedTextField )
	{
		// Kill the keyboard
		[selectedTextField resignFirstResponder];
	}

	// General
	[self.smartSearch setSearchName: [self stringForTextField: SECTION_GENERAL_NAME inSection: SECTION_GENERAL]];

	// Card options
	[self.smartSearch setNameLike: [self stringForTextField: SECTION_CARD_DETAIL_NAME inSection: SECTION_CARD_DETAIL]];
	[self.smartSearch setTypeLike: [self stringForTextField: SECTION_CARD_DETAIL_TYPE inSection: SECTION_CARD_DETAIL]];
	[self.smartSearch setDescriptionLike: [self stringForTextField: SECTION_CARD_DETAIL_DESCRIPTION inSection: SECTION_CARD_DETAIL]];
//	[self.smartSearch setRarityLike: [self stringForTextField: SECTION_CARD_DETAIL_RARITY inSection: SECTION_CARD_DETAIL]];
	[self.smartSearch setSetLike: [self stringForTextField: SECTION_CARD_DETAIL_SET inSection: SECTION_CARD_DETAIL]];
	[self.smartSearch setArtistLike: [self stringForTextField: SECTION_CARD_DETAIL_ARTIST inSection: SECTION_CARD_DETAIL]];

	[self.smartSearch setColorAll: [self valueForColorField: SECTION_CARD_DETAIL_COLOR_ALL inSection: SECTION_CARD_DETAIL]];
	[self.smartSearch setColorAny: [self valueForColorField: SECTION_CARD_DETAIL_COLOR_ANY inSection: SECTION_CARD_DETAIL]];
	[self.smartSearch setColorExclude: [self valueForColorField: SECTION_CARD_DETAIL_COLOR_EXCLUDE inSection: SECTION_CARD_DETAIL]];

	// Update our card count
	[self.smartSearch setCachedCount: [MTGSmartSearch countWithSmartSearch: self.smartSearch]];

	// Save it
	[MTGSmartSearch saveSmartSearchItems];

	// Pop to the root
	[self.navigationController popToRootViewControllerAnimated: YES];
	// TODO: Push the grid
} // End of onSave

- (void) onDelete: (id) sender
{
	if ( nil != selectedTextField )
	{
		// Kill the keyboard
		[selectedTextField resignFirstResponder];
	}

    // Remove it
    [[MTGSmartSearch smartSearchItems] removeObject: self.smartSearch];

	// Save it
	[MTGSmartSearch saveSmartSearchItems];
    
	// Pop to the root
	[self.navigationController popToRootViewControllerAnimated: YES];
} // End of onSave

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

        [self textFieldDidBeginEditing: self.selectedTextField];
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
    self.selectedTextField = textField;
    UITableViewCell *cell = (UITableViewCell*) [[textField superview] superview];
    [self.tableView scrollToRowAtIndexPath: [self.tableView indexPathForCell:cell] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
}

- (BOOL) textFieldShouldReturn:(UITextField *)aTextField
{
    NSLog( @"Textfield should return called" );

    if ( aTextField.tag + 1 < self.maxTag )
    {
        UITextField * target = (UITextField*)[self.tableView viewWithTag: aTextField.tag + 1];
		[target becomeFirstResponder];

        return NO;
    }
    else
    {
        [aTextField resignFirstResponder];
        return YES;
    }

} // End of textFieldShouldReturn

#pragma mark Table view data source

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	if ( 0 == section )
	{
		return SECTION_GENERAL;
	}
    else if ( 1 == section )
    {
        return SECTION_CARD_DETAIL;
    }
    else if ( 2 == section )
    {
        return SECTION_SORT;
    }

    return @"";
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView
{
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section
{
	NSString * key = [self tableView:aTableView titleForHeaderInSection:section];
	NSArray * cells = [self.editCells objectForKey: key];
	
	return [cells count];
}


- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString * key = [self tableView:aTableView titleForHeaderInSection:indexPath.section];
	NSArray * cells = [self.editCells objectForKey: key];

	return [cells objectAtIndex: indexPath.row];
}

- (CGFloat)tableView:(UITableView *)aTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ( ![AppDelegate isIPad] )
    {
        NSString * key = [self tableView:aTableView titleForHeaderInSection:indexPath.section];
        NSArray * cells = [self.editCells objectForKey: key];

        if ( [[cells objectAtIndex: indexPath.row] isKindOfClass: [UIColorSelectorTableViewCell class]] )
        {
            return 88;
        } // End of ColorSelectorTableViewCell
    } // End of iPhone
	return 44;
}

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */


/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
 
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }   
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }   
 }
 */


/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
 }
 */


/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ( false ) //1 == indexPath.section && 1 == indexPath.row )
    {
#if NOTUSED
        UIMultiCheckboxViewController * multiCheckboxViewController = [[UIMultiCheckboxViewController alloc] initWithNibName:@"UIMultiCheckboxViewController" bundle: nil];
        
        // Setup our checkbox
        [multiCheckboxViewController setTitle: @"Select Types"];
        [multiCheckboxViewController setCheckboxItems: [self checkboxesForType]];
        [multiCheckboxViewController setDelegate: self];
        [multiCheckboxViewController setSelector: @selector(updateTypes:)];

        [self.navigationController pushViewController: multiCheckboxViewController
                                             animated: YES];
        
        [multiCheckboxViewController release];
#endif
    } // End of type
    
    else if ( 1 == indexPath.section && 7 == indexPath.row )
    {
        UIMultiCheckboxViewController * multiCheckboxViewController = [[UIMultiCheckboxViewController alloc] initWithNibName:@"UIMultiCheckboxViewController" bundle: nil];

        // Setup our checkbox
        [multiCheckboxViewController setTitle: @"Select Rarity"];
        [multiCheckboxViewController setCheckboxItems: [self checkboxesForRarity]];
        multiCheckboxViewController.onCheckboxAction = ^(NSArray *checkboxItems) {
            [self updateRarity: checkboxItems];
        };

        [self.navigationController pushViewController: multiCheckboxViewController
                                             animated: YES];
    }
    else if ( 1 == indexPath.section && 8 == indexPath.row )
    {
        UIMultiCheckboxViewController * multiCheckboxViewController = [[UIMultiCheckboxViewController alloc] initWithNibName:@"UIMultiCheckboxViewController" bundle: nil];
        
        // Setup our checkbox
        [multiCheckboxViewController setTitle: @"Select Format"];
        [multiCheckboxViewController setCheckboxItems: [self checkboxesForFormat]];
        multiCheckboxViewController.onCheckboxAction = ^(NSArray *checkboxItems) {
            [self updateFormat: checkboxItems];
        };
        
        [self.navigationController pushViewController: multiCheckboxViewController
                                             animated: YES];
    }
    else if ( 1 == indexPath.section && 9 == indexPath.row )
    {
        UIMultiCheckboxViewController * multiCheckboxViewController = [[UIMultiCheckboxViewController alloc] initWithNibName:@"UIMultiCheckboxViewController" bundle: nil];
        
        // Setup our checkbox
        [multiCheckboxViewController setTitle: @"Select Abilities"];
        [multiCheckboxViewController setCheckboxItems: [self checkboxesForAbility]];
        multiCheckboxViewController.onCheckboxAction = ^(NSArray *checkboxItems) {
            [self updateAbility: checkboxItems];
        };

        [self.navigationController pushViewController: multiCheckboxViewController
                                             animated: YES];
    }
}

- (void) setSmartSearch:(MTGSmartSearch *) _smartSearch
{
    smartSearch = _smartSearch;
} // End of setSmartSearch

#pragma mark -
#pragma mark Memory management

/// <Summary>
/// Loops though our cached items trying to find one with the proper field and section, returning
/// the text of the textfield (or null if nothing was found).
/// </Summary>
- (NSString*) stringForTextField: (NSString*) field inSection: (NSString*) section
{
	NSArray * cells = [self.editCells objectForKey: section];
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

- (UITableViewCell*) cellForField: (NSString*) field
                        inSection: (NSString*) section
{
	NSArray * cells = [self.editCells objectForKey: section];
	if ( !cells )
	{
		return nil;
	}
    
	for ( int i = 0; i < [cells count]; ++i )
	{
		UITableViewCell * cell = [cells objectAtIndex: i];
		if ( [cell.textLabel.text isEqualToString: field] )
		{
			return cell;
		}
	} // End of for loop
	
	return nil;
}

/// <Summary>
/// Loops though our cached items trying to find one with the proper field and section, returning
/// the value of the combined colors (or 0 if nothing was found).
/// </Summary>
- (int) valueForColorField: (NSString*) field inSection: (NSString*) section
{
	NSArray * cells = [self.editCells objectForKey: section];
	if ( !cells )
	{
		return 0;
	}
	
	for ( int i = 0; i < [cells count]; ++i )
	{
		UITableViewCell * cell = [cells objectAtIndex: i];
		if ( [cell.textLabel.text isEqualToString: field] )
		{
			return [(UIColorSelectorTableViewCell*)cell getValue];
		}
	} // End of for loop
	
	return 0;
} // End of stringForTextField

#pragma mark -
#pragma mark Checkbox array

- (NSArray*) checkboxesForRarity
{
    NSMutableArray * array = [[NSMutableArray alloc] init];

    weakify(self);
    [[AppDelegate databaseQueue] inDatabase: ^(FMDatabase * database) {
        strongify(self);

        FMResultSet * results = [database executeQuery: @"SELECT DISTINCT rarity FROM card ORDER BY rarity ASC"];

		while ([results next])
		{
            CheckboxObject * checkboxObject = [[CheckboxObject alloc] init];
            [checkboxObject setDisplay: [results stringForColumnIndex: 0]];
            [checkboxObject setValue: checkboxObject.display];

            // Checked if our rarity already contains this object
            [checkboxObject setChecked: [self->smartSearch.rarityArray containsObject: checkboxObject.display]];

            [array addObject: checkboxObject];
		}
    }]; // End of query

    return array;
} // End fo checkboxesForRarity

- (NSArray*) checkboxesForFormat
{
    NSMutableArray * array = [[NSMutableArray alloc] init];

    weakify(self);
    [[AppDelegate databaseQueue] inDatabase: ^(FMDatabase * database) {
        strongify(self);

        FMResultSet * results = [database executeQuery: @"SELECT DISTINCT name FROM format ORDER BY name ASC"];

		while ([results next])
		{
            CheckboxObject * checkboxObject = [[CheckboxObject alloc] init];
            [checkboxObject setDisplay: [results stringForColumnIndex: 0]];
            [checkboxObject setValue: checkboxObject.display];
            // Checked if our rarity already contains this object
            [checkboxObject setChecked: [self->smartSearch.formatArray containsObject: checkboxObject.display]];
            
            [array addObject: checkboxObject];
		}
    }]; // End of query

    return array;
} // End fo checkboxesForRarity

- (NSArray*) checkboxesForAbility
{
    NSMutableArray * array = [[NSMutableArray alloc] init];
    
    weakify(self);
    [[AppDelegate databaseQueue] inDatabase: ^(FMDatabase * database) {
        strongify(self);

        FMResultSet * results = [database executeQuery: @"SELECT DISTINCT name FROM ability ORDER BY name ASC"];
        
        while ([results next])
        {
            CheckboxObject * checkboxObject = [[CheckboxObject alloc] init];
            [checkboxObject setDisplay: [results stringForColumnIndex: 0]];
            [checkboxObject setValue: checkboxObject.display];
            // Checked if our ability already contains this object
            [checkboxObject setChecked: [self->smartSearch.abilityAny containsObject: checkboxObject.display]];
            
            [array addObject: checkboxObject];
		}
    }]; // End of query

    return array;
} // End fo checkboxesForAbility

/*
- (NSArray*) checkboxesForType
{
    NSMutableArray * array = [[NSMutableArray alloc] init];
    NSArray * types = [[NSArray alloc] initWithObjects:
                       @"Artifact", @"Creature", @"Enchantment", @"Instant", @"Interrupt", @"Land", @"Legendary",
                       @"Planeswalker", @"Snow", @"Sorcery", @"Summon", @"Tribal", nil];
    
    for ( int i = 0; i < [types count]; ++i )
    {
        NSString * type = [types objectAtIndex: i];
        CheckboxObject * checkboxObject = [[CheckboxObject alloc] init];
        [checkboxObject setDisplay: type];
        [checkboxObject setValue: checkboxObject.display];
        // Checked if our rarity already contains this object
        [checkboxObject setChecked: [smartSearch.typeArray containsObject: checkboxObject.display]];

        [array addObject: checkboxObject];
        [checkboxObject release];
	} // End of query
    
    return array;
} // End fo checkboxesForRarity
*/
- (void) updateRarity:(id)object
{
    NSArray * rarityArray = (NSArray*)object;
    
    NSMutableArray * newArray = [[NSMutableArray alloc] init];
    for ( int i = 0; i < [rarityArray count]; ++i )
    {
        CheckboxObject * cbo = (CheckboxObject*)[rarityArray objectAtIndex: i];
        if ( cbo.checked )
        {
            [newArray addObject: cbo.value];
        }
    }

    // Clear the existing items
    self.smartSearch.rarityArray = [NSArray arrayWithArray: newArray];

    UITableViewCell * cell = [self cellForField: SECTION_CARD_DETAIL_RARITY
                                      inSection: SECTION_CARD_DETAIL];
    [cell.detailTextLabel setText: [smartSearch.rarityArray componentsJoinedByString: @", "]];
    [tableView reloadData];
}

- (void) updateFormat:(id)object
{
    NSArray * formatArray = (NSArray*)object;
    
    NSMutableArray * newArray = [[NSMutableArray alloc] init];
    for ( int i = 0; i < [formatArray count]; ++i )
    {
        CheckboxObject * cbo = (CheckboxObject*)[formatArray objectAtIndex: i];
        if ( cbo.checked )
        {
            [newArray addObject: cbo.value];
        }
    }
    
    // Clear the existing items
    self.smartSearch.formatArray = [NSArray arrayWithArray: newArray];
    
    UITableViewCell * cell = [self cellForField: SECTION_CARD_DETAIL_FORMAT inSection: SECTION_CARD_DETAIL];
    [cell.detailTextLabel setText: [smartSearch.formatArray componentsJoinedByString: @", "]];
    [tableView reloadData];
}

- (void) updateAbility:(id)object
{
    NSArray * abilityArray = (NSArray*)object;
    
    NSMutableArray * newArray = [[NSMutableArray alloc] init];
    for ( int i = 0; i < [abilityArray count]; ++i )
    {
        CheckboxObject * cbo = (CheckboxObject*)[abilityArray objectAtIndex: i];
        if ( cbo.checked )
        {
            [newArray addObject: cbo.value];
        }
    }
    
    // Clear the existing items
    self.smartSearch.abilityAny = [NSArray arrayWithArray: newArray];
    
    UITableViewCell * cell = [self cellForField: SECTION_CARD_DETAIL_ABILITY inSection: SECTION_CARD_DETAIL];
    [cell.detailTextLabel setText: [smartSearch.abilityAny componentsJoinedByString: @", "]];
    [tableView reloadData];
} // End of updateAbility

/*
- (void) updateTypes:(id)object
{
    NSArray * typesArray = (NSArray*)object;
    
    NSMutableArray * newArray = [[NSMutableArray alloc] init];
    for ( int i = 0; i < [typesArray count]; ++i )
    {
        CheckboxObject * cbo = (CheckboxObject*)[typesArray objectAtIndex: i];
        if ( cbo.checked )
        {
            [newArray addObject: cbo.value];
        }
    }

    // Clear the existing items
    self.smartSearch.typeArray = newArray;
    [newArray release];

    UITableViewCell * cell = [self cellForField: SECTION_CARD_DETAIL_TYPE inSection: SECTION_CARD_DETAIL];
    [cell.detailTextLabel setText: [smartSearch.typeArray componentsJoinedByString: @", "]];
    [tableView reloadData];
} // End of updateTypes
*/
@end

