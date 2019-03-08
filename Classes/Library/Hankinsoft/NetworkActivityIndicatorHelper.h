//
//  NetworkActivityIndicatorHelper.h
//  Chrome Bookmarks
//
//  Created by Kyle Hankinson on 10-01-10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NetworkActivityIndicatorHelper : NSObject
{
}

+ (void) increaseActivity;
+ (void) decreaseActivity;

@end
