//
//  MTGLifeCounterEDHPresentationController.m
//  PresentationControllerSample
//
//  Created by Shinichiro Oba on 2014/10/08.
//  Copyright (c) 2014年 bricklife.com. All rights reserved.
//

#import "MTGLifeCounterEDHPresentationController.h"

@interface MTGLifeCounterEDHPresentationController ()

@property (nonatomic, readonly) UIView *dimmingView;

@end

@implementation MTGLifeCounterEDHPresentationController

- (UIView *) dimmingView
{
    UIView *instance = nil;
    if (instance == nil)
    {
        instance = [[UIView alloc] initWithFrame:self.containerView.bounds];
        instance.backgroundColor = [UIColor colorWithWhite:0 alpha:0.7];

        UITapGestureRecognizer * tapGesture =
            [[UITapGestureRecognizer alloc] initWithTarget: self
                                                    action: @selector(dimmingViewTapped:)];

        [instance addGestureRecognizer: tapGesture];
    }

    return instance;
}

- (IBAction) dimmingViewTapped: (UITapGestureRecognizer*) sender
{
    [self.presentingViewController dismissViewControllerAnimated: YES
                                                      completion: NULL];
} // End of dimmingViewTapped:

- (void) presentationTransitionWillBegin
{
    UIView *presentedView = self.presentedViewController.view;
    presentedView.layer.cornerRadius = 20.f;
    presentedView.layer.shadowColor = [[UIColor blackColor] CGColor];
    presentedView.layer.shadowOffset = CGSizeMake(0, 10);
    presentedView.layer.shadowRadius = 10;
    presentedView.layer.shadowOpacity = 0.5;

    self.dimmingView.frame = self.containerView.bounds;
    self.dimmingView.alpha = 0;
    [self.containerView addSubview:self.dimmingView];
    
    [self.presentedViewController.transitionCoordinator animateAlongsideTransition: ^(id<UIViewControllerTransitionCoordinatorContext> context) {
        self.dimmingView.alpha = 1;
    } completion: ^(id<UIViewControllerTransitionCoordinatorContext> context) {
    }];
}

- (void)presentationTransitionDidEnd:(BOOL)completed {
    if (!completed) {
        [self.dimmingView removeFromSuperview];
    }
}

- (void)dismissalTransitionWillBegin {
    [self.presentedViewController.transitionCoordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        self.dimmingView.alpha = 0;
    } completion:nil];
}

- (void)dismissalTransitionDidEnd:(BOOL)completed {
    if (completed) {
        [self.dimmingView removeFromSuperview];
    }
}

- (CGRect)frameOfPresentedViewInContainerView
{
    CGFloat width = 320;
    CGFloat height = 320;
    CGRect frame = CGRectMake((self.containerView.frame.size.width - width) / 2,
                              (self.containerView.frame.size.height - height) / 2,
                              width, height);
    return frame;
}

- (void)containerViewWillLayoutSubviews {
    self.dimmingView.frame = self.containerView.bounds;
    self.presentedView.frame = [self frameOfPresentedViewInContainerView];
}

@end
