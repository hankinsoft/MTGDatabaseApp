//
//  MTGCardSortOptionsViewController.m
//  MTG Deck Builder
//
//  Created by Kyle Hankinson on 11-07-14.
//  Copyright 2011 Hankinsoft. All rights reserved.
//

#import "MTGCardSortOptionsViewController.h"

@implementation MTGCardSortOptionsViewController

@synthesize delegate;

+ (NSDictionary*) sortDictionary
{
    static NSDictionary<NSNumber*, NSString*> * _sort = nil;

    if(nil != _sort) return _sort;

    @synchronized(self)
    {
        if(nil == _sort)
        {
            _sort = @{
                      @(MTGSortByName): @"Name",
                      @(MTGSortByCollectorsNumber): @"Collectors Number",
                      @(MTGSortByConvertedManaCost): @"Converted Mana Cost",
                      @(MTGSortByPrice): @"Price",
                      @(MTGSortByRarity): @"Rarity",
                      @(MTGSortByPower): @"Power",
                      @(MTGSortByToughness): @"Toughness",
                    };
        } // End of _sort
    } // End of lock

    // Finally return our sort
    return _sort;
} // End of sortDictionary


+ (MTGSortMode) sortMode
{
    MTGSortMode sortMode;

    id result = [[NSUserDefaults standardUserDefaults] objectForKey: @"SortMode"];

    // NOTE: In previous versions, sort by and sort mode were stored as strings.
    // If we see a non-number, we will ingore it and default.
    if([result isKindOfClass: [NSNumber class]])
    {
        sortMode = (MTGSortMode) [result unsignedIntegerValue];
    }
    else
    {
        sortMode = MTGSortModeAscending;
    }

    return sortMode;
} // End of sortMode

+ (MTGSortBy) sortBy
{
    MTGSortBy sortBy;

    // NOTE: In previous versions, sort by and sort mode were stored as strings.
    // If we see a string, we will default and ignore it. (And not crash).
    id result = [[NSUserDefaults standardUserDefaults] objectForKey: @"SortBy"];
    if([result isKindOfClass: [NSNumber class]])
    {
        sortBy = (MTGSortBy) [result unsignedIntegerValue];
    }
    else
    {
        sortBy = MTGSortByName;
    }

    return sortBy;
} // End of sortMode

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
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

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Content size
    self.contentSizeForViewInPopover = CGSizeMake(320.0, 600.0);

    // Do any additional setup after loading the view from its nib.
    [self setTitle: @"Sort Mode"];
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger) numberOfSectionsInTableView: (UITableView *) tableView
{
    // NOTE: Scrolling options are disabled
    // return 3;

    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    
    if ( 0 == section )
    {
        return @"Sort By";
    }
    else if ( 1 == section )
    {
        return @"Sort Order";
    }
    else if ( 2 == section )
    {
        return @"Scrolling options";
    }

    return @"";
}

- (NSInteger) tableView: (UITableView *) tableView
  numberOfRowsInSection: (NSInteger) section
{
    if(0 == section)
    {
        return [[MTGCardSortOptionsViewController sortDictionary] count];
    }
    else if(1 == section)
    {
        return 2;
    } // End of else
    else if(2 == section)
    {
        return 2;
    }
    
    return 0;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView: (UITableView *)tableView
         cellForRowAtIndexPath: (NSIndexPath *)indexPath
{
    static UIImage * checkedImage = nil;
    static UIImage * uncheckedImage = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        checkedImage = [UIImage imageNamed:@"SquareCheckbox_yes.png"];
        uncheckedImage = [UIImage imageNamed:@"SquareCheckbox_no.png"];
    });

	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SortIdentifier"];
	if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier: @"SortIdentifier"];
		cell.accessoryType = UITableViewCellAccessoryNone;
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }

    BOOL checked = false;
    if(0 == indexPath.section)
    {
        MTGSortBy rowSortBy = (MTGSortBy) indexPath.row;

        NSString * display =
            [MTGCardSortOptionsViewController sortDictionary][@(indexPath.row)];

        [[cell textLabel] setText: display];

        if(rowSortBy == [MTGCardSortOptionsViewController sortBy])
        {
            checked = YES;
        }

        [[cell imageView] setImage: (checked) ? checkedImage : uncheckedImage];
    } // End of sort by
    else if(1 == indexPath.section)
    {
        if(0 == indexPath.row)
        {
            NSString * sortDisplay =
                [self ascendingSortOrderDisplayForSortBy: [MTGCardSortOptionsViewController sortBy]];

            [[cell textLabel] setText: sortDisplay];

            if(MTGSortModeAscending == [MTGCardSortOptionsViewController sortMode])
            {
                checked = YES;
            }
        }
        else
        {
            NSString * sortDisplay = [self descendingSortOrderDisplayForSortBy: [MTGCardSortOptionsViewController sortBy]];
            [[cell textLabel] setText: sortDisplay];
            if(MTGSortModeDescending == [MTGCardSortOptionsViewController sortMode])
            {
                checked = YES;
            }
        }

        [[cell imageView] setImage: (checked) ? checkedImage : uncheckedImage];
        // sort order
    }
    else if(2 == indexPath.section)
    {
        CGFloat offset = cell.layoutMargins.left;
        if(0 == indexPath.row)
        {
            // Add the Badge cell (with switch), unselectable
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"GridMode"];
            [cell setSelectionStyle: UITableViewCellSelectionStyleNone];
            [cell setAccessoryType: UITableViewCellAccessoryNone];
            [[cell textLabel] setText: @"Horizontal"];

            UISwitch * badgeSwitch = [[UISwitch alloc] initWithFrame: CGRectZero];
            badgeSwitch.translatesAutoresizingMaskIntoConstraints = NO;
            badgeSwitch.on = [[NSUserDefaults standardUserDefaults] integerForKey: @"gridScrollsHorizontal"];
            badgeSwitch.tag = 1;
            [badgeSwitch addTarget: self
                            action: @selector(toggleGridScrollMode:)
                  forControlEvents: UIControlEventValueChanged];
            [cell addSubview: badgeSwitch];
            [badgeSwitch.rightAnchor constraintEqualToAnchor: cell.rightAnchor
                                                    constant: -offset].active = YES;
            [badgeSwitch.centerYAnchor constraintEqualToAnchor: cell.centerYAnchor].active = YES;
            [badgeSwitch sizeToFit];
        } // End of row 0
        else if(1 == indexPath.row)
        {
            // Add the Badge cell (with switch), unselectable
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"GridMode"];
            [cell setSelectionStyle: UITableViewCellSelectionStyleNone];
            [cell setAccessoryType: UITableViewCellAccessoryNone];
            [[cell textLabel] setText: @"Paging"];

            UISwitch * badgeSwitch = [[UISwitch alloc] initWithFrame: CGRectZero];
            badgeSwitch.translatesAutoresizingMaskIntoConstraints = NO;
            badgeSwitch.on = [[NSUserDefaults standardUserDefaults] integerForKey: @"gridScrollsPaged"];
            badgeSwitch.tag = 1;
            [badgeSwitch addTarget:self action:@selector(toggleGridPageMode:) forControlEvents:UIControlEventValueChanged];
            [cell addSubview: badgeSwitch];
            [badgeSwitch.rightAnchor constraintEqualToAnchor: cell.rightAnchor
                                                    constant: -offset].active = YES;
            [badgeSwitch.centerYAnchor constraintEqualToAnchor: cell.centerYAnchor].active = YES;
            [badgeSwitch sizeToFit];
        } // End of row 1
    }

    return cell;
}

