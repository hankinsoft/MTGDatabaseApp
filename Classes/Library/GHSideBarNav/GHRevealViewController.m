//
//  GHSidebarViewController.m
//  GHSidebarNav
//
//  Created by Greg Haines on 11/20/11.
//

#import "GHRevealViewController.h"
#import <QuartzCore/QuartzCore.h>


#define kAdMobAdID        @"ca-app-pub-7431449344610247/1123317911"

#pragma mark -
#pragma mark Constants
const NSTimeInterval kGHRevealSidebarDefaultAnimationDuration = 0.25;
const CGFloat kGHRevealSidebarWidth = 260.0f;
const CGFloat kGHRevealSidebarFlickVelocity = 1000.0f;

// Just define so we can see if it exists when we add to a view
@interface MTGHideShowRevealGestureRecognizer : UISwipeGestureRecognizer
@end

@implementation MTGHideShowRevealGestureRecognizer
@end

#pragma mark -
#pragma mark Private Interface
@interface GHRevealViewController ()
{
}

@property (nonatomic, readwrite, getter = isSidebarShowing) BOOL sidebarShowing;
@property (nonatomic, readwrite, getter = isSearching) BOOL searching;
@property (nonatomic, strong) UIView *searchView;
- (void)hideSidebar;
@end


#pragma mark -
#pragma mark Implementation
@implementation GHRevealViewController {
@private
    UIView *_sidebarView;
    UIView *_contentView;
    UITapGestureRecognizer *_tapRecog;
}

- (UIStatusBarStyle) preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
} // End of preferredStatusBarStyle

- (void) setSidebarViewController: (UIViewController *) svc
{
    if (_sidebarViewController == nil)
    {
        svc.view.frame = [self boundsForContentView];
        svc.view.autoresizingMask = UIViewAutoresizingFlexibleHeight;

        _sidebarViewController = svc;
        [self addChildViewController:_sidebarViewController];
        [_sidebarView addSubview:_sidebarViewController.view];
        [_sidebarViewController didMoveToParentViewController:self];
    }
    else if (_sidebarViewController != svc)
    {
        svc.view.frame = [self boundsForContentView];
        svc.view.autoresizingMask = UIViewAutoresizingFlexibleHeight;

        [_sidebarViewController willMoveToParentViewController:nil];
        [self addChildViewController:svc];
        self.view.userInteractionEnabled = NO;

        weakify(self);
        [self transitionFromViewController:_sidebarViewController
                          toViewController:svc
                                  duration:0
                                   options:UIViewAnimationOptionTransitionNone
                                animations:^{}
                                completion:^(BOOL finished)
        {
            strongify(self);

            self.view.userInteractionEnabled = YES;
            [self->_sidebarViewController removeFromParentViewController];
            [svc didMoveToParentViewController:self];
            self->_sidebarViewController = svc;
        }];
    }
}

- (void) setContentViewController: (UIViewController *) cvc
{
    if(cvc && cvc.view)
    {
        BOOL hasSwipeGestures = NO;
        for(UIGestureRecognizer * recognizer in cvc.view.gestureRecognizers)
        {
            if(![recognizer isKindOfClass: MTGHideShowRevealGestureRecognizer.class])
            {
                continue;
            }

            hasSwipeGestures = true;
            break;
        }

        if(!hasSwipeGestures)
        {
            UISwipeGestureRecognizer * swipeLeftGesture = [[MTGHideShowRevealGestureRecognizer alloc] initWithTarget: self
                                                                                                              action: @selector(onSwipeLeftGesture:)];

            swipeLeftGesture.direction = UISwipeGestureRecognizerDirectionLeft;
            [self.view addGestureRecognizer: swipeLeftGesture];

            UISwipeGestureRecognizer * swipeRightGesture = [[MTGHideShowRevealGestureRecognizer alloc] initWithTarget: self
                                                                                                               action: @selector(onSwipeRightGesture:)];

            swipeRightGesture.direction = UISwipeGestureRecognizerDirectionRight;
            [self.view addGestureRecognizer: swipeRightGesture];
        }
    }

    if (_contentViewController == nil)
    {
        cvc.view.frame = _contentView.bounds;
        _contentViewController = cvc;

        [self addChildViewController:_contentViewController];
        [_contentView addSubview:_contentViewController.view];
        [_contentViewController didMoveToParentViewController:self];
    }
    else if (_contentViewController != cvc)
    {
        cvc.view.frame = [self boundsForContentView];
        [_contentViewController willMoveToParentViewController: nil];

        [self addChildViewController:cvc];
        self.view.userInteractionEnabled = NO;
        
        weakify(self);
        [self transitionFromViewController:_contentViewController
                          toViewController:cvc
                                  duration:0
                                   options:UIViewAnimationOptionTransitionNone
                                animations:^{}
                                completion:
         ^(BOOL finished)
        {
            strongify(self);

             self.view.userInteractionEnabled = YES;
            [self->_contentViewController removeFromParentViewController];
            [cvc didMoveToParentViewController:self];
            self->_contentViewController = cvc;
        }];
    }
}

- (void) onSwipeLeftGesture: (UISwipeGestureRecognizer*) gesture
{
    [self hideSidebar];
} // End of onSwipeLeftGesture:

