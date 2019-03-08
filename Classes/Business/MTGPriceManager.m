//
//  MTGPriceManager.m
//  MTG Deck Builder
//
//  Created by Kyle Hankinson on 2018-03-16.
//  Copyright © 2018 Hankinsoft Development, Inc. All rights reserved.
//

#import "MTGPriceManager.h"
#import "HSSemaphore.h"

typedef struct __attribute__((packed)) {
    uint32_t    multiverseId;
    uint16_t     lowPrice;
    uint16_t     mediumPrice;
    uint16_t     highPrice;
} MTGPriceEntry;

@interface MTGPriceForCard()

@property(nonatomic,assign) NSUInteger multiverseId;
@property(nonatomic,retain) NSDecimalNumber * highPrice;
@property(nonatomic,retain) NSDecimalNumber * mediumPrice;
@property(nonatomic,retain) NSDecimalNumber * lowPrice;

@end

@implementation MTGPriceForCard
@end

@implementation MTGPriceManager

static MTGPriceForCard * noPrice = nil;
static HSSemaphore * loadingSemaphore = nil;

+ (void) initialize
{
    noPrice = [[MTGPriceForCard alloc] init];
    noPrice.multiverseId = NSNotFound;
    noPrice.lowPrice = [[NSDecimalNumber alloc] initWithInt: 0];
    noPrice.mediumPrice = [[NSDecimalNumber alloc] initWithInt: 0];
    noPrice.highPrice = [[NSDecimalNumber alloc] initWithInt: 0];

    loadingSemaphore = [[HSSemaphore alloc] initWithIdentifier: @"com.mtg.price.loadingSemaphore"
                                                  initialValue: 1];
}

+ (MTGPriceForCard*) priceForMultiverseId: (NSUInteger) multiverseId
{
    static NSArray<MTGPriceForCard*>* prices = nil;

    if(!prices)
    {
        [loadingSemaphore wait: DISPATCH_TIME_FOREVER];

        // Double check. Maybe we were waiting for the prices to finish loading.
        if(!prices)
        {
            NSBundle * databaseBundle = [NSBundle bundleWithIdentifier: @"com.hankinsoft.MTGDatabase"];

            NSString * pricesPath = [databaseBundle pathForResource: @"prices"
                                                             ofType: @"bin"];

            NSArray * tempPrices = [self loadPrices: pricesPath];
            prices = tempPrices;
        } // End of still no prices

        [loadingSemaphore signal];
    } // End of no prices

    MTGPriceForCard * searchObject = [[MTGPriceForCard alloc] init];
    searchObject.multiverseId = multiverseId;

    NSRange searchRange = NSMakeRange(0, [prices count]);
    NSUInteger findIndex = [prices indexOfObject: searchObject
                                   inSortedRange: searchRange
                                         options: NSBinarySearchingFirstEqual
                                 usingComparator: ^(MTGPriceForCard * obj1, MTGPriceForCard * obj2)
                            {
                                if(obj1.multiverseId == obj2.multiverseId)
                                {
                                    return NSOrderedSame;
                                }
                                else if(obj1.multiverseId < obj2.multiverseId)
                                {
                                    return NSOrderedAscending;
                                }

                                return NSOrderedDescending;
                            }];

    if(NSNotFound == findIndex)
    {
        // Unable to find
        return noPrice;
    } // End of not found

    return prices[findIndex];
} // End of priceForMultiverseId:

+ (CGFloat) randomPrice
{
    int lowerBound = 0;
    int upperBound = 30000;
    
    CGFloat rndValue = lowerBound + arc4random() % (upperBound - lowerBound);
    
    rndValue /= 10.0f;

    return rndValue;
} // End of randomPriceDisplay

