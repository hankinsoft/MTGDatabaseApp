//
//  BrowseSetViewController.m
//  MTG Deck Builder
//
//  Created by Kyle Hankinson on 10-08-04.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import "BrowseSetViewController.h"
#import "MTGCardSet.h"
#import "MTGCard.h"
#import "UISetTableCell.h"
#import "MTGSmartSearch.h"
#import "AppDelegate.h"
#import "HSSearchBarWithSpinner.h"
#import "MTGCardSetIconHelper.h"

@interface BrowseSetViewController ()<UISearchBarDelegate, UIAlertViewDelegate>
{
    HSSearchBarWithSpinner * searchBar;
}

- (void) createCardSetCellCache: (NSArray*) cardSets;

@end

@implementation BrowseSetViewController
{
    RevealBlock         _revealBlock;
    NSArray             * setIndex;
    BOOL                isRemovingTextWithBackspace;
}

#pragma mark -
#pragma mark View lifecycle

- (id) initWithRevealBlock: (RevealBlock) revealBlock
{
    if (self = [super initWithNibName:nil bundle:nil])
    {
		_revealBlock = [revealBlock copy];

		self.navigationItem.leftBarButtonItem = [GHRootViewController generateMenuBarButtonItem: self
                                                                                       selector: @selector(revealSidebar)];
	}
	return self;
}

- (void) revealSidebar
{
	_revealBlock();
}

- (void) viewDidLoad
{
    self.title = @"Sets";
    self.navigationController.navigationBar.barStyle = [AppDelegate barButtonStyle];
    self.navigationController.navigationBar.translucent = NO;

	NSLog( @"Root view controller - View did load!" );
    [super viewDidLoad];

    UIColor * backgroundColor = SQLProAppearanceManager.sharedInstance.darkTableBackgroundColor;

    searchBar = [[HSSearchBarWithSpinner alloc] initWithFrame: CGRectMake(0, 0, 0, 56.0f)];
    searchBar.textColor = [UIColor whiteColor];
    searchBar.autocorrectionType   = UITextAutocorrectionTypeNo;
    searchBar.searchBarStyle       = UISearchBarStyleMinimal;
    searchBar.tintColor            = [UIColor darkGrayColor];   // Tint color is the entered text color + cancel button color
    searchBar.barTintColor         = backgroundColor;
    searchBar.placeholder          = @"Search";
    searchBar.delegate             = self;
    tableView.tableHeaderView = searchBar;

	// Search results
    searchResultCells = nil;
    searchResultSets  = nil;

    [self updateCache];
}

- (void) updateCache
{
    NSMutableArray * filteredArray = [NSMutableArray array];
    for(MTGCardSet * cardSet in [MTGCardSet allCardSets])
    {
        if(cardSet.block &&
           (NSOrderedSame == [cardSet.block caseInsensitiveCompare: @"promo"] ||
            NSOrderedSame == [cardSet.block caseInsensitiveCompare: @"signature spellbook"] ||
            NSOrderedSame == [cardSet.block caseInsensitiveCompare: @"global series"]))
        {
            continue;
        }

        [filteredArray addObject: cardSet];
    } // End of cardSet

    // Get our cardSets
    NSSortDescriptor * dateSortDescriptor = [NSSortDescriptor sortDescriptorWithKey: @"releaseDate"
                                                                          ascending: NO];

    NSArray * _cardSets = [filteredArray sortedArrayUsingDescriptors: @[dateSortDescriptor]];

    // Check for error. Unable to load card sets
    if(0 == _cardSets)
    {
        NSLog(@"Unable to load cardSet");
        [[NSUserDefaults standardUserDefaults] setInteger: -1
                                                   forKey: DATABASE_VERSION_KEY];
    } // End of unable to load cardSets

    TICK;
    [self createCardSetCellCache: _cardSets];
    TOCK(@"Created browse-set cell cache.");

    [tableView reloadData];
}

- (void) viewWillAppear: (BOOL) animated
{
    [super viewWillAppear: animated];
    [searchBar setText: @""];
} // End of viewWillAppear:

#pragma mark -
#pragma mark Content Filtering

