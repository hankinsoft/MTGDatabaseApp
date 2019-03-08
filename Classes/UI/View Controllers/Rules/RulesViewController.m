//
//  RulesViewController.m
//  MTG Deck Builder
//
//  Created by Kyle Hankinson on 12-06-01.
//  Copyright (c) 2012 Hankinsoft. All rights reserved.
//

#import "RulesViewController.h"
#import "MTGRules.h"
#import "Children.h"

#import "RulesChildrenViewController.h"

@interface RulesViewController ()<UISearchBarDelegate>

@end

@implementation RulesViewController

- (id) initWithRevealBlock: (RevealBlock) revealBlock
{
    if (self = [super initWithNibName: nil
                               bundle: nil])
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

- (void) loadRules
{
    NSString* path = [[NSBundle mainBundle] pathForResource: @"MTGRules" ofType: @"json"];
    NSString* data = [NSString stringWithContentsOfFile: path
                                               encoding: NSUTF8StringEncoding error: NULL];
    
    NSError * error = nil;
    rules = [MTGRules MTGRulesArrayWithJSONString: data usingEncoding:NSUTF8StringEncoding error: &error];
    NSLog(@"Retreived rules: %p. Error: %@", rules, [error localizedDescription]);
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    [self loadRules];

    // Do any additional setup after loading the view from its nib.
    self.title = @"Rules";
    self.navigationController.navigationBar.barStyle = [AppDelegate barButtonStyle];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear: animated];
    [tableView reloadData];
}

#pragma mark -
#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSLog(@"There are %ld rules", (unsigned long)rules.count);
    return [rules count];
} // End of numberOfSectionsInTableView

- (NSString*) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    MTGRules * rule = [rules objectAtIndex: section];

    return [NSString stringWithFormat: @"%@. %@", [rule section], [rule text]];
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [(MTGRules*)[rules objectAtIndex: section] children].count;
}

- (UITableViewCell*) tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:@"Rules"];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier: @"Rules"];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }

    // Get our rule
    MTGRules * rule = [rules objectAtIndex: indexPath.section];
    Children * children = [rule.children objectAtIndex: indexPath.row];

    cell.textLabel.text = [NSString stringWithFormat: @"%@. %@", children.section, children.text];

    return cell;
} // End of tableViewCell

#pragma mark -
#pragma mark UITableViewDelegate

- (void)      tableView: (UITableView *) aTableView
didSelectRowAtIndexPath: (NSIndexPath *) indexPath
{
    // Deselect it
    [aTableView deselectRowAtIndexPath: indexPath animated: YES];

	RulesChildrenViewController * rulesChildrenViewController =
        [[RulesChildrenViewController alloc] initWithNibName: @"RulesChildrenViewController" bundle: nil];

    // Get our rule
    MTGRules * rule = [rules objectAtIndex: indexPath.section];
    Children * children = [rule.children objectAtIndex: indexPath.row];
    rulesChildrenViewController.title = [NSString stringWithFormat: @"%@. %@", children.section, children.text];
    rulesChildrenViewController.children = children;
    [self.navigationController pushViewController: rulesChildrenViewController animated:YES];
}

#pragma mark -
#pragma mark UISearchBarDelegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    NSString * searchFor = searchBar.text;

    NSLog(@"Want to search rules for: %@", searchBar.text);

    NSMutableArray * results = [NSMutableArray array];

    for(MTGRules * rule in rules)
    {
        if(NSNotFound != [rule.text rangeOfString: searchFor options: NSCaseInsensitiveSearch].location)
        {
            [results addObject: @"test"];
        }

        for(Children * child in rule.children)
        {
            [self doSearch: searchFor intoResults: results fromChild: child];
        }
    }
    
    NSLog(@"Finished searching. %lu results.", (unsigned long)results.count);
}

- (void) doSearch: (NSString*) searchFor intoResults: (NSMutableArray*) results fromChild: (Children*) child
{
    if(NSNotFound != [child.text rangeOfString: searchFor options: NSCaseInsensitiveSearch].location)
    {
        [results addObject: @"test"];
    }
    
    for(Children * subChild in child.children)
    {
        [self doSearch: searchFor intoResults: results fromChild: subChild];
    } // End of children loop
}

- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar
{
    NSLog(@"Search cancelled");
}

@end
