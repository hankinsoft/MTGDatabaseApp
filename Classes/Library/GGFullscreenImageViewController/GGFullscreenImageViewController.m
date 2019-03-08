//
//  GGFullscreenImageViewController.m
//  TFM
//
//  Created by John Wu on 6/5/12.
//  Copyright (c) 2012 TFM. All rights reserved.
//

#import "GGFullscreenImageViewController.h"
#import <QuartzCore/QuartzCore.h>

static const double kAnimationDuration = 0.3;

@interface GGFullscreenImageViewController () <UIScrollViewDelegate, CAAnimationDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) UIImageView *imageView;

- (void) onDismiss;

@end

@implementation GGFullscreenImageViewController
{
}

- (id) init
{
    self = [super init];

    if (self)
    {
        self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        self.supportedOrientations = UIInterfaceOrientationMaskAll;
    }

    return self;
}

#pragma mark - View Life Cycle

- (void) loadView
{
    self.view = [[UIView alloc] initWithFrame: [[UIScreen mainScreen] bounds]];
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.view.backgroundColor = [UIColor blackColor];

    self.scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    self.scrollView.delegate = self;
    self.scrollView.maximumZoomScale = 2;
    self.scrollView.autoresizingMask = self.view.autoresizingMask;
    [self.scrollView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];

    [self.view addSubview: self.scrollView];
    
    self.containerView = [[UIView alloc] initWithFrame:self.scrollView.bounds];
    self.containerView.autoresizingMask = self.view.autoresizingMask;
    self.containerView.backgroundColor = [UIColor blackColor];
    [self.scrollView addSubview:self.containerView];
    self.scrollView.bounces = YES;
    self.scrollView.alwaysBounceVertical = YES;
    self.scrollView.alwaysBounceHorizontal = YES;

    self.imageView = [[UIImageView alloc] initWithFrame: self.containerView.bounds];

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget: self
                                                                          action: @selector(onDismiss)];

    [self.scrollView addGestureRecognizer: tap];
}

- (void) observeValueForKeyPath:(NSString *)keyPath
                       ofObject:(id)object
                         change:(NSDictionary *)change
                        context:(void *)context
{
    static NSDate * canCloseDate = nil;

    if(object != self.scrollView)
    {
        return;
    } // End of not the scrollView

    // Only allow drag to close when not zoomed
    if(1 != self.scrollView.zoomScale)
    {
        // Don't allow auto-closing until future. This is to prevent accidental closing due to offsets during resizing.
        canCloseDate = [[NSDate date] dateByAddingTimeInterval: 1];
        return;
    }

    if(self.scrollView.isDecelerating)
    {
        return;
    }

    // Our animation is happening
    if(!self.liftedImageView.hidden)
    {
        return;
    }

    // Disable closing until one second after zoom has finished.
    if(nil != canCloseDate && canCloseDate.timeIntervalSince1970 > [NSDate date].timeIntervalSince1970)
    {
        return;
    } // End of cannot close yet

    /// Since iOS 11, the "top" position of a `UIScrollView` is not when
    /// its `contentOffset.y` is 0, but when `contentOffset.y` added to it's
    /// `safeAreaInsets.top` is 0, so that is adjusted for here.
    CGFloat vOffset = 0;
    CGFloat hOffset = 0;
    if(@available(iOS 11, *))
    {
        vOffset = self.scrollView.contentOffset.y + self.scrollView.contentInset.top + self.scrollView.safeAreaInsets.top;
        hOffset = self.scrollView.contentOffset.x + self.scrollView.contentInset.left + self.scrollView.safeAreaInsets.left;
    }
    else
    {
        vOffset = self.scrollView.contentOffset.y + self.scrollView.contentInset.top;
        hOffset = self.scrollView.contentOffset.x + self.scrollView.contentInset.left;
    }

    if(0 == vOffset)
    {
        return;
    }

    // Outside our range = close
    if(vOffset < -100 || vOffset > 100 ||
       hOffset < -100 || hOffset > 100)
    {
        [self onDismiss];
        return;
    }
}

- (void) viewWillAppear: (BOOL) animated
{
    [super viewWillAppear:animated];

    UIApplication *app = [UIApplication sharedApplication];
    UIView *window = [app keyWindow];
    window.backgroundColor = [UIColor blackColor];

    [app setStatusBarHidden: YES
              withAnimation: UIStatusBarAnimationFade];

    // imageView configuration
    self.imageView.image = self.liftedImageView.image;
    self.imageView.contentMode = self.liftedImageView.contentMode;
    self.imageView.clipsToBounds = self.liftedImageView.clipsToBounds;

    CGRect startFrame = [self.liftedImageView convertRect: self.liftedImageView.bounds
                                                   toView:window];
    self.imageView.layer.position = CGPointMake(startFrame.origin.x + floorf(startFrame.size.width/2), startFrame.origin.y + floorf(startFrame.size.height/2));

    self.imageView.layer.bounds = CGRectMake(0, 0, startFrame.size.width, startFrame.size.height);

    [window addSubview: self.imageView];
}

