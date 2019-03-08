//
//  MTGCardSetHelper.m
//
//  Created by Kyle Hankinson on 10-04-23.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "MTGCardSetIconHelper.h"
#import "AppDelegate.h"
#import "MTGCardSet.h"
#import "MTGCard.h"

@implementation MTGCardSetIconHelper

#define kRarityTypes @[@"C", @"M", @"T", @"U"]

static NSMutableDictionary<NSString*,UIImage*>* iconCache = nil;
static NSString * cardSetPath = nil;

+ (void) initialize
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        iconCache = @{}.mutableCopy;

        NSArray *  paths        = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString * documentsDir = [paths objectAtIndex:0];
        cardSetPath = [documentsDir stringByAppendingPathComponent: @"CardSets"];

        NSError * error = nil;
        [[NSFileManager defaultManager] createDirectoryAtPath: cardSetPath
                                  withIntermediateDirectories: YES
                                                   attributes: nil
                                                        error: &error];
        if (error != nil)
        {
            NSLog(@"error creating directory: %@", error);
            //..
        }
    });
}

+ (void) downloadMissingIcons
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSArray<NSString*>* existingKeys = nil;
        @synchronized(iconCache)
        {
            existingKeys = iconCache.allKeys;
        } // End of iconCache

        NSMutableArray * needToDownload = @[].mutableCopy;

        [AppDelegate.databaseQueue inDatabase:^(FMDatabase * _Nonnull db) {
            FMResultSet * results = [db executeQuery: @"SELECT shortName, group_concat(distinct rarity) FROM cardSet INNER JOIN card ON card.cardSetId = cardSet.cardSetId WHERE block NOT IN('promo','signature spellbook', \
                                     'global series') GROUP BY shortName ORDER BY releaseDate ASC"];
            while([results next])
            {
                NSString * shortName = [results stringForColumn: @"shortName"];

                // Timespiral timeshifted special case
                if([shortName isEqualToString: @"TSB"])
                {
                    shortName = @"TSP";
                } // End of timespiral timeshifted fix

                NSArray * raritiesToTry = [[results stringForColumnIndex: 1] componentsSeparatedByString: @","];

                for(NSString * fullRarity in raritiesToTry)
                {
                    NSString * rarity = [fullRarity stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
                    if(NSOrderedSame == [rarity caseInsensitiveCompare: @"Common"] ||
                       NSOrderedSame == [rarity caseInsensitiveCompare: @"Basic Land"] ||
                       NSOrderedSame == [rarity caseInsensitiveCompare: @"Land"])
                    {
                        rarity = @"C";
                    }
                    else if(NSOrderedSame == [rarity caseInsensitiveCompare: @"Uncommon"])
                    {
                        rarity = @"U";
                    }
                    else if(NSOrderedSame == [rarity caseInsensitiveCompare: @"Mythic Rare"])
                    {
                        rarity = @"M";
                    }
                    else if(NSOrderedSame == [rarity caseInsensitiveCompare: @"Rare"])
                    {
                        rarity = @"R";
                    }
                    else if(NSOrderedSame == [rarity caseInsensitiveCompare: @"Special"])
                    {
                        rarity = @"T";
                    }

                    NSString * lookupString = [NSString stringWithFormat: @"%@%@", shortName, rarity];
                    if([existingKeys containsObject: lookupString])
                    {
                        continue;
                    } // End of already exists

                    NSString * fileName = [NSString stringWithFormat: @"%@%@.png", shortName, rarity];
                    NSString * imageInCardSets = [NSString stringWithFormat: @"CardSets/%@", fileName];

                    NSString * bundleIconPath = [[NSBundle mainBundle] pathForResource: imageInCardSets
                                                                                ofType: nil];
                    
                    // If the file exists then we will use that
                    if(nil != bundleIconPath &&
                       [[NSFileManager defaultManager] fileExistsAtPath: bundleIconPath])
                    {
                        continue;
                    }

                    NSString * tempIconPath = [cardSetPath stringByAppendingPathComponent: fileName];

                    if([[NSFileManager defaultManager] fileExistsAtPath: tempIconPath])
                    {
                        continue;
                    }

                    [needToDownload addObject: lookupString];
                } // End of rarity loop
            } // End of results enumeration
        }];

        NSLog(@"Need to download %ld images.", (long) needToDownload.count);
        for(NSString * setImage in needToDownload)
        {
            CGFloat scale = UIScreen.mainScreen.scale;
            NSString * retinaSuffix = nil;
            if(0 == scale || 1 == scale)
            {
                retinaSuffix = @"";
            }
            else if(2 == scale)
            {
                retinaSuffix = @"@2x";
            }
            else if(3 == scale)
            {
                retinaSuffix = @"@3x";
            }

            NSString * targetFileName = [NSString stringWithFormat: @"%@%@.png", setImage, retinaSuffix];
            NSString * downloadPath = [NSString stringWithFormat: @"https://s3.amazonaws.com/mtgdb/setImages/%@", targetFileName];
            
            NSURL * downloadURL = [NSURL URLWithString: downloadPath];
            NSData * iconData = [NSData dataWithContentsOfURL: downloadURL];
            if(iconData)
            {
                UIImage * image = [UIImage imageWithData: iconData];
                if(image)
                {
                    NSString * fileName = [NSString stringWithFormat: @"%@.png", setImage];
                    NSString * tempIconPath = [cardSetPath stringByAppendingPathComponent: fileName];

                    NSError * writeError = nil;
                    [iconData writeToFile: tempIconPath
                                  options: NSDataWritingAtomic
                                    error: &writeError];

                    if(writeError)
                    {
                        NSLog(@"Write error");
                    }
                }
            }

            NSLog(@"Want to download %@", downloadPath);
        }
    });
} // End of downloadMissingIcons

