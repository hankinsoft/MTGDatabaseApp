//
//  PriceUpdater.h
//  MTG Deck Builder
//
//  Created by Kyle Hankinson on 11-06-04.
//  Copyright 2011 Hankinsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>
#import "MTStatusBarOverlay.h"

#pragma pack(push)  /* push current alignment to stack */
#pragma pack(1)     /* set alignment to 1 byte boundary */
typedef struct
{
    unsigned int   multiverseId;
    unsigned short lowPrice;
    unsigned short avgPrice;
    unsigned short highPrice;
    unsigned int   tcgId;
} CardPrice;
#pragma pack(pop)   /* restore original alignment from stack */

@interface PriceUpdater : NSObject <MTStatusBarOverlayDelegate>
{
}

+ (NSString*) PricesUpdatedNotification;
+ (void) terminate;
+ (void) update;

@end