- (void) viewDidAppear: (BOOL) animated
{
    [super viewDidAppear: animated];
    
    UIApplication *app = [UIApplication sharedApplication];
    UIView *window = [app keyWindow];

    CGRect endFrame = [self.containerView convertRect:self.containerView.bounds toView:window];

    CABasicAnimation *center = [CABasicAnimation animationWithKeyPath:@"position"];
    center.fromValue = [NSValue valueWithCGPoint:self.imageView.layer.position];
    center.toValue = [NSValue valueWithCGPoint:CGPointMake(floorf(endFrame.size.width/2),floorf(endFrame.size.height/2))];
    
    CABasicAnimation *scale = [CABasicAnimation animationWithKeyPath:@"bounds"];
    scale.fromValue = [NSValue valueWithCGRect:self.imageView.layer.bounds];

    CGSize imageSize = self.liftedImageView.image.size;
    CGFloat maxHeight = 0;
    CGFloat maxWidth = 0;

    // 570/323 = 320/y
    maxHeight = MIN(endFrame.size.height,endFrame.size.width*imageSize.height/imageSize.width);
    maxWidth = MIN(endFrame.size.width, endFrame.size.height*imageSize.width/imageSize.height);
    scale.toValue = [NSValue valueWithCGRect:CGRectMake(0, 0, maxWidth, maxHeight)];

    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.duration = kAnimationDuration;
    group.delegate = self;
    group.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];    
    group.animations = @[scale,center];
    [group setValue:@"expand" forKey:@"type"];

    self.imageView.layer.position = [center.toValue CGPointValue];
    self.imageView.layer.bounds = [scale.toValue CGRectValue];
    [self.imageView.layer addAnimation:group forKey:nil];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    UIApplication *app = [UIApplication sharedApplication];
    UIWindow *window = [app keyWindow];

    if (NSFoundationVersionNumber <= NSFoundationVersionNumber_iOS_6_1) {
        [app setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    }

    CGRect startFrame = [self.containerView convertRect:self.imageView.frame toView:window];
    self.imageView.layer.position = CGPointMake(startFrame.origin.x + floorf(startFrame.size.width/2), startFrame.origin.y + floorf(startFrame.size.height/2));

    self.imageView.layer.bounds = CGRectMake(0, 0, startFrame.size.width, startFrame.size.height);
    [window addSubview: self.imageView];

    [self.scrollView removeObserver: self forKeyPath: @"contentOffset"];
}

- (void) viewDidDisappear: (BOOL) animated
{
    [super viewDidDisappear: animated];

    UIApplication *app = [UIApplication sharedApplication];
    UIWindow *window = [app keyWindow];

    CGRect endFrame = [self.liftedImageView.superview convertRect: self.liftedImageView.frame
                                                           toView: window];

    CABasicAnimation *center = [CABasicAnimation animationWithKeyPath:@"position"];
    center.fromValue = [NSValue valueWithCGPoint:self.imageView.layer.position];
    center.toValue = [NSValue valueWithCGPoint:CGPointMake(endFrame.origin.x + floorf(endFrame.size.width/2), endFrame.origin.y + floorf(endFrame.size.height/2))];

    CABasicAnimation *scale = [CABasicAnimation animationWithKeyPath:@"bounds"];
    scale.fromValue = [NSValue valueWithCGRect:self.imageView.layer.bounds];
    scale.toValue = [NSValue valueWithCGRect:CGRectMake(0, 0, endFrame.size.width, endFrame.size.height)];

    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    group.duration = kAnimationDuration;
    group.delegate = self;
    group.animations = @[scale,center];
    [group setValue:@"contract" forKey:@"type"];

    self.imageView.layer.position = [center.toValue CGPointValue];
    self.imageView.layer.bounds = [scale.toValue CGRectValue];
    [self.imageView.layer addAnimation:group forKey:nil];
}

#pragma mark - Private Methods

- (void) onDismiss
{
    [self dismissViewControllerAnimated: YES
                             completion: nil];
}

#pragma mark - Orientation

- (void) viewWillTransitionToSize: (CGSize) size
        withTransitionCoordinator: (id <UIViewControllerTransitionCoordinator>) coordinator
{
    [super viewWillTransitionToSize: size
          withTransitionCoordinator: coordinator];

    CGSize imageSize = self.liftedImageView.image.size;
    CGRect endFrame = self.containerView.bounds;
    CGFloat maxHeight = MIN(endFrame.size.height,endFrame.size.width*imageSize.height/imageSize.width);
    CGFloat maxWidth = MIN(endFrame.size.width, endFrame.size.height*imageSize.width/imageSize.height);
    self.imageView.layer.bounds = CGRectMake(0, 0, maxWidth, maxHeight);
    self.imageView.layer.position = self.containerView.layer.position;
}

- (UIInterfaceOrientationMask) supportedInterfaceOrientations
{
    return self.supportedOrientations;
} // End of supportedInterfaceOrientations

#pragma mark - CAAnimationDelegate

- (void) animationDidStart: (CAAnimation *) anim
{
    if ([[anim valueForKey:@"type"] isEqual:@"expand"])
    {
        self.liftedImageView.hidden = YES;
    }
} // End of animationDidStart:

- (void) animationDidStop: (CAAnimation *) anim
                 finished: (BOOL) flag
{
    if ([[anim valueForKey:@"type"] isEqual:@"contract"])
    {
        self.liftedImageView.hidden = NO;
        [self.imageView removeFromSuperview];
    }
    else if ([[anim valueForKey:@"type"] isEqual:@"expand"])
    {
        self.imageView.layer.position = self.containerView.layer.position;
        [self.containerView addSubview:self.imageView];
    }
} // End of animationDidStop:finished:

#pragma mark - UIScrollViewDelegate

- (UIView *) viewForZoomingInScrollView: (UIScrollView *) scrollView
{
    return self.containerView;
} // End of viewForZoomingInScrollView:

@end