+ (NSArray<MTGPriceForCard*>*) loadPrices: (NSString*) pricesPath
{
    NSMutableArray<MTGPriceForCard*>* prices = nil;
    void * pricesBuffer = NULL;
    long totalBytes     = 0;
    NSUInteger totalEntries = 0;

    prices = @[].mutableCopy;

    MachTimer * binaryLoadTimer = [MachTimer startTimer];

    /* declare a file pointer */
    FILE    *infile;

    /* open an existing file for reading */
    infile = fopen(pricesPath.cString, "r");

    /* quit if the file does not exist */
    if(infile == NULL)
    {
        return nil;
    }

    /* Get the number of bytes */
    fseek(infile, 0L, SEEK_END);

    totalBytes = ftell(infile);

    /* reset the file position indicator to
     the beginning of the file */
    fseek(infile, 0L, SEEK_SET);

    /* grab sufficient memory for the
     buffer to hold the text */
    pricesBuffer = (char*)calloc(totalBytes, sizeof(char));

    /* memory error */
    if(pricesBuffer == NULL)
    {
        return nil;
    }

    /* copy all the text into the buffer */
    fread(pricesBuffer, sizeof(char), totalBytes, infile);
    fclose(infile);

    totalEntries = (totalBytes - 10) / sizeof(MTGPriceEntry);
    NSLog(@"Prices binary loading took %0.02f seconds", binaryLoadTimer.elapsedSeconds);

    prices = @[].mutableCopy;

    NSDecimalNumber * tenDecimalNumber = [[NSDecimalNumber alloc] initWithInt: 10];
    NSDecimalNumber * oneHundredDecimalNumbrer = [[NSDecimalNumber alloc] initWithInt: 100];

    NSString * dateString = [[NSString alloc] initWithBytes: pricesBuffer
                                                     length: 10
                                                   encoding: NSUTF8StringEncoding];

    (void) dateString; // Just voided so we get no 'Unused variable' warning. I want it here so I can see the value during debugging.

    MTGPriceEntry * priceEntry = pricesBuffer + 10;
    for(NSInteger index = 0; index < totalEntries; ++index)
    {
        MTGPriceForCard * priceForCard = [[MTGPriceForCard alloc] init];

        // Note: This is probably over thought and NSDecimalNumbers are problaby not needed,
        // but since we are dealing with currency I decided to use it.
        priceForCard.lowPrice     = [[NSDecimalNumber alloc] initWithInt: priceEntry->lowPrice];
        priceForCard.mediumPrice  = [[NSDecimalNumber alloc] initWithInt: priceEntry->mediumPrice];
        priceForCard.highPrice    = [[NSDecimalNumber alloc] initWithInt: priceEntry->highPrice];

        priceForCard.lowPrice = [priceForCard.lowPrice decimalNumberByDividingBy: tenDecimalNumber];
        priceForCard.mediumPrice = [priceForCard.mediumPrice decimalNumberByDividingBy: tenDecimalNumber];
        priceForCard.highPrice = [priceForCard.highPrice decimalNumberByDividingBy: tenDecimalNumber];

        NSUInteger multiverseId = priceEntry->multiverseId;
        if(multiverseId & (1 << 31))
        {
            multiverseId &= ~(1 << 31);
            priceForCard.highPrice = [priceForCard.highPrice decimalNumberByMultiplyingBy: oneHundredDecimalNumbrer];
        }
        if(multiverseId & (1 << 30))
        {
            multiverseId &= ~(1 << 30);
            priceForCard.mediumPrice = [priceForCard.mediumPrice decimalNumberByMultiplyingBy: oneHundredDecimalNumbrer];
        }
        if(multiverseId & (1 << 29))
        {
            multiverseId &= ~(1 << 29);
            priceForCard.lowPrice = [priceForCard.lowPrice decimalNumberByMultiplyingBy: oneHundredDecimalNumbrer];
        }

        // Set our multiverseId
        priceForCard.multiverseId = multiverseId;

        [prices addObject: priceForCard];

        ++priceEntry;
    }

    return prices;
}

@end
