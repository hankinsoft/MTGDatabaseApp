//
//  AppDelegate.h
//  MTG Deck Builder
//
//  Created by Kyle Hankinson on 10-06-15.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
@import FMDB;

@class CardGridViewController;
@class BrowseSetViewController;

static NSString * databaseUpdateLockObject = @"DatabaseUpdateLockObject";

@interface AppDelegate : NSObject <UIApplicationDelegate>
{
    IBOutlet UIWindow           * window;
}

+ (NSString*) PurchaseUpdatedNotification;

+ (NSString*) cardsPath;
+ (int) databaseVersion;
+ (AppDelegate*) instance;
+ (BOOL) isIPad;
+ (FMDatabaseQueue*) databaseQueue;
+ (NSInteger) cardPriceVersion;
+ (void) setCardPriceVersion: (NSInteger) version;
+ (UIBarStyle) barButtonStyle;

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) FMDatabaseQueue * dbQueue;

@end
