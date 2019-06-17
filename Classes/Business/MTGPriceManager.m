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
    uint32_t     lowPrice;
    uint32_t     mediumPrice;
    uint32_t     highPrice;
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
static HSSemaphore * updateSemaphore = nil;
static HSSemaphore * loadingSemaphore = nil;
static NSArray<MTGPriceForCard*>* prices = nil;
static NSUInteger currentPriceTimestamp = 0;

+ (NSString*) pricesUpdatedNotificationName
{
    return @"com.hankinsoft.mtg.pricesUpdatedNotification";
} // End of pricesUpdatedNotificationName

+ (void) initialize
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        noPrice = [[MTGPriceForCard alloc] init];
        noPrice.multiverseId = NSNotFound;
        noPrice.lowPrice = [[NSDecimalNumber alloc] initWithInt: 0];
        noPrice.mediumPrice = [[NSDecimalNumber alloc] initWithInt: 0];
        noPrice.highPrice = [[NSDecimalNumber alloc] initWithInt: 0];

        loadingSemaphore = [[HSSemaphore alloc] initWithIdentifier: @"com.mtg.price.loadingSemaphore"
                                                      initialValue: 1];

        updateSemaphore = [[HSSemaphore alloc] initWithIdentifier: @"com.mtg.price.updateSemaphore"
                                                    initialValue: 1];
    });
}

+ (NSURL*) URLForPrices
{
    static NSURL * urlForPrices = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        NSString * cacheDirectory = [paths objectAtIndex:0];
        NSString * pricesPath = [cacheDirectory stringByAppendingPathComponent: @"prices.bin"];

        urlForPrices = [NSURL fileURLWithPath: pricesPath];
    });

    return urlForPrices;
} // End of URLForPrices

+ (void) beginUpdatePrices
{
    // Wait until we have a timestamp set
    if(0 == currentPriceTimestamp)
    {
        return;
    } // End of no timestamp set yet

    NSDateComponents * dayComponent = [[NSDateComponents alloc] init];
    dayComponent.day = 1;

    NSDate * updateDate = [[NSCalendar currentCalendar] dateByAddingComponents: dayComponent
                                                                        toDate: [NSDate dateWithTimeIntervalSince1970: currentPriceTimestamp]
                                                                       options: 0];


    if(NSDate.date.timeIntervalSince1970 < updateDate.timeIntervalSince1970)
    {
        NSLog(@"MTGPriceManager - not going to check for update yet.");
        return;
    } // End of do not need to update

    // If we are already updating, then exit out.
    if([updateSemaphore wait: DISPATCH_TIME_NOW])
    {
        return;
    } // End of already updating

    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        // Get our latest price timestamp. (Timestamp file is smaller than prices file, so we grab it first).
        NSUInteger latestPriceTimestamp = [self downloadLatestPriceTimestamp];

        // Not found indicates a failure. We cannot try and update.
        if(NSNotFound == latestPriceTimestamp)
        {
            [updateSemaphore signal];
            return;
        } // End of no price found

        // If we alraedy have the latests, then we can safely exit.
        if(latestPriceTimestamp <= currentPriceTimestamp)
        {
            [updateSemaphore signal];
            return;
        } // End of timestamp is invalid

        NSData * priceData = [self downloadPrices];

        if(nil == priceData)
        {
            NSLog(@"Failed to download price data");
        }

        // Wait for our loading semaphore to be complete
        while([loadingSemaphore wait: DISPATCH_TIME_FOREVER]);

        NSString * tempPath = NSTemporaryDirectory();
        NSString * tempFile = [tempPath stringByAppendingPathComponent: NSUUID.UUID.UUIDString];
        NSURL * tempURL = [NSURL fileURLWithPath: tempFile];
        
        if(![priceData writeToURL: tempURL
                       atomically: YES])
        {
            NSLog(@"Failed to save price data to file");
            [loadingSemaphore signal];
            [updateSemaphore signal];
            return;
        } // End of failed to write to file

        // Try and load
        NSArray * tempPrices = [self loadPricesFromPath: tempFile
                                              timestamp: &currentPriceTimestamp];

        // Only replace if we have prices
        if(tempPrices)
        {
            // Set our prices
            prices = tempPrices;

            // Replace our file
            NSError * error = nil;
            if([NSFileManager.defaultManager fileExistsAtPath: self.URLForPrices.path])
            {
                [NSFileManager.defaultManager replaceItemAtURL: self.URLForPrices
                                                 withItemAtURL: tempURL
                                                backupItemName: nil
                                                       options: 0
                                              resultingItemURL: nil
                                                         error: &error];
            }
            else
            {
                [NSFileManager.defaultManager moveItemAtURL: tempURL
                                                      toURL: self.URLForPrices
                                                      error: &error];
            }

            if(error)
            {
                NSLog(@"Failed to copy new prices with error: %@", error.localizedDescription);
            }
        } // End of we had prices

        [loadingSemaphore signal];
        [updateSemaphore signal];

        // Make sure anything that cares, knows that our notifications have been
        // updated.
        [NSNotificationCenter.defaultCenter postNotificationName: self.pricesUpdatedNotificationName
                                                          object: nil];
    });
} // End of beginUpdatePrices

+ (nullable NSData*) downloadPrices
{
    NSString *url = [NSString stringWithFormat: @"https://github.com/hankinsoft/MTGDatabaseApp-Database/raw/master/MTGDatabase/Resources/prices.bin"];

    NSLog( @"Want to get prices from %@", url );
    
    // We got data
    NSData * data = [NSData dataWithContentsOfURL: [NSURL URLWithString: url]];

    // Could be nil. Thats ok.
    return data;
} // End of downloadPrices

