//
//  BrowseFormatViewController.m
//  MTG Deck Builder
//
//  Created by Kyle Hankinson on 2013-05-29.
//
//

#import "BrowseFormatViewController.h"
#import "AppDelegate.h"
#import "MTGSmartSearch.h"
#import "CardGridViewController.h"

@interface BrowseFormatViewController ()
{
    NSArray                     * formats;
    NSArray                     * setIndex;
    
    IBOutlet UITableView        * formatTableView;
}
@end

@implementation BrowseFormatViewController

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

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)revealSidebar {
	_revealBlock();
}

- (void)viewDidLoad
{
    self.title = @"Formats";
    self.navigationController.navigationBar.barStyle = [AppDelegate barButtonStyle];
    self.navigationController.navigationBar.translucent = NO;

    [super viewDidLoad];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear: animated];
} // End of viewWillAppear

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) loadFormats
{
    if(nil != formats && formats.count > 0)
    {
        return;
    }

    dispatch_queue_t backgroundQueue = dispatch_queue_create("com.hankinsoft.mtg.formatloader", 0);
    
    weakify(self);
    dispatch_async(backgroundQueue, ^{
        strongify(self);

        NSLog(@"Loading formats");

        [[AppDelegate databaseQueue] inDatabase: ^(FMDatabase * database) {
            strongify(self);

            NSString * query = @"SELECT formatId, name, cardCount FROM format ORDER BY name ASC";
            FMResultSet * results = [database executeQuery: query];

            if(nil == results && nil != database.lastError)
            {
                NSLog(@"Failed to execute query: %@.\r\nError: %@.",
                      query,
                      database.lastError.localizedDescription);
            }

            NSMutableArray * _formats = [NSMutableArray array];

            while([results next])
            {
                [_formats addObject: @{
                                       @"id":[results objectForColumnName: @"formatId"],
                                       @"format":[results objectForColumnName: @"name"],
                                       @"cardCount":[NSNumber numberWithInteger: [results intForColumn: @"cardCount"]],
                                       }];
            }

            self->formats = [_formats copy];
        }];

        // Our set index
        NSMutableArray * indexes = [NSMutableArray array];
        for (int i = 0; i < [self->formats count]; ++i)
        {
            NSString * format = [[self->formats objectAtIndex: i] objectForKey: @"format"];

            //---get the first char of each state---
            char alphabet = [format characterAtIndex: 0];

            NSString *uniChar = [NSString stringWithFormat:@"%c", (char)alphabet];

            //---add each letter to the index array---
            if (![indexes containsObject: uniChar])
            {
                [indexes addObject: uniChar];
            }
        } // End of formats loop

        self->setIndex = [NSArray arrayWithArray: indexes];

        NSLog(@"Finished loading formats");

        dispatch_async(dispatch_get_main_queue(), ^{
            strongify(self);
            [self->formatTableView reloadData];
        });
    });
} // End of loadFormats

- (void) viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id <UIViewControllerTransitionCoordinator>)coordinator
{
    NSLog ( @"Will viewWillTransitionToSize" );
	[formatTableView reloadData];
}

#pragma mark -
#pragma UITableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView
{
/*
	// If we are searching, then no titles
	if (aTableView == self.searchDisplayController.searchResultsTableView)
	{
		return [searchResultCells count] > 0 ? 1 : 0;
	} // End of we are searching
*/
    // Return the number of sections.
    return [setIndex count];;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)aTableView
{
	// If we are searching, then no titles
	if (aTableView == self.searchDisplayController.searchResultsTableView)
	{
		return nil;
	} // End of we are searching

    return setIndex;
} // End of sectionIndexTitlesForTableView

- (NSString *) tableView: (UITableView *) aTableView
 titleForHeaderInSection: (NSInteger) section
{
	// If we are searching, then no titles
	if (aTableView == self.searchDisplayController.searchResultsTableView)
	{
		return nil;
	}
	
	// Return our section name
    return [setIndex objectAtIndex: section];
} // End of titleForHeaderInSection

- (NSInteger) tableView: (UITableView *) aTableView
  numberOfRowsInSection: (NSInteger) section
{
	NSInteger rows;

    NSString * alphabet = [setIndex objectAtIndex: section];
    
    NSPredicate * predicate = [NSPredicate predicateWithFormat: @"(format beginswith[c] %@)", alphabet];
    NSArray * results = [formats filteredArrayUsingPredicate: predicate];

    rows = [results count];

    // Return the number of rows in the section.
    return rows;
} // End of numberOfRowsInSection

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleSubtitle
                                      reuseIdentifier: CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }

	if ( aTableView == self.searchDisplayController.searchResultsTableView )
	{

	} // End of searching
    else
    {
        // Get our letter
        NSString *alphabet = [setIndex objectAtIndex: [indexPath section]];

        // Find the cached items
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(format beginswith[c] %@)", alphabet];
        NSArray * temp = [formats filteredArrayUsingPredicate: predicate];
        NSDictionary * format = [temp objectAtIndex: indexPath.row];

        cell.textLabel.text = [format objectForKey: @"format"];

        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
        NSString *formattedOutput = [formatter stringFromNumber: [format objectForKey: @"cardCount"]];

        cell.detailTextLabel.text = [NSString stringWithFormat: @"%@ cards", formattedOutput];
        cell.detailTextLabel.textColor = [[UIColor whiteColor] colorWithAlphaComponent: 0.60];
    }

    return cell;
} // End of cellForRowAtIndexPath

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSLog( @"RootViewController selected an item" );

    [aTableView deselectRowAtIndexPath: indexPath animated: YES];

    NSString * formatString;

	if ( aTableView == self.searchDisplayController.searchResultsTableView )
	{
        
	} // End of searching
    else
    {
        // Get our letter
        NSString *alphabet = [setIndex objectAtIndex: [indexPath section]];
        
        // Find the cached items
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(format beginswith[c] %@)", alphabet];
        NSArray * temp = [formats filteredArrayUsingPredicate: predicate];
        NSDictionary * format = [temp objectAtIndex: indexPath.row];
        
        formatString = [format objectForKey: @"format"];
    }

	MTGSmartSearch * tempSmartSearch = [MTGSmartSearch smartSearchForFormat: formatString];

	CardGridViewController * cardGridViewController;

    cardGridViewController = [[CardGridViewController alloc] init];

	cardGridViewController.hidesBottomBarWhenPushed = YES;
	cardGridViewController.smartSearch = tempSmartSearch;

	[self.navigationController pushViewController: cardGridViewController
                                         animated: YES];
}

@end