- (void) onSwipeRightGesture: (UISwipeGestureRecognizer*) gesture
{
    if(!self.sidebarShowing)
    {
        // Show our sidebar
        [self toggleSidebar: YES
                   duration: kGHRevealSidebarDefaultAnimationDuration];
    } // End of onSwipeRightGesture
}

#pragma mark Memory Management

- (id)initWithNibName: (NSString *) nibNameOrNil
               bundle:(NSBundle *) nibBundleOrNil
{
    if (self = [super initWithNibName: nibNameOrNil
                               bundle: nibBundleOrNil])
    {
        self.sidebarShowing = NO;
        self.searching = NO;

        _tapRecog = [[UITapGestureRecognizer alloc] initWithTarget: self
                                                            action: @selector(hideSidebar)];

        _tapRecog.cancelsTouchesInView = YES;

        self.view.autoresizingMask =
            (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);

        _sidebarView = [[UIView alloc] initWithFrame:self.view.bounds];
        _sidebarView.autoresizingMask =
            (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);

        _sidebarView.backgroundColor = [UIColor clearColor];
        [self.view addSubview:_sidebarView];

        _contentView = [[UIView alloc] initWithFrame: self.view.bounds];

        _contentView.autoresizingMask =
            (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);

        _contentView.backgroundColor = [UIColor clearColor];
        _contentView.layer.masksToBounds = NO;
        _contentView.layer.shadowColor = [UIColor blackColor].CGColor;
        _contentView.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
        _contentView.layer.shadowOpacity = 1.0f;
        _contentView.layer.shadowRadius = 2.5f;
        _contentView.layer.shadowPath =
            [UIBezierPath bezierPathWithRect:_contentView.bounds].CGPath;

        [self.view addSubview: _contentView];
    }

    return self;
}

#pragma mark Public Methods

- (void)dragContentView:(UIPanGestureRecognizer *)panGesture
{
    CGFloat translation = [panGesture translationInView: self.view].x;

    if (panGesture.state == UIGestureRecognizerStateChanged)
    {
        if (_sidebarShowing)
        {
            if (translation > 0.0f)
            {
                _contentView.frame = CGRectOffset(_contentView.bounds, kGHRevealSidebarWidth, 0.0f);
                self.sidebarShowing = YES;
            }
            else if (translation < -kGHRevealSidebarWidth)
            {
                _contentView.frame = _contentView.bounds;
                self.sidebarShowing = NO;
            }
            else
            {
                _contentView.frame = CGRectOffset(_contentView.bounds, (kGHRevealSidebarWidth + translation), 0.0f);
            }
        }
        else
        {
            if (translation < 0.0f)
            {
                _contentView.frame = _contentView.bounds;
                self.sidebarShowing = NO;
            }
            else if (translation > kGHRevealSidebarWidth)
            {
                _contentView.frame = CGRectOffset(_contentView.bounds, kGHRevealSidebarWidth, 0.0f);
                self.sidebarShowing = YES;
            }
            else
            {
                _contentView.frame = CGRectOffset(_contentView.bounds, translation, 0.0f);
            }
        }
    } else if (panGesture.state == UIGestureRecognizerStateEnded) {
        CGFloat velocity = [panGesture velocityInView:self.view].x;
        BOOL show = (fabs(velocity) > kGHRevealSidebarFlickVelocity)
        ? (velocity > 0)
        : (translation > (kGHRevealSidebarWidth / 2));
        [self toggleSidebar:show duration:kGHRevealSidebarDefaultAnimationDuration];
        
    }
}

- (void)toggleSidebar: (BOOL)show
             duration: (NSTimeInterval)duration
{
    [self toggleSidebar: show
               duration: duration
             completion: ^(BOOL finshed){}];
}

- (void)toggleSidebar:(BOOL)show
             duration:(NSTimeInterval)duration
           completion:(void (^)(BOOL finsihed))completion
{
    __weak GHRevealViewController *selfRef = self;
    weakify(self);
    void (^animations)(void) = ^{
        strongify(self);

        if (show) {
            self->_contentView.frame = CGRectOffset(self->_contentView.bounds, kGHRevealSidebarWidth, 0.0f);
            [self->_contentView addGestureRecognizer: self->_tapRecog];
            [selfRef.contentViewController.view setUserInteractionEnabled:NO];
        }
        else
        {
            if (self.isSearching)
            {
                self->_sidebarView.frame = CGRectMake(0.0f, 0.0f, kGHRevealSidebarWidth, CGRectGetHeight(self.view.bounds));
            }
            else
            {
                [self->_contentView removeGestureRecognizer: self->_tapRecog];
            }

            self->_contentView.frame = self->_contentView.bounds;
            [selfRef.contentViewController.view setUserInteractionEnabled:YES];
        }

        selfRef.sidebarShowing = show;
    };

    if (duration > 0.0)
    {
        [UIView animateWithDuration: duration
                              delay: 0
                            options: UIViewAnimationOptionCurveEaseInOut
                         animations: animations
                         completion: completion];
    }
    else
    {
        animations();
        completion(YES);
    }
}

#pragma mark Private Methods

- (void) hideSidebar
{
    [self toggleSidebar: NO
               duration: kGHRevealSidebarDefaultAnimationDuration];
}


- (CGRect) boundsForContentView
{
    CGRect bounds = self.view.bounds;
    return bounds;
}


@end
