//
//  DeckBuilderViewController.m
//  MTG Deck Builder
//
//  Created by Kyle Hankinson on 11-10-02.
//  Copyright (c) 2011 Hankinsoft. All rights reserved.
//

#import "DeckBuilderViewController.h"
#import "Deck.h"
#import "EditDeckViewController.h"

@implementation DeckBuilderViewController


- (id)initWithRevealBlock:(RevealBlock)revealBlock
{
    if (self = [super initWithNibName:nil bundle:nil])
    {
		_revealBlock = [revealBlock copy];
        
		self.navigationItem.leftBarButtonItem = [GHRootViewController generateMenuBarButtonItem: self
                                                                                       selector: @selector(revealSidebar)];
	}
	return self;
}

- (void)revealSidebar {
	_revealBlock();
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void) viewDidLoad
{
    [super viewDidLoad];

    self.title = @"Collections";
    self.navigationController.navigationBar.barStyle = [AppDelegate barButtonStyle];

//	self.navigationItem.leftBarButtonItem = editButton;
	self.navigationItem.rightBarButtonItem = addButton;
}

- (void) viewWillAppear:(BOOL)animated
{
    [tableView reloadData];
    [super viewWillAppear:animated];
}

#pragma mark -
#pragma mark Actions

- (IBAction) onEdit: (id) sender
{
    // If we are editing
    if ( tableView.editing )
    {
        NSLog( @"Editing Completed" );
        tableView.editing = NO;
        editButton.title = @"Edit";
    }
    else
    {
        NSLog( @"Editing Started" );
        tableView.editing = YES;
        editButton.title = @"Done";
    }
} // End of onEdit

- (IBAction) onAdd: (id) sender
{
	Deck * deck = [[Deck alloc] init];
	[deck setDeckName: @"New Collection"];
    
	// Add an item to our smart search items
	[[Deck decks] addObject: deck];
	[Deck saveDecks];
	[tableView reloadData];
} // End of onAdd

#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [[Deck decks] count];
}


- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"DeckBuilderCellIdentifier";
    
    // Dequeue or create a cell of the appropriate type.
    UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
	{
        cell = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    // If we are editing, the allow re-ordering
    if ( aTableView.editing )
    {
        cell.showsReorderControl = YES;
    }
    else
    {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }

    Deck * deck = [[Deck decks] objectAtIndex: indexPath.row];

    cell.textLabel.text = deck.deckName;

    // Find our how many cards there are
    NSUInteger cards = [deck countOfCards];
    cell.detailTextLabel.text = [NSString stringWithFormat: @"%lu card%@", (unsigned long)cards, cards == 1 ? @"" : @"s"];
    cell.detailTextLabel.textColor = [[UIColor whiteColor] colorWithAlphaComponent: 0.60];

    return cell;
}

#pragma mark -
#pragma mark Table view delegate

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
} // End of canMoveRowAtIndexPath

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
	// Swap the items in our array
	[[Deck decks] exchangeObjectAtIndex: fromIndexPath.row withObjectAtIndex:toIndexPath.row];
    
	// Save
	[Deck saveDecks];
}

//RootViewController.m
- (void)tableView:(UITableView *)aTableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
//    NSLog( @"Accessory button tapped" );
}

- (void)tableView:(UITableView *)aTableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	EditDeckViewController * editDeckViewController = [[EditDeckViewController alloc] init];
    
	// Set our deck
	editDeckViewController.deck = [[Deck decks] objectAtIndex: indexPath.row];
	editDeckViewController.hidesBottomBarWhenPushed = YES;
	[self.navigationController pushViewController: editDeckViewController animated:YES];
}

- (void)tableView:(UITableView *)aTableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
	// If row is deleted, remove it from the list.
	if (editingStyle == UITableViewCellEditingStyleDelete)
	{
		// Delete our object from the array and update the table
		[[Deck decks] removeObjectAtIndex: indexPath.row];
		[aTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
		[Deck saveDecks];
	}
}

#pragma mark -

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

@end
