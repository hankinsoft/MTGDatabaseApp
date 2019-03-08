//
//  MTGLifeCounterSettingsViewController.h
//  MTG Deck Builder
//
//  Created by kylehankinson on 2018-08-15.
//  Copyright © 2018 Hankinsoft Development, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XLForm/XLFormViewController.h>

#define kMTGLockScreenIdleTimerDisabled          @"kMTGLockScreenIdleTimerDisabled"

@class MTGLifeCounterSettingsViewController;

@protocol MTGLifeCounterSettingsViewControllerDelegate<NSObject>

- (void) lifeCounterSettingsDidChange: (MTGLifeCounterSettingsViewController*) settingsViewController;

@end

@interface MTGLifeCounterSettingsViewController : XLFormViewController

@property(nonatomic,weak) id<MTGLifeCounterSettingsViewControllerDelegate> delegate;

@end
