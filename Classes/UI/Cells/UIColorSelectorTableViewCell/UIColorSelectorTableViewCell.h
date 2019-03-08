//
//  UIColorSelectorTableViewCell.h
//  MTG Deck Builder
//
//  Created by Kyle Hankinson on 10-09-18.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MTGCard.h"
#import "UIToggleImage.h"

@interface UIColorSelectorTableViewCell : UITableViewCell <UIToggleImageProtocol>
{
	UIToggleImage			* whiteToggleImage;
	UIToggleImage			* blueToggleImage;
	UIToggleImage			* blackToggleImage;
	UIToggleImage			* redToggleImage;
	UIToggleImage			* greenToggleImage;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)identifier;
- (int) getValue;
- (void) setValue: (int) value;

@end
