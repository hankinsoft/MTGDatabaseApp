//
//  UIMultiCheckboxViewController.m
//  MTG Deck Builder
//
//  Created by Kyle Hankinson on 10-09-11.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "UIMultiCheckboxViewController.h"

@implementation UIMultiCheckboxViewController

@synthesize checkboxItems;

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;

    // No back button
    [self.navigationItem setHidesBackButton: YES animated: NO];

    UIBarButtonItem * saveBarButtonButtonItem = [[UIBarButtonItem alloc]
                                                 initWithTitle: @"Save" 
                                                 style: UIBarButtonItemStylePlain 
                                                 target: self 
                                                 action: @selector(onSave:)];

    [self.navigationItem setRightBarButtonItem: saveBarButtonButtonItem];
}


/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/
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
#pragma mark Button Actions

- (void) onSave: (id) sender
{
    if(self.onCheckboxAction)
    {
        self.onCheckboxAction(checkboxItems);
    }

    [self.navigationController popViewControllerAnimated: YES];
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [checkboxItems count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView: (UITableView *) tableView
         cellForRowAtIndexPath: (NSIndexPath *) indexPath
{
    static UIImage * checkedImage = nil;
    static UIImage * uncheckedImage = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        checkedImage = [UIImage imageNamed:@"SquareCheckbox_yes.png"];
        uncheckedImage = [UIImage imageNamed:@"SquareCheckbox_no.png"];
    });

    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
	{
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
		cell.accessoryType = UITableViewCellAccessoryNone;
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }

	// Get our dictionary item
	CheckboxObject * checkboxObject = [checkboxItems objectAtIndex: indexPath.row];
	[cell.textLabel setText: [checkboxObject display]];

	BOOL checked = [checkboxObject checked];

/*
	UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
	CGRect frame = CGRectMake(0.0, 0.0, image.size.width, image.size.height);
	button.frame = frame;	// match the button's size with the image size

	[button setBackgroundImage:image forState:UIControlStateNormal];

	// set the button's target to this table view controller so we can interpret touch events and map that to a NSIndexSet
	[button addTarget:self action:@selector(checkButtonTapped:event:) forControlEvents:UIControlEventTouchUpInside];
	button.backgroundColor = [UIColor clearColor];
	cell.accessoryView = button;
*/
    [[cell imageView] setImage: (checked) ? checkedImage : uncheckedImage];

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
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
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
    // Get our checkbox object and switch the checked
	CheckboxObject * checkboxObject = [checkboxItems objectAtIndex: indexPath.row];
    [checkboxObject setChecked: !checkboxObject.checked];

    // Need our table to reload
    [aTableView reloadData];
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

@end

