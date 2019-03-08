//
//  MTGCardSetHelper.h
//
//  Created by Kyle Hankinson on 10-04-23.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

@class MTGCardSet;
@class MTGCard;

@interface MTGCardSetIconHelper : NSObject
{

}

+ (void) downloadMissingIcons;

+ (UIImage*) iconForCardSet: (MTGCardSet*) cardSet;
+ (UIImage*) iconForCardSet: (MTGCardSet*) cardSet
                     rarity: (NSString*) rarity;

+ (UIImage*) iconForCardSetShortName: (NSString *) shortName;

@end
