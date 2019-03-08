//
//  SQLProNavigationController.m
//  SQLPro (iOS)
//
//  Created by Kyle Hankinson on 2016-11-30.
//  Copyright © 2016 Hankinsoft Development, Inc. All rights reserved.
//

#import "MTGNavigationController.h"

@interface MTGNavigationController ()

@end

@implementation MTGNavigationController
{
}

- (id) initWithRootViewController:(UIViewController *)rootViewController
{
    self = [super initWithRootViewController: rootViewController];
    if(self)
    {
    } // End of self

    return self;
} // End of initWithRootViewController

- (UIStatusBarStyle) preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
} // End of preferredStatusBarStyle

- (UIInterfaceOrientationMask) supportedInterfaceOrientations
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        return UIInterfaceOrientationMaskLandscape;
    }

    return UIInterfaceOrientationMaskAll;
} // End of supportedInterfaceOrientations

@end
