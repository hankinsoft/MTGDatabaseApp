//
//  CardLinksViewController.m
//  MTG Deck Builder
//
//  Created by Kyle Hankinson on 12-06-01.
//  Copyright (c) 2012 Hankinsoft. All rights reserved.
//

#import "CardLinksViewController.h"
#import "MTGCard.h"

@interface CardLinksViewController ()

@end

@implementation CardLinksViewController

@synthesize card;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear: animated];
    [self setTitle: @"Links"];
} // End of viewWillAppear

#pragma mark -
#pragma UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(0 == section)
    {
        return 2;
    }
    else if(1 == section)
    {
        return 1;
    }
    else if(2 == section)
    {
        return 1;
    }
    else if(3 == section)
    {
        return 1;
    }

    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if(0 == section)
    {
        return @"Gatherer";
    }
    else if(1 == section)
    {
        return @"Starcity.com";
    }
    else if(2 == section)
    {
        return @"TCGPlayer.com";
    }
    else if(3 == section)
    {
        return @"MagicCards.info";
    }
    
    return @"";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Gatherer"];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier: @"Gatherer"];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }

    if(0 == indexPath.section)
    {
        if(0 == indexPath.row)
        {
            cell.textLabel.text = @"Details";
        }
        else if(1 == indexPath.row)
        {
            cell.textLabel.text = @"Discussion";
        }
    }
    else if(1 == indexPath.section)
    {
        if(0 == indexPath.row)
        {
            cell.textLabel.text = @"Search for this card";
        }
    }
    else if(2 == indexPath.section)
    {
        if(0 == indexPath.row)
        {
            cell.textLabel.text = @"Search for this card";
        }
    }
    else if(3 == indexPath.section)
    {
        if(0 == indexPath.row)
        {
            cell.textLabel.text = @"Search for this card";
        }
    }
    
    return cell;
}
#pragma mark -
#pragma mark UITableViewDelegate

- (void) tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath: indexPath animated: YES];

    NSString * url = nil;
    if(0 == indexPath.section)
    {
        if(0 == indexPath.row)
        {
            url =
            [NSString stringWithFormat: @"http://gatherer.wizards.com/Pages/Card/Details.aspx?multiverseid=%ld", (long)card.multiverseId];
        }
        else if(1 == indexPath.row)
        {
            url =
            [NSString stringWithFormat: @"http://gatherer.wizards.com/Pages/Card/Discussion.aspx?multiverseid=%ld", (long)card.multiverseId];
        }
    }
    else if(1 == indexPath.section)
    {
        if(0 == indexPath.row)
        {
            url = [NSString stringWithFormat: @"http://sales.starcitygames.com/cardsearch.php?singlesearch=%@", [card.name stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding]];
        }
    }
    else if(2 == indexPath.section)
    {
        if(0 == indexPath.row)
        {
            url = [NSString stringWithFormat: @"http://magic.tcgplayer.com/db/search_result.asp?Name=%@", [card.name stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding]];
        }
    }
    else if(3 == indexPath.section)
    {
        if(0 == indexPath.row)
        {
            url = [NSString stringWithFormat: @"http://magiccards.info/query?q=%@&v=card&s=cname", [card.name stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding]];
        }
    }

    NSLog(@"Want to launch: %@", url);
    // Launch the browser
    [[UIApplication sharedApplication] openURL: [NSURL URLWithString: url]];
}
#pragma mark -
@end
