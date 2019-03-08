//
//  MTGBrowseAbilitiesViewController.m
//  MTG Deck Builder
//
//  Created by Kyle Hankinson on 2018-03-22.
//  Copyright © 2018 Hankinsoft Development, Inc. All rights reserved.
//

#import "MTGBrowseAbilitiesViewController.h"
#import "HSSearchBarWithSpinner.h"
#import "MTGSmartSearch.h"
#import "CardGridViewController.h"

@interface MTGAbility : NSObject

@property(nonatomic,retain) NSString * name;
@property(nonatomic,assign) NSUInteger cardCount;

@end

@implementation MTGAbility
@end

@interface MTGBrowseAbilitiesViewController ()<UISearchBarDelegate,UITableViewDataSource,UITableViewDelegate>
{
    HSSearchBarWithSpinner * searchBar;
    UITableView            * tableView;
}
@end

@implementation MTGBrowseAbilitiesViewController
{
    RevealBlock             _revealBlock;
}

static NSArray<MTGAbility*>                             * abilities = nil;
static NSDictionary<NSString*,NSArray<MTGAbility*>*>    * letterLookup = nil;

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
    self.title = @"Abilities";
    self.navigationController.navigationBar.barStyle = [AppDelegate barButtonStyle];
    self.navigationController.navigationBar.translucent = NO;

    [super viewDidLoad];

    UIColor * backgroundColor = SQLProAppearanceManager.sharedInstance.darkTableBackgroundColor;

    tableView = [[UITableView alloc] initWithFrame: CGRectZero
                                             style: UITableViewStyleGrouped];
    tableView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview: tableView];
    [tableView.leftAnchor constraintEqualToAnchor: self.view.leftAnchor].active = YES;
    [tableView.rightAnchor constraintEqualToAnchor: self.view.rightAnchor].active = YES;
    [tableView.topAnchor constraintEqualToAnchor: self.view.topAnchor].active = YES;
    [tableView.bottomAnchor constraintEqualToAnchor: self.view.bottomAnchor].active = YES;
    tableView.dataSource = self;
    tableView.delegate = self;

    searchBar = [[HSSearchBarWithSpinner alloc] initWithFrame:CGRectMake(0, 0, 0, 56.0f)];
    searchBar.textColor = [UIColor whiteColor];
    searchBar.autocorrectionType   = UITextAutocorrectionTypeNo;
    searchBar.searchBarStyle       = UISearchBarStyleMinimal;
    searchBar.tintColor            = [UIColor darkGrayColor];   // Tint color is the entered text color + cancel button color
    searchBar.barTintColor         = backgroundColor;
    searchBar.placeholder          = @"Search";
    searchBar.delegate = self;
    tableView.tableHeaderView = searchBar;
}

- (void) viewWillAppear: (BOOL) animated
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSMutableArray * mutableAbilities = @[].mutableCopy;
        [[AppDelegate databaseQueue] inDatabase:^(FMDatabase * _Nonnull db) {
            FMResultSet * results = [db executeQuery: @"SELECT name, cardCount FROM ability ORDER BY name ASC"];
            while([results next])
            {
                MTGAbility * ability = [[MTGAbility alloc] init];
                ability.name = [results stringForColumnIndex: 0];
                ability.cardCount = [results intForColumnIndex: 1];

                [mutableAbilities addObject: ability];
            }

            abilities = mutableAbilities;
        }];

        // Our set index
        NSMutableDictionary<NSString*,NSMutableArray<MTGAbility*>*> * _letterLookup = @{}.mutableCopy;
        for(MTGAbility * ability in abilities)
        {
            NSString * abilityName = ability.name;

            char alphabet = [abilityName characterAtIndex: 0];
            NSString *uniChar = [NSString stringWithFormat: @"%c", (char)alphabet];
            
            NSMutableArray<MTGAbility*> * entries = _letterLookup[uniChar];
            if(nil == entries)
            {
                entries = @[].mutableCopy;
                _letterLookup[uniChar] = entries;
            }

            [entries addObject: ability];
        } // End of formats loop

        letterLookup = _letterLookup;
    });

    [super viewWillAppear: animated];
    [searchBar setText: @""];
} // End of viewWillAppear:

- (NSDictionary<NSString*,NSArray<MTGAbility*>*>*) tableData
{
    return letterLookup;
}

- (NSInteger) numberOfSectionsInTableView: (UITableView *) tableView
{
    return self.tableData.allKeys.count;
} // End of numberOfSectionsInTableView:

- (NSArray *)sectionIndexTitlesForTableView: (UITableView *) aTableView
{
    NSArray * sortedKeys = [self.tableData.allKeys sortedArrayUsingSelector: @selector(compare:)];
    return sortedKeys;
} // End of sectionIndexTitlesForTableView

- (NSString *) tableView: (UITableView *) aTableView
 titleForHeaderInSection: (NSInteger) section
{
    NSArray * sortedKeys = [self.tableData.allKeys sortedArrayUsingSelector: @selector(compare:)];

    // Return our section name
    return sortedKeys[section];
} // End of titleForHeaderInSection

- (NSInteger) tableView: (UITableView *)aTableView
  numberOfRowsInSection: (NSInteger)section
{
    NSArray * sortedKeys = [self.tableData.allKeys sortedArrayUsingSelector: @selector(compare:)];
    NSArray<MTGAbility*>* abilities = self.tableData[sortedKeys[section]];

    NSInteger count = abilities.count;
    return count;
} // End of numberOfRowsInSection

- (UITableViewCell *)tableView: (UITableView *) aTableView
         cellForRowAtIndexPath: (NSIndexPath *) indexPath
{
#define kCellIdentifier         @"BrowseAbilities"

    UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier: kCellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleSubtitle
                                      reuseIdentifier: kCellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }

    NSArray * sortedKeys = [self.tableData.allKeys sortedArrayUsingSelector: @selector(compare:)];
    NSArray<MTGAbility*>* abilities = self.tableData[sortedKeys[indexPath.section]];
    MTGAbility * ability = abilities[indexPath.row];

    cell.textLabel.text = ability.name;
    cell.detailTextLabel.text = [NSString stringWithFormat: @"%ld card%@", (long) ability.cardCount, (ability.cardCount ? @"s" : @"")];
    cell.detailTextLabel.textColor = [[UIColor whiteColor] colorWithAlphaComponent: 0.60];

    return cell;
} // End of cellForRowAtIndexPath

- (void)      tableView: (UITableView *) aTableView
didSelectRowAtIndexPath: (NSIndexPath *) indexPath
{
	NSLog( @"RootViewController selected an item" );

	// Kill the keyboard
	[searchBar resignFirstResponder];

	// Deselect
	[aTableView deselectRowAtIndexPath: indexPath
                              animated:YES];
    [aTableView reloadData];

    NSArray * sortedKeys = [self.tableData.allKeys sortedArrayUsingSelector: @selector(compare:)];
    NSArray<MTGAbility*>* abilities = self.tableData[sortedKeys[indexPath.section]];
    MTGAbility * ability = abilities[indexPath.row];

    MTGSmartSearch * tempSmartSearch = [[MTGSmartSearch alloc] init];
    tempSmartSearch.abilityAny = @[ability.name];

	CardGridViewController * cardGridViewController;
    cardGridViewController = [[CardGridViewController alloc] init];

	cardGridViewController.hidesBottomBarWhenPushed = YES;
	cardGridViewController.smartSearch = tempSmartSearch;

	[self.navigationController pushViewController: cardGridViewController
                                         animated: YES];
}

@end
