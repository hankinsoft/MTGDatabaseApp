//
//  UIToggleImageControl.h
//  MTG Deck Builder
//
//  Created by Kyle Hankinson on 10-09-11.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol UIToggleImageProtocol<NSObject>

- (void) imageToggled;

@end

@interface UIToggleImage : UIControl
{
	BOOL		toggled;

	UIImageView *	imageView;
	UIImage		*	normalImage;
	UIImage		*	selectedImage;

	id<UIToggleImageProtocol>	delegate;
}

- (id) initWithFrame: (CGRect) frame normalImage: (UIImage*) normalImage selectedImage: (UIImage*) selectedImage delegate: (id<UIToggleImageProtocol>) delegate;

@property (nonatomic, assign) BOOL toggled;
@property (nonatomic, retain) id<UIToggleImageProtocol>	delegate;

@end
