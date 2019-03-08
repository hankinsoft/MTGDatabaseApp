//
//  MTGArtists.h
//  MTG Deck Builder
//
//  Created by kylehankinson on 2018-04-14.
//  Copyright © 2018 Hankinsoft Development, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MTGArtist : NSObject

+ (NSArray<MTGArtist*>*) allArtists;
+ (MTGArtist*) artistById: (NSUInteger) artistId;

@property(nonatomic,copy,readonly) NSString * name;

@end
