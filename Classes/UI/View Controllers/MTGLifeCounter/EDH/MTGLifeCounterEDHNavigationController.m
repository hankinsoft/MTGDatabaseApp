//
//  MTGLifeCounterEDHNavigationController.m
//  MTG Deck Builder
//
//  Created by kylehankinson on 2018-08-16.
//  Copyright © 2018 Hankinsoft Development, Inc. All rights reserved.
//

#import "MTGLifeCounterEDHNavigationController.h"
#import "MTGLifeCounterEDHPresentationController.h"

@interface MTGLifeCounterEDHNavigationController ()<UIViewControllerTransitioningDelegate>

@end

@implementation MTGLifeCounterEDHNavigationController

- (instancetype) initWithRootViewController:(UIViewController *)rootViewController
{
    self = [super initWithRootViewController: rootViewController];
    
    if (self)
    {
        if ([self respondsToSelector: @selector(setTransitioningDelegate:)])
        {
            self.modalPresentationStyle = UIModalPresentationCustom;
            self.transitioningDelegate = self;
        }
    }
    
    return self;
} // End of init

#pragma mark -
#pragma mark UIViewControllerTransitioningDelegate

- (UIPresentationController *)presentationControllerForPresentedViewController:(UIViewController *)presented
                                                      presentingViewController:(UIViewController *)presenting
                                                          sourceViewController:(UIViewController *)source
{
    return [[MTGLifeCounterEDHPresentationController alloc] initWithPresentedViewController: presented
                                                                   presentingViewController: presenting];
}

@end
