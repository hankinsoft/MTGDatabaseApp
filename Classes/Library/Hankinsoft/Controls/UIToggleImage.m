//
//  UIToggleImage.m
//  MTG Deck Builder
//
//  Created by Kyle Hankinson on 10-09-11.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "UIToggleImage.h"

@interface UIToggleImage ()

@property (nonatomic, retain) UIImage		*	normalImage;
@property (nonatomic, retain) UIImage		*	selectedImage;

@end

@implementation UIToggleImage

@synthesize normalImage;
@synthesize selectedImage;
@synthesize toggled;

@synthesize delegate;

#pragma mark -
#pragma mark View lifecycle

- (id) initWithFrame: (CGRect) frame normalImage: (UIImage*) _normalImage selectedImage: (UIImage*) _selectedImage delegate: (id<UIToggleImageProtocol>) _delegate
{
	if ( self = [super initWithFrame: frame] )
	{
		self.normalImage = _normalImage;
		self.selectedImage = _selectedImage;
		self.toggled = NO;

		imageView = [[UIImageView alloc] initWithFrame: CGRectMake ( 0, 0, frame.size.width, frame.size.height)];
		imageView.image = normalImage;
		self.delegate = _delegate;

		// set imageView frame
		[self addSubview: imageView];
		[self sendActionsForControlEvents:UIControlEventTouchDown];
		[self addTarget: self action: @selector(toggleImage) forControlEvents: UIControlEventTouchDown];
	}

	return self;
}

- (void) toggleImage
{
	[self setToggled: !toggled];
}

- (void) setToggled:(BOOL) _toggled
{
	if ( toggled != _toggled )
	{
		toggled = _toggled;
		imageView.image = (toggled ? selectedImage : normalImage);
		// Call into our delegate
		[self.delegate imageToggled];
	}
}

@end