- (void) filterContentForSearchText: (NSString*) searchText
{
    if(0 == searchText.length)
    {
        searchResultCells = nil;
        searchResultSets  = nil;

        [tableView reloadData];

        return;
    } // End of no search length

    searchResultCells = @[].mutableCopy;
    searchResultSets  = @[].mutableCopy;

    NSUInteger cardSetCount = [cardSets count];
	for(NSUInteger j = 0;
        j < cardSetCount;
        ++j)
	{
		MTGCardSet * set = (MTGCardSet*)[cardSets objectAtIndex: j];
		NSRange resultsRange = [[set name] rangeOfString: searchText
                                                 options: NSCaseInsensitiveSearch];

		if(resultsRange.length)
		{
			[searchResultCells addObject: [cardSetCellCache objectAtIndex: j]];
			[searchResultSets addObject: set];
		}
	} // End of CardSet loop

    // Reload
    [tableView reloadData];
} // End of filterContentForSearchText

#pragma mark -
#pragma mark UISearchBarDelegate

- (void) searchBarTextDidBeginEditing: (UISearchBar *) aSearchBar
{
    [aSearchBar setShowsCancelButton: YES
                            animated: YES];
} // End of searchBarTextDidBeginEditing:

- (BOOL)      searchBar: (UISearchBar *)searchBar
shouldChangeTextInRange: (NSRange)range
        replacementText: (NSString *)text
{
    isRemovingTextWithBackspace = ([searchBar.text stringByReplacingCharactersInRange:range withString:text].length == 0);

    return YES;
} // End of searchBar:shouldChangeTextInRange:replacementText:

- (void) searchBar: (UISearchBar *) searchBar
     textDidChange: (NSString *) searchText
{
    if ([searchText length] == 0 && !isRemovingTextWithBackspace)
    {
        [self filterContentForSearchText: nil];
    }
} // End fo searchBar:textDidChange:

- (void) searchBarCancelButtonClicked: (UISearchBar *)aSearchBar
{
    [aSearchBar setShowsCancelButton: NO
                            animated: YES];

    [aSearchBar setText: @""];
    [self filterContentForSearchText: nil];
    [aSearchBar resignFirstResponder];
} // End of searchBarCancelButtonClicked:

- (void) searchBarSearchButtonClicked: (UISearchBar *) aSearchBar
{
    NSString * searchText = aSearchBar.text;
    NSLog(@"Want to search for: %@", searchText);
    [self filterContentForSearchText: searchText];
    [aSearchBar resignFirstResponder];
} // End of searchBarSearchButtonClicked:

#pragma mark Table view data source

- (void) createCardSetCellCache: (NSArray*) newCardSets
{
	NSMutableArray * tempCellCache = [[NSMutableArray alloc] init];

	// Loop though our cardsets creating a cell for each
	for ( int i = 0; i < [newCardSets count]; ++i )
	{
		MTGCardSet * cardSet = [newCardSets objectAtIndex: i];

        UISetTableCell * cell = nil;
        cell = [[UISetTableCell alloc] initWithStyle: UITableViewCellStyleSubtitle
                                     reuseIdentifier: @"CardSetCell"];

        cell.cardSet        = cardSet;

        cell.textLabel.text = cardSet.name;

#if DEBUG
        cell.detailTextLabel.text = [NSString stringWithFormat: @"%ld cards (%@) block: %@, type: %@, ", (long)cardSet.cardCount, cardSet.shortName, cardSet.block, cardSet.type];
#else
        cell.detailTextLabel.text = [NSString stringWithFormat: @"%ld cards", (long)cardSet.cardCount];
#endif
        cell.detailTextLabel.textColor = [[UIColor whiteColor] colorWithAlphaComponent: 0.60];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

        // Default to empty
        cell.imageView.image = [UIImage imageNamed: @"Empty32"];

		// Add our cell to the tempCache
		[tempCellCache addObject: cell];
	} // End of loop

    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        static UIImage * lockImage = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            lockImage = [UIImage imageNamed: @"Lock"];
        });

        for(UISetTableCell * cell in tempCellCache)
        {
            // Load the image on the background thread
            UIImage * setImage = [MTGCardSetIconHelper iconForCardSet: cell.cardSet];
            if(nil == setImage)
            {
                // Default to the magic logo icon
                setImage = [MTGCardSetIconHelper iconForCardSetShortName: @"DOTP"];
            }

            dispatch_async(dispatch_get_main_queue(), ^{
                cell.setImageView.image = setImage;
                cell.setImageView.tintColor = [UIColor redColor];
            });
        } // End of cell cache enumeration
    });

    cardSets = newCardSets;
    cardSetCellCache = tempCellCache;
}

