//
//  CardLinksViewController.h
//  MTG Deck Builder
//
//  Created by Kyle Hankinson on 12-06-01.
//  Copyright (c) 2012 Hankinsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MTGCard;
@interface CardLinksViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>

@property(nonatomic,retain) MTGCard * card;

@end
