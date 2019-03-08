//
//  NetworkActivityIndicatorHelper.m
//  Chrome Bookmarks
//
//  Created by Kyle Hankinson on 10-01-10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "NetworkActivityIndicatorHelper.h"


@implementation NetworkActivityIndicatorHelper

static int activity = 0;

+ (void) increaseActivity
{
	if ( ++activity == 1 )
	{
		[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	}
}

+ (void) decreaseActivity
{
	if ( --activity == 0 )
	{
		[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	}
}

@end
