//
//  RulesChildrenViewController.m
//  MTG Deck Builder
//
//  Created by Kyle Hankinson on 12-06-04.
//  Copyright (c) 2012 Hankinsoft. All rights reserved.
//

#import "RulesChildrenViewController.h"
#import "Children.h"

#define CELL_CONTENT_WIDTH          320.0f
#define DESCRIPTION_FONT_SIZE       16
#define CELL_CONTENT_MARGIN         10.0f

@interface RulesChildrenViewController ()

@end

@implementation RulesChildrenViewController

@synthesize children;

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
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear: animated];
 
    NSLog(@"TEST: %f", tableView.frame.size.width);
    [self updateCells];
    [tableView reloadData];
}

- (void) updateCells
{
    NSMutableArray * mutableCells = [NSMutableArray array];
    
    for(NSInteger i = 0; i < children.children.count; ++i)
    {
        Children * subChildren = [children.children objectAtIndex: i];

        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier: @"Rules"];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.text = [NSString stringWithFormat: @"%@.", subChildren.section];
        cell.textLabel.textColor = [UIColor colorWithRed: 91 / 255.0 green: 111 / 255.0 blue:174 / 255.0 alpha: 1];

        cell.detailTextLabel.text = subChildren.text;
        cell.detailTextLabel.textColor = [[UIColor whiteColor] colorWithAlphaComponent: 0.60];

        cell.detailTextLabel.numberOfLines = 0;
        [cell.detailTextLabel sizeToFit];
        cell.detailTextLabel.lineBreakMode = UILineBreakModeWordWrap;
        cell.detailTextLabel.minimumFontSize = DESCRIPTION_FONT_SIZE;
        cell.detailTextLabel.font = [UIFont systemFontOfSize: DESCRIPTION_FONT_SIZE];

        cell.accessoryType  = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;

        [mutableCells addObject: cell];

        // Loop though our childs children
        for(NSInteger subIndex = 0; subIndex < subChildren.children.count; ++subIndex)
        {
            Children * subSubChildren = [subChildren.children objectAtIndex: subIndex];

            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier: @"Rules"];
            cell.backgroundColor = [UIColor colorWithRed: 0.9 green: 0.9 blue:0.9 alpha: 0.50];

            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.textLabel.text = [NSString stringWithFormat: @"%@.", subSubChildren.section];
            cell.textLabel.textColor = [UIColor colorWithRed: 91 / 255.0 green: 111 / 255.0 blue:174 / 255.0 alpha: 1];
            cell.detailTextLabel.text = subSubChildren.text;
            cell.detailTextLabel.textColor = [UIColor blackColor];
            cell.detailTextLabel.numberOfLines = 0;
            [cell.detailTextLabel sizeToFit];
            cell.detailTextLabel.lineBreakMode = UILineBreakModeWordWrap;
            cell.detailTextLabel.minimumFontSize = DESCRIPTION_FONT_SIZE;
            cell.detailTextLabel.font = [UIFont systemFontOfSize: DESCRIPTION_FONT_SIZE];
            cell.detailTextLabel.textColor = [[UIColor whiteColor] colorWithAlphaComponent: 0.60];
            cell.accessoryType  = UITableViewCellAccessoryNone;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;

            [mutableCells addObject: cell];            
        } // End of inner loop
    } // End of children loop

    cellArray = [NSArray arrayWithArray: mutableCells];
}

#pragma mark -
#pragma mark UITableViewDataSource

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return cellArray.count;
} // End of tableView: numberOfRowsInSection:

- (UITableViewCell*) tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [cellArray objectAtIndex: indexPath.row];
}

#pragma mark -
#pragma mark UITableViewDelegate

- (CGFloat)   tableView: (UITableView *) tableView
heightForRowAtIndexPath: (NSIndexPath *) indexPath
{
    double width;

    if(INTERFACE_IS_PHONE)
    {
        width = 300.0f;
    }
    else
    {
        width = 678.0f;
    }

    UITableViewCell * cell = [cellArray objectAtIndex: indexPath.row];

    CGSize size1 = [cell.textLabel.text sizeWithFont: cell.textLabel.font
                                   constrainedToSize: CGSizeMake(self.view.frame.size.width - (8 * 3), 1000.0f)];

    CGSize size2 = [cell.detailTextLabel.text sizeWithFont: cell.detailTextLabel.font
                                         constrainedToSize: CGSizeMake(self.view.frame.size.width - (8 * 3), 1000.0f)];

    CGFloat height = MAX(size1.height + size2.height, 44.0f);
        
    return height + (CELL_CONTENT_MARGIN * 2);
}

#pragma mark -
@end
