//
//  ImageCacheDownloader.h
//  MTG Deck Builder
//
//  Created by Kyle Hankinson on 10-09-02.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ImageCacheDownloaderProtocol

- (void) imageCacheProgressChanged: (float) progress;

@end

@interface ImageCacheDownloader : NSObject
{

}

+ (void) setDelegate: (id<ImageCacheDownloaderProtocol>) delegate;

+ (BOOL) enabled;
+ (void) setEnabled: (BOOL) enabled;
+ (void) setPaused: (BOOL) paused;

@end
