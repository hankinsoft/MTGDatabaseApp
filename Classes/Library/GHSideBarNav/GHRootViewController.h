//
//  GHRootViewController.h
//  GHSidebarNav
//
//  Created by Greg Haines on 11/20/11.
//


typedef void (^RevealBlock)(void);

@interface GHRootViewController : UIViewController

+ (UIBarButtonItem*) generateMenuBarButtonItem: (id) target selector: (SEL) selector;
- (id)initWithTitle:(NSString *)title withRevealBlock:(RevealBlock)revealBlock;

@end
