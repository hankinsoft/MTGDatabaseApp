//
//  MTGPriceManager.h
//  MTG Deck Builder
//
//  Created by Kyle Hankinson on 2018-03-16.
//  Copyright © 2018 Hankinsoft Development, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MTGPriceForCard : NSObject

- (NSUInteger) multiverseId;

- (NSDecimalNumber*) highPrice;
- (NSDecimalNumber*) mediumPrice;
- (NSDecimalNumber*) lowPrice;

@end

@interface MTGPriceManager : NSObject

+ (NSString*) pricesUpdatedNotificationName;

+ (NSURL*) URLForPrices;
+ (void) beginUpdatePrices;
+ (MTGPriceForCard*) priceForMultiverseId: (NSUInteger) multiverseId;

@end