- (NSInteger) numberOfSectionsInTableView: (UITableView *) aTableView
{
    // Return the number of sections.
    if(nil != setIndex)
    {
        return setIndex.count;
    }

    return 1;
}

- (NSInteger) tableView: (UITableView *)aTableView
  numberOfRowsInSection: (NSInteger)section
{
    NSUInteger rows = 0;

	if (searchResultCells)
	{
		rows = [searchResultCells count];
    }
	else if(nil != setIndex)
	{
        NSString * alphabet = [setIndex objectAtIndex: section];

        NSPredicate * predicate = [NSPredicate predicateWithFormat: @"SELF.name beginswith[c] %@", alphabet];
        NSArray * cards = [cardSets filteredArrayUsingPredicate: predicate];

		rows = [cards count];
	}
    else
    {
        rows = cardSets.count;
    }

    // Return the number of rows in the section.
    return rows;
} // End of numberOfRowsInSection

- (UITableViewCell *)tableView: (UITableView *) aTableView
         cellForRowAtIndexPath: (NSIndexPath *) indexPath
{
    UISetTableCell * setTableCell = nil;

	if (searchResultCells)
	{
        return [searchResultCells objectAtIndex: indexPath.row];
	} // End of searching
    else if(nil != setIndex)
	{
        // Get our letter
        NSString *alphabet = [setIndex objectAtIndex: [indexPath section]];

        // Find the cached items
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.name beginswith[c] %@", alphabet];
        NSArray * temp = [cardSets filteredArrayUsingPredicate:predicate];
        NSUInteger index = [cardSets indexOfObject: [temp objectAtIndex: indexPath.row]];

        setTableCell = [cardSetCellCache objectAtIndex: index];
	} // End of normal
    else
    {
        setTableCell = [cardSetCellCache objectAtIndex: indexPath.row];
    }

    return setTableCell;
} // End of cellForRowAtIndexPath

- (void)      tableView: (UITableView *) aTableView
didSelectRowAtIndexPath: (NSIndexPath *) indexPath
{
	NSLog( @"RootViewController selected an item" );

	// Kill the keyboard
	[searchBar resignFirstResponder];

	// Deselect
	[aTableView deselectRowAtIndexPath:indexPath animated:YES];
    [aTableView reloadData];

	if (searchResultCells)
	{
		// Array is the sorted array
		selectedCardSet = [searchResultSets objectAtIndex: indexPath.row];
	} // End of searching
	else if(nil != setIndex)
	{
        // Get our letter
        NSString *alphabet = [setIndex objectAtIndex: [indexPath section]];
        
        // Find the cached items
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.name beginswith[c] %@", alphabet];
        NSArray * temp = [cardSets filteredArrayUsingPredicate:predicate];
        selectedCardSet = [temp objectAtIndex: indexPath.row];
	}
    else
    {
        selectedCardSet = cardSets[indexPath.row];
    }

	MTGSmartSearch * tempSmartSearch = [MTGSmartSearch smartSearchForSetId: selectedCardSet.setId];

	CardGridViewController * cardGridViewController;
    cardGridViewController = [[CardGridViewController alloc] init];

	cardGridViewController.hidesBottomBarWhenPushed = YES;
	cardGridViewController.smartSearch = tempSmartSearch;

	[self.navigationController pushViewController: cardGridViewController
                                         animated: YES];

//    cardGridViewController.title = selectedCardSet.name;
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning
{
    NSLog( @"BrowseSetViewController received memory warning" );
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];

    // Relinquish ownership any cached data, images, etc. that aren't in use.
}

@end

