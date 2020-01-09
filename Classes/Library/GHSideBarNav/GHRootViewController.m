//
//  GHRootViewController.m
//  GHSidebarNav
//
//  Created by Greg Haines on 11/20/11.
//

#import "GHRootViewController.h"

#pragma mark Private Interface
@interface GHRootViewController ()
- (void)revealSidebar;
@end

#pragma mark Implementation
@implementation GHRootViewController{
@private
    RevealBlock _revealBlock;
}


+ (UIBarButtonItem *) generateMenuBarButtonItem: (id) target
                                       selector: (SEL) selector
{
    UIBarButtonItem * menuBarButtonItem = [[UIBarButtonItem alloc] initWithImage: [UIImage imageNamed: @"SideBarMenu"]
                                                                           style: UIBarButtonItemStylePlain
                                                                          target: target
                                                                          action: selector];
    
    return menuBarButtonItem;
} // End of generateMenuBarButtonItem:selector:

#pragma mark Memory Management
- (id)initWithTitle:(NSString *)title withRevealBlock:(RevealBlock)revealBlock {
    if (self = [super initWithNibName:nil bundle:nil]) {
        self.title = title;
        _revealBlock = [revealBlock copy];
        self.navigationItem.leftBarButtonItem =
        [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                                                      target:self
                                                      action:@selector(revealSidebar)];
    }
    return self;
}

#pragma mark UIViewController
- (void) viewDidLoad
{
    [super viewDidLoad];
    self.view.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    self.view.backgroundColor = [UIColor lightGrayColor];

    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)])
    {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
}

- (void)revealSidebar {
    _revealBlock();
}

@end
