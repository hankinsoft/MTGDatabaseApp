    //
//  AboutViewController.m
//  MTG Deck Builder
//
//  Created by Kyle Hankinson on 10-09-08.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "AboutViewController.h"
#import "AppDelegate.h"
#import "GHRootViewController.h"
@implementation AboutViewController

@synthesize webview;

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

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

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];

	// Load our about page
	[webview loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"about" ofType:@"html"]isDirectory:NO]]];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear: animated];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

@end
