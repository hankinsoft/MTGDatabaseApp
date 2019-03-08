//
//  SakeToRootViewController.m
//  StarboundHelper
//
//  Created by Kyle Hankinson on 2014-04-24.
//  Copyright (c) 2014 com.hankinsoft.ios. All rights reserved.
//

#import "ShakeToRootViewController.h"

@interface ShakeToRootViewController ()

@end

@implementation ShakeToRootViewController

-(BOOL)canBecomeFirstResponder
{
    return YES;
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self resignFirstResponder];
    [super viewWillDisappear:animated];
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    if (motion == UIEventSubtypeMotionShake)
    {
        NSLog(@"Shook. Popping to root view controller.");
        [self.navigationController popToRootViewControllerAnimated: YES];
    }
}

@end
