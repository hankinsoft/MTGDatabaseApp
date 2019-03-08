//
//  UISetTableViewCell.h
//  MTG Deck Builder
//
//  Created by Kyle Hankinson on 10-08-01.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UISetTableView;
@class MTGCardSet;

@interface UISetTableCell : UITableViewCell
{
}

@property(nonatomic,retain) MTGCardSet     * cardSet;
@property(nonatomic,retain) UIImageView * setImageView;

@end