- (void)      tableView: (UITableView *) tableView
didSelectRowAtIndexPath: (NSIndexPath *) indexPath
{
    if(0 == indexPath.section)
    {
        NSNumber * value = @(indexPath.row);
        [[NSUserDefaults standardUserDefaults] setObject: value
                                                  forKey: @"SortBy"];
    } // End of selected a sort by
    else
    {
        if(0 == indexPath.row)
        {
            [[NSUserDefaults standardUserDefaults] setObject: @(MTGSortModeAscending)
                                                      forKey: @"SortMode"];
        }
        else
        {
            [[NSUserDefaults standardUserDefaults] setObject: @(MTGSortModeDescending)
                                                      forKey: @"SortMode"];
        }
    }

    if(nil != delegate)
    {
        [delegate sortingChanged];
    } // End of delegateChanged

    // Reload the table
    [tableView reloadData];
} // End of didSelectRowAtIndexPath

- (NSString*) ascendingSortOrderDisplayForSortBy: (MTGSortBy) sortBy
{
    if(MTGSortByName == sortBy)
    {
        return @"Ascending (A-Z)";
    }
    else if(MTGSortByConvertedManaCost == sortBy)
    {
        return @"Lowest first";
    }
    else if(MTGSortByPrice == sortBy)
    {
        return @"Cheapest first";
    }
    else if(MTGSortByRarity == sortBy)
    {
        return @"Common first";
    }

    return @"Ascending";
} // End of ascendingSortOrderDisplayForSortBy

- (NSString*) descendingSortOrderDisplayForSortBy: (MTGSortBy) sortBy
{
    if(MTGSortByName == sortBy)
    {
        return @"Descending (Z-A)";
    }
    else if(MTGSortByConvertedManaCost == sortBy)
    {
        return @"Highest first";
    }
    else if(MTGSortByPrice == sortBy)
    {
        return @"Most expensive first";
    }
    else if(MTGSortByRarity == sortBy)
    {
        return @"Rarest first";
    }

    return @"Descending";
} // End of descendingSortOrderDisplayForSortBy

#pragma mode -
#pragma mode Events

- (void) toggleGridScrollMode: (UISwitch*) sender
{
    // Toggle our notifications, but we will not do any work until the app is closeing
	[[NSUserDefaults standardUserDefaults] setBool: [sender isOn] forKey: @"gridScrollsHorizontal"];
	NSLog( @"toggleGridScrollMode: sender (%@), isOn %d",  sender, [sender isOn] );

    if(nil != delegate)
    {
        [delegate scrollingChanged];
    } // End of delegateChanged
}

- (void) toggleGridPageMode: (UISwitch*) sender
{
    // Toggle our notifications, but we will not do any work until the app is closeing
	[[NSUserDefaults standardUserDefaults] setBool: [sender isOn] forKey: @"gridScrollsPaged"];
    NSLog( @"toggleGridPageMode: sender = %ld, isOn %d",  (long)[sender tag], [sender isOn] );

    if(nil != delegate)
    {
        [delegate scrollingChanged];
    } // End of delegateChanged
}

#pragma mode -

@end
