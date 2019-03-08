//
//  UIColorSelectorTableViewCell.m
//  MTG Deck Builder
//
//  Created by Kyle Hankinson on 10-09-18.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "UIColorSelectorTableViewCell.h"
#import "AppDelegate.h"

#define			IMAGE_SIZE		35

@interface UIColorSelectorTableViewCell ()

- (CGRect) frameForToggleImageIndex: (int) toggleImageIndex;

@property (nonatomic, retain) UIToggleImage			* whiteToggleImage;
@property (nonatomic, retain) UIToggleImage			* blueToggleImage;
@property (nonatomic, retain) UIToggleImage			* blackToggleImage;
@property (nonatomic, retain) UIToggleImage			* redToggleImage;
@property (nonatomic, retain) UIToggleImage			* greenToggleImage;

@end

@implementation UIColorSelectorTableViewCell

@synthesize whiteToggleImage;
@synthesize blueToggleImage;
@synthesize blackToggleImage;
@synthesize redToggleImage;
@synthesize greenToggleImage;

- (id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)identifier
{
    if ( [AppDelegate isIPad] )
    {
        style = UITableViewCellStyleDefault;
    }
    else
    {
        style = UITableViewCellStyleSubtitle;
    }

	if ( self = [super initWithStyle:style reuseIdentifier:identifier] )
	{
		self.whiteToggleImage = [[UIToggleImage alloc] initWithFrame: [self frameForToggleImageIndex: 0]
														 normalImage: [UIImage imageNamed: @"white-dim.png"]
													   selectedImage: [UIImage imageNamed: @"white.png"]
															delegate: self];
		
		self.blueToggleImage = [[UIToggleImage alloc] initWithFrame: [self frameForToggleImageIndex: 1]
														normalImage: [UIImage imageNamed: @"blue-dim.png"]
													  selectedImage: [UIImage imageNamed: @"blue.png"]
														   delegate: self];
		
		self.blackToggleImage = [[UIToggleImage alloc] initWithFrame: [self frameForToggleImageIndex: 2]
														 normalImage: [UIImage imageNamed: @"black-dim.png"]
													   selectedImage: [UIImage imageNamed: @"black.png"]
															delegate: self];
		
		self.redToggleImage = [[UIToggleImage alloc] initWithFrame: [self frameForToggleImageIndex: 3]
													   normalImage: [UIImage imageNamed: @"red-dim.png"]
													 selectedImage: [UIImage imageNamed: @"red.png"]
														  delegate: self];
		
		self.greenToggleImage = [[UIToggleImage alloc] initWithFrame: [self frameForToggleImageIndex: 4]
														 normalImage: [UIImage imageNamed: @"green-dim.png"]
													   selectedImage: [UIImage imageNamed: @"green.png"]
															delegate: self];

		[self addSubview:self.whiteToggleImage];
		[self addSubview:self.blueToggleImage];
		[self addSubview:self.blackToggleImage];
		[self addSubview:self.redToggleImage];
		[self addSubview:self.greenToggleImage];		

		// Un-selectable
		[self setSelectionStyle: UITableViewCellSelectionStyleNone];
    }
    return self;
}

- (CGRect) frameForToggleImageIndex: (int) toggleImageIndex
{
    int imageOffsetY = 3;
    int imageOffsetX = 257;
    int imagePadding = 40;

    if ( ![AppDelegate isIPad] )
    {
        imageOffsetY = 43;
        imageOffsetX = 20;
        imagePadding = 25;
    }

	return CGRectMake (
                       imageOffsetX + ( imagePadding * toggleImageIndex + IMAGE_SIZE * toggleImageIndex), 
					  imageOffsetY, 
					  IMAGE_SIZE, 
					  IMAGE_SIZE );
}

- (void) imageToggled
{
	[self setNeedsDisplay];
	NSLog( @"Image toggled from cell" );
} // End of imageToggled

- (int) getValue
{
	int value = 0;
	
	if ( whiteToggleImage.toggled )
	{
		value |= CARD_WHITE;
	}
	if ( blueToggleImage.toggled )
	{
		value |= CARD_BLUE;
	}
	if ( blackToggleImage.toggled )
	{
		value |= CARD_BLACK;
	}
	if ( redToggleImage.toggled )
	{
		value |= CARD_RED;
	}
	if ( greenToggleImage.toggled )
	{
		value |= CARD_GREEN;
	}

	return value;
}

- (void) setValue: (int) value
{
	[self.whiteToggleImage setToggled: 0 != ( value & CARD_WHITE )];
	[self.blueToggleImage setToggled:  0 != ( value & CARD_BLUE )];
	[self.blackToggleImage setToggled: 0 != ( value & CARD_BLACK )];
	[self.redToggleImage setToggled:   0 != ( value & CARD_RED )];
	[self.greenToggleImage setToggled: 0 != ( value & CARD_GREEN )];
}

- (void)layoutSubviews
{
	// Super layout
	[super layoutSubviews];

    // Update our text labels frame
    CGRect textLabelFrame = self.textLabel.frame;
    textLabelFrame.size.width = 200;

    // iPhone moves the label up
    if ( ![AppDelegate isIPad] )
    {
        textLabelFrame.origin.y = 12;
    }
    self.textLabel.frame = textLabelFrame;

    NSLog ( @"%@", NSStringFromCGRect(self.textLabel.bounds));
} // End of layoutSubviews


@end
