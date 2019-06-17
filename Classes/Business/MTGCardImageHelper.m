//
//  MTGCardImageHelper.m
//  MTG Deck Builder
//
//  Created by kylehankinson on 2018-08-27.
//  Copyright © 2018 Hankinsoft Development, Inc. All rights reserved.
//

#import "MTGCardImageHelper.h"

@import SDWebImage;

@implementation MTGCardImageHelper

static NSComparisonResult compareStrings(NSString* _Nonnull obj1, NSString * _Nonnull obj2)
{
    return [obj1 compare: obj2];
}

+ (void) loadImage: (NSUInteger) multiverseId
   targetImageView: (UIImageView*) targetImageView
  placeholderImage: (UIImage*) placeholderImage
      didLoadBlock: (MTGCardImageHelperDidLoadBlock) didLoadBlock
      didFailBlock: (MTGCardImageHelperDidFailBlock) didFailBlock
{
    static NSArray<NSString*>* resourceCardImages = nil;
    static NSURL * imagesRoot = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        imagesRoot = [[[NSBundle mainBundle] bundleURL] URLByAppendingPathComponent: @"CardImages"];
        NSArray * directoryContents = [[NSFileManager defaultManager] contentsOfDirectoryAtURL: imagesRoot
                                                                    includingPropertiesForKeys: @[]
                                                                                       options: NSDirectoryEnumerationSkipsHiddenFiles
                                                                                         error:nil];

        NSMutableArray *cardImages = @[].mutableCopy;
        for(NSURL * card in directoryContents)
        {
            [cardImages addObject: card.lastPathComponent];
        }

        resourceCardImages = [cardImages sortedArrayUsingComparator: ^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            return compareStrings(obj1, obj2);
        }];
    });

    NSString * imageName = [NSString stringWithFormat: @"%ld.jpg", (long) multiverseId];
    if(NSNotFound != [resourceCardImages indexOfObject: imageName
                                         inSortedRange: NSMakeRange(0, resourceCardImages.count)
                                               options: NSBinarySearchingFirstEqual
                                       usingComparator: ^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
                                           return compareStrings(obj1, obj2);
                                       }])
    {
        NSURL * imageURL = [imagesRoot URLByAppendingPathComponent: imageName];
        NSString * stringPath = imageURL.path;

        UIImage * image = [UIImage imageWithContentsOfFile: stringPath];
        if(nil != image)
        {
            didLoadBlock(image, true);
            return;
        } // End of we have an image
    }

    // Try to load from scryfall.com
    NSString * imageString = [NSString stringWithFormat: @"https://api.scryfall.com/cards/multiverse/%lu?format=image&version=border_crop", (unsigned long)multiverseId];

    NSURL * imageURL = [NSURL URLWithString: imageString];

    // Clear the image before load
    targetImageView.image = placeholderImage;
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    [manager loadImageWithURL: imageURL
                      options: (SDWebImageOptions) 0
                     progress: NULL
                    completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
                        if(error)
                        {
                            didFailBlock();
                            return;
                        }

                        if(image)
                        {
                            if(cacheType == SDImageCacheTypeNone)
                            {
                                didLoadBlock(image, false);
                                [[HSLogHelper sharedInstance] logEvent: @"CardImageDownloaded"
                                                           withDetails: @{@"multiverseId": [NSString stringWithFormat: @"%ld", (long) multiverseId]}];
                            }
                            else
                            {
                                didLoadBlock(image, true);
                            }
                        }
                        else
                        {
                            didFailBlock();
                        }
                    }];
}

@end