+ (UIImage*) iconForCardSet: (MTGCardSet*) cardSet
{
    return [self iconForCardSet: cardSet
                         rarity: nil];
} // End of iconForCardSet

+ (UIImage*) iconForCardSet: (MTGCardSet*) cardSet
                     rarity: (NSString*) rarity
{
    return [self iconForCardSetShortName: cardSet.shortName
                                  rarity: rarity];
}

+ (UIImage*) iconForCardSetShortName: (NSString *) shortName
{
    return [self iconForCardSetShortName: shortName
                                  rarity: nil];
}

+ (UIImage*) iconForCardSetShortName: (NSString *) shortName
                              rarity: (NSString*) rarity
{
    // Timespiral timeshifted special case
    if([shortName isEqualToString: @"TSB"])
    {
        shortName = @"TSP";
    } // End of timespiral timeshifted fix

    NSString * lookupString = [NSString stringWithFormat: @"%@%@", shortName, rarity ? rarity : @""];

    @synchronized(iconCache)
    {
        UIImage * cachedImage = iconCache[lookupString];
        if(nil != cachedImage)
        {
            return cachedImage;
        } // End of we have a cachedImage

        if([NSThread isMainThread])
        {
            NSLog(@"Break");
        }

        NSArray * typesToTry = kRarityTypes;

        if(nil != rarity)
        {
            if(NSOrderedSame == [@"Common" caseInsensitiveCompare: rarity] ||
               NSOrderedSame == [@"Basic Land" caseInsensitiveCompare: rarity] ||
               NSOrderedSame == [@"Land" caseInsensitiveCompare: rarity])
            {
                typesToTry = @[@"C"];
            }
            else if(NSOrderedSame == [@"Uncommon" caseInsensitiveCompare: rarity])
            {
                typesToTry = @[@"U", @"C"];
            }
            else if(NSOrderedSame == [@"Rare" caseInsensitiveCompare: rarity])
            {
                typesToTry = @[@"R", @"C"];
            }
            else if(NSOrderedSame == [@"Mythic" caseInsensitiveCompare: rarity] ||
                    NSOrderedSame == [@"Mythic Rare" caseInsensitiveCompare: rarity])
            {
                typesToTry = @[@"M", @"R", @"C"];
            }
            else if(NSOrderedSame == [@"Special" caseInsensitiveCompare: rarity])
            {
                typesToTry = @[@"T", @"M", @"C"];
            }
            else if(NSOrderedSame == [@"Bonus" caseInsensitiveCompare: rarity])
            {
                typesToTry = @[@"T", @"M", @"R"];
            }
            else
            {
                NSLog(@"Unknown: %@", rarity);
            }
        }

        for(NSString * rarity in typesToTry)
        {
            NSString * fileName = [NSString stringWithFormat: @"%@%@", shortName, rarity];
            NSString * imageInCardSets = [NSString stringWithFormat: @"CardSets/%@", fileName];
            UIImage * resultImage = [UIImage imageNamed: imageInCardSets];

            if(nil != resultImage)
            {
                iconCache[lookupString] = resultImage;
                return resultImage;
            }

            fileName = [NSString stringWithFormat: @"%@.png", fileName];

            NSString * bundleIconPath = [[NSBundle mainBundle] pathForResource: fileName
                                                                        ofType: nil];

            // If the file exists then we will use that
            if([[NSFileManager defaultManager] fileExistsAtPath: bundleIconPath])
            {
                resultImage = [UIImage imageWithContentsOfFile: bundleIconPath];
                if(nil != resultImage)
                {
                    iconCache[lookupString] = resultImage;
                    return resultImage;
                }
            }

            NSString * tempIconPath   = [cardSetPath stringByAppendingPathComponent: fileName];

            if([[NSFileManager defaultManager] fileExistsAtPath: tempIconPath])
            {
                resultImage = [UIImage imageWithContentsOfFile: tempIconPath];
                if(nil != resultImage)
                {
                    iconCache[lookupString] = resultImage;
                    return resultImage;
                }
            }
        }
    }

    NSString * fileName = [NSString stringWithFormat: @"DOTP%@", rarity];
    NSString * imageInCardSets = [NSString stringWithFormat: @"CardSets/%@", fileName];
    UIImage * resultImage = [UIImage imageNamed: imageInCardSets];

    return resultImage;
}

@end
