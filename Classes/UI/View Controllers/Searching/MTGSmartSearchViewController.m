//
//  SearchViewController.m
//  MTG Deck Builder
//
//  Created by Kyle Hankinson on 10-06-20.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "MTGSmartSearchViewController.h"
#import "CardGridViewController.h"
#import "MTGSmartSearch.h"

#import "CardDetailsViewController.h"

#import "AppDelegate.h"

@interface MTGSmartSearchViewController ()
{
}

@property (nonatomic, retain) MTGSmartSearch           * selectedSmartSearch;

@end

@implementation MTGSmartSearchViewController
@synthesize selectedSmartSearch;

// UI
@synthesize tableView;

#pragma mark -
#pragma mark View lifecycle


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

- (void)viewDidLoad
{
    self.navigationController.navigationBar.barStyle = [AppDelegate barButtonStyle];

	self.navigationItem.rightBarButtonItem = addButton;

    [super viewDidLoad];
}

- (void) viewWillAppear: (BOOL) animated
{
    self.title = @"Advanced Search";

	// Reload our tableView
	[self.tableView reloadData];

    [super viewWillAppear: animated];

    TICK;
    [[MTGSmartSearch smartSearchItems] enumerateObjectsUsingBlock:
     ^(MTGSmartSearch * smartSearch, NSUInteger index, BOOL * stop)
    {
        smartSearch.cachedCount = [MTGSmartSearch countWithSmartSearch: smartSearch];
    }];

    TOCK(@"Counts for smart search.");
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id <UIViewControllerTransitionCoordinator>)coordinator
{
    NSLog ( @"Will viewWillTransitionToSize" );

	[tableView reloadData];
}

#pragma mark -
#pragma mark Card Grid view delegate

- (void) beginLoadingSequenceCompleted
{
	NSLog ( @"BeginLoadingSequenceComplete" );
}

#pragma mark -
#pragma mark Actions

- (IBAction) onEdit: (id) sender
{
    // If we are editing
    if ( self.tableView.editing )
    {
        NSLog ( @"Editing Completed" );
        self.tableView.editing = NO;
        editButton.title = @"Edit";
    }
    else
    {
        NSLog ( @"Editing Started" );
        self.tableView.editing = YES;
        editButton.title = @"Done";
    }
} // End of onEdit

- (IBAction) onAdd: (id) sender
{
	MTGSmartSearch * smartSearch = [[MTGSmartSearch alloc] init];
	smartSearch.cachedCount = [MTGSmartSearch countWithSmartSearch: smartSearch];
	[smartSearch setSearchName: @"New Search"];

	// Add an item to our smart search items
	[[MTGSmartSearch smartSearchItems] addObject: smartSearch];
	[MTGSmartSearch saveSmartSearchItems];
	[self.tableView reloadData];

	// Load up our smart search
    MTGEditSmartSearchViewController * editSmartSearchViewController = [[MTGEditSmartSearchViewController alloc] initWithNibName:@"MTGEditSmartSearchViewController" bundle: nil];

    // Set our smartSearch
    editSmartSearchViewController.smartSearch = [[MTGSmartSearch smartSearchItems] objectAtIndex: [[MTGSmartSearch smartSearchItems] count] - 1];

	// Hide the tab bar when displayed
	editSmartSearchViewController.hidesBottomBarWhenPushed = YES;

    // Hack. Change the title so that it updates the back button.
    self.title = @"Cancel";

	[self.navigationController pushViewController: editSmartSearchViewController animated:YES];
} // End of onAdd

#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView
{
    // Return the number of sections.
    return 1;
}

- (NSString *)tableView:(UITableView *)aTableView titleForHeaderInSection:(NSInteger)section
{
    return @"";
} // End of titleForHeaderInSection

- (NSInteger)tableView:(UITableView *)aTableView
 numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [[MTGSmartSearch smartSearchItems] count];
}


- (UITableViewCell *)tableView:(UITableView *)aTableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SmartSearchCellIdentifier";

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
        cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    }

    MTGSmartSearch * smartSearch = [[MTGSmartSearch smartSearchItems] objectAtIndex: indexPath.row];

    // Find our how many cards there are
    NSInteger cards = [smartSearch cachedCount];
    cell.textLabel.text = smartSearch.searchName;

    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    NSString *formattedOutput = [formatter stringFromNumber: [NSNumber numberWithInteger: cards]];

    cell.detailTextLabel.text = [NSString stringWithFormat: @"%@ card%@", formattedOutput, cards == 1 ? @"" : @"s"];
    cell.detailTextLabel.textColor = [[UIColor whiteColor] colorWithAlphaComponent: 0.60];

    return cell;
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

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
} // End of canMoveRowAtIndexPath

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
	// Swap the items in our array
	[[MTGSmartSearch smartSearchItems] exchangeObjectAtIndex:fromIndexPath.row withObjectAtIndex:toIndexPath.row];

	// Save
	[MTGSmartSearch saveSmartSearchItems];
}

//RootViewController.m
- (void)tableView:(UITableView *)aTableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    NSLog ( @"Accessory button tapped" );

	MTGEditSmartSearchViewController * editSmartSearchViewController = [[MTGEditSmartSearchViewController alloc] initWithNibName:@"MTGEditSmartSearchViewController" bundle: nil];

	// Set our smartSearch
	editSmartSearchViewController.smartSearch = [[MTGSmartSearch smartSearchItems] objectAtIndex: indexPath.row];
	editSmartSearchViewController.hidesBottomBarWhenPushed = YES;
    self.title = @"Cancel";
	[self.navigationController pushViewController:editSmartSearchViewController animated:YES];
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSLog ( @"RootViewController selected an item" );

    // Get our selected smart search item
    selectedSmartSearch = [[MTGSmartSearch smartSearchItems] objectAtIndex: indexPath.row];

	CardGridViewController * cardGridViewController;
	
    cardGridViewController = [[CardGridViewController alloc] init];

	cardGridViewController.hidesBottomBarWhenPushed = YES;
	cardGridViewController.smartSearch = selectedSmartSearch;
    self.title = @"Back";
	[self.navigationController pushViewController:cardGridViewController animated:YES];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
	// If row is deleted, remove it from the list.
	if (editingStyle == UITableViewCellEditingStyleDelete)
	{
		// Delete our object from the array and update the table
		[[MTGSmartSearch smartSearchItems] removeObjectAtIndex: indexPath.row];
		[self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
		[MTGSmartSearch saveSmartSearchItems];
	}
}

#pragma mark -
#pragma mark EditSmartSearchProtocol

- (void) smartSearchSaveFinished
{
	NSLog ( @"Smart search saved" );

	// Reload our table
	[self.tableView reloadData];

	// Save our updated items
	[MTGSmartSearch saveSmartSearchItems];
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning
{
    NSLog( @"SearchViewController received memory warning" );

    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

@end

