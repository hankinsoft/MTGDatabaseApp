//
//  MTGCardImageHelper.h
//  MTG Deck Builder
//
//  Created by kylehankinson on 2018-08-27.
//  Copyright © 2018 Hankinsoft Development, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^MTGCardImageHelperDidLoadBlock)(UIImage * image, BOOL wasCached);
typedef void (^MTGCardImageHelperDidFailBlock)(void);


@interface MTGCardImageHelper : NSObject

+ (void) loadImage: (NSUInteger) multiverseId
   targetImageView: (UIImageView*) targetImageView
  placeholderImage: (UIImage*) placeholderImage
      didLoadBlock: (MTGCardImageHelperDidLoadBlock) didLoadBlock
      didFailBlock: (MTGCardImageHelperDidFailBlock) didFailBlock;

@end