+ (NSUInteger) downloadLatestPriceTimestamp
{
    NSString *url = [NSString stringWithFormat: @"https://github.com/hankinsoft/MTGDatabaseApp-Database/raw/master/MTGDatabase/Resources/pricesTimestamp.bin"];

    NSLog( @"Want to get prices from %@", url );

    // We got data
    NSData * data = [NSData dataWithContentsOfURL: [NSURL URLWithString: url]];
    if(nil == data)
    {
        return NSNotFound;
    } // End of could not find it

    // Get our timestamp
    NSUInteger latestPriceTimestamp;

    [data getBytes: &latestPriceTimestamp
            length: sizeof(latestPriceTimestamp)];

    return latestPriceTimestamp;
} // End of downloadPrices

+ (MTGPriceForCard*) priceForMultiverseId: (NSUInteger) multiverseId
{
    if(!prices)
    {
        [self loadPrices];
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

    MTGPriceForCard * foundPrice = prices[findIndex];
    return foundPrice;
} // End of priceForMultiverseId:

+ (void) loadPrices
{
    BOOL wantToCheckPricesForUpdate = NO;

    // Wait until we can load
    while([loadingSemaphore wait: DISPATCH_TIME_FOREVER]);

    // Double check. Maybe we were waiting for the prices to finish loading.
    if(!prices)
    {
        // Use prices from resource if no file already exists
        if(![NSFileManager.defaultManager fileExistsAtPath: self.URLForPrices.path])
        {
            NSBundle * databaseBundle = [NSBundle bundleWithIdentifier: @"com.hankinsoft.MTGDatabase"];

            NSString * pricesPath = [databaseBundle pathForResource: @"prices"
                                                             ofType: @"bin"];

            NSError * error = nil;
            [NSFileManager.defaultManager copyItemAtPath: pricesPath
                                                  toPath: self.URLForPrices.path
                                                   error: &error];

            if(error)
            {
                NSLog(@"Failed to set prices path with error: %@", error.localizedDescription);
            }

            // We want to check for an update
            wantToCheckPricesForUpdate = YES;
        } // End of prices path does not exist

        NSArray * tempPrices = [self loadPricesFromPath: self.URLForPrices.path
                                              timestamp: &currentPriceTimestamp];

        // Only replace if we have prices
        if(tempPrices)
        {
            prices = tempPrices;
        } // End of we had prices
    } // End of still no prices

    [loadingSemaphore signal];

    if(wantToCheckPricesForUpdate)
    {
        [self beginUpdatePrices];
    }
} // End of loadPrices

+ (NSArray<MTGPriceForCard*>*) loadPricesFromPath: (NSString*) pricesPath
                                        timestamp: (NSUInteger*) pTimestamp
{
    NSMutableArray<MTGPriceForCard*>* prices = nil;
    void * pricesBuffer = NULL;
    long totalBytes     = 0;
    NSUInteger totalEntries = 0;

    prices = @[].mutableCopy;

    MachTimer * binaryLoadTimer = [MachTimer startTimer];

    /* declare a file pointer */
    FILE    * infile;

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

#define kTimestampSize          8

    totalEntries = (totalBytes - kTimestampSize) / sizeof(MTGPriceEntry);
    NSLog(@"Prices binary loading took %0.02f seconds", binaryLoadTimer.elapsedSeconds);

    prices = @[].mutableCopy;

    NSDecimalNumber * oneHundredDecimalNumbrer = [[NSDecimalNumber alloc] initWithInt: 1000];

    NSUInteger timestamp = *((NSUInteger *)pricesBuffer);
    NSDate * date = [NSDate dateWithTimeIntervalSince1970: timestamp];
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    formatter.dateStyle = NSDateFormatterMediumStyle;
    formatter.timeStyle = NSDateFormatterMediumStyle;


    NSString * dateString = [formatter stringFromDate: date];
    (void) dateString; // Just voided so we get no 'Unused variable' warning. I want it here so I can see the value during debugging.

    MTGPriceEntry * priceEntry = pricesBuffer + kTimestampSize;
    for(NSInteger index = 0; index < totalEntries; ++index)
    {
        MTGPriceForCard * priceForCard = [[MTGPriceForCard alloc] init];

        // Note: This is probably over thought and NSDecimalNumbers are problaby not needed,
        // but since we are dealing with currency I decided to use it.
        priceForCard.lowPrice     = [[NSDecimalNumber alloc] initWithInt: priceEntry->lowPrice];
        priceForCard.mediumPrice  = [[NSDecimalNumber alloc] initWithInt: priceEntry->mediumPrice];
        priceForCard.highPrice    = [[NSDecimalNumber alloc] initWithInt: priceEntry->highPrice];

        priceForCard.lowPrice = [priceForCard.lowPrice decimalNumberByDividingBy: oneHundredDecimalNumbrer];
        priceForCard.mediumPrice = [priceForCard.mediumPrice decimalNumberByDividingBy: oneHundredDecimalNumbrer];
        priceForCard.highPrice = [priceForCard.highPrice decimalNumberByDividingBy: oneHundredDecimalNumbrer];

        // Set our multiverseId
        NSUInteger multiverseId = priceEntry->multiverseId;
        priceForCard.multiverseId = multiverseId;

        [prices addObject: priceForCard];

        ++priceEntry;
    }

    // If we have prices and a prices count
    if(prices && prices.count && pTimestamp)
    {
        *pTimestamp = timestamp;
    } // End of we have a timestamp pointer specified

    return prices;
}

@end
