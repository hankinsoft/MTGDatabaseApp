//
//  SettingsViewController.h
//  MTG Deck Builder
//
//  Created by Kyle Hankinson on 10-08-28.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
#import "ImageCacheDownloader.h"
#import "GHRootViewController.h"

@class ImageCacheDownloader;
@class CardGridViewController;

@interface MTGSettingsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, MBProgressHUDDelegate, ImageCacheDownloaderProtocol>
{
    CardGridViewController	* detailViewController;

	MBProgressHUD			* progressHUD;

	NSDictionary			* settingsCells;
@private
	RevealBlock _revealBlock;
}

- (id)initWithRevealBlock:(RevealBlock)revealBlock;

@property (nonatomic, retain) IBOutlet CardGridViewController *detailViewController;

@end
