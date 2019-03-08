//
//  PriceUpdater.m
//  MTG Deck Builder
//
//  Created by Kyle Hankinson on 11-06-04.
//  Copyright 2011 Hankinsoft. All rights reserved.
//

#import "PriceUpdater.h"
#import "AppDelegate.h"

@interface PriceUpdater ()

+ (BOOL) extract: (NSString*) file;
+ (BOOL) downloadPrices: (NSString *) file;

@end

@implementation PriceUpdater

static dispatch_semaphore_t    pricesSemaphore;
static bool                    terminating;

+ (NSString*) PricesUpdatedNotification
{
    return @"MTG-Prices-Updated-Notification";
}

+ (void) initialize
{
    pricesSemaphore   = dispatch_semaphore_create(1);
    terminating       = NO;
} // End of initialize

+ (void) terminate
{
    terminating = YES;

    // Wait for the prices to finish
    dispatch_semaphore_wait(pricesSemaphore, DISPATCH_TIME_FOREVER);
    NSLog(@"Terminate finished.");
} // End of terminate

+ (void) update
{
    return;

#if TODO
    if(0 != dispatch_semaphore_wait(pricesSemaphore, DISPATCH_TIME_NOW))
    {
        NSLog(@"Price update is already running.");
        return;
    } // End of already running

    dispatch_async(dispatch_get_main_queue(), ^{
        [[MTStatusBarOverlay sharedInstance] postMessage: @"Checking for new prices"
                                                animated: YES];
    });

    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self updateInBackground];

        // Reset our prices token
        dispatch_semaphore_signal(pricesSemaphore);
    });
#endif
} // End of update

+ (void) updateInBackground
{
    return;

#if TODO
    NSLog( @"Started price update" );

    NSString * tempPath = NSTemporaryDirectory();
    NSString * tempFile = [tempPath stringByAppendingPathComponent: @"prices.zip"];

    // Download the update
    if ( ![self downloadPrices: tempFile] )
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[MTStatusBarOverlay sharedInstance] postFinishMessage: @"No new prices available"
                                                          duration: 3
                                                          animated: YES];
        });

        return;
    } // End of failed to downloadPrices

    // Extract our tempFile and get our data
    if (![self extract: tempFile] )
    {
        NSLog(@"Failed to extract temp file.");
        dispatch_async(dispatch_get_main_queue(), ^{
            [[MTStatusBarOverlay sharedInstance] postFinishMessage: @"Finished updating prices"
                                                          duration: 3];
        });
        return;
    } // End of we failed to extract temp file

    // save the downloaded data into a temporary file
    tempFile = [tempPath stringByAppendingPathComponent: @"prices.bin"];

    __block int updated = 0;

    FILE * fp = fopen ( [tempFile UTF8String], "rb" );
    if ( !fp )
    {
        NSLog( @"Failed to open temp file." );

        dispatch_async(dispatch_get_main_queue(), ^{
            [[MTStatusBarOverlay sharedInstance] postFinishMessage: @"Finished updating prices"
                                                          duration: 3];
        });

        return;
    }

    // Read two bytes to ensure we have data and a version
    unsigned int header [3] = {0x00, 0x00, 0x00};

    // Ensure we can read our header and that it has the proper value
    if ( !
        (3 == fread ( &header, sizeof ( unsigned int ), 3, fp ) && header [ 0 ] == 0xFFFF ))
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[MTStatusBarOverlay sharedInstance] postFinishMessage: @"Finished updating prices"
                                                          duration: 3];
        });
        return;
    }

    NSInteger newCardPriceVersion = header[1];
    NSInteger totalCards          = header[2];
    __block NSInteger lastUpdate  = 0;

    NSMutableArray * cards = [NSMutableArray array];
    while ( true )
    {
        if(terminating)
        {
            break;
        }

        CardPrice * cardPrice = malloc(sizeof(CardPrice));
        if ( 0 == fread(cardPrice, sizeof(CardPrice), 1, fp) ) break;

        // Add our card
        [cards addObject: [NSValue valueWithPointer: cardPrice]];
    } // End of loop

    // No longer need our file pointer
    fclose(fp);

    for(NSValue * value in cards)
    {
        CardPrice * cardPrice = value.pointerValue;
        free(cardPrice);
    } // End of loop

    // Update our price version
    [AppDelegate setCardPriceVersion: newCardPriceVersion];

    dispatch_async(dispatch_get_main_queue(), ^{
        // Notify that prices have been updated
        [[NSNotificationCenter defaultCenter] postNotificationName: [PriceUpdater PricesUpdatedNotification]
                                                            object: self];

        [[MTStatusBarOverlay sharedInstance] postFinishMessage: @"Prices are up-to date"
                                                      duration: 3];
    });

    NSLog( @"Finished update (%d)", updated );
#endif
}

+ (BOOL) downloadPrices: (NSString *) file
{
    NSString *url = [NSString stringWithFormat: @"http://hankinsoft.com/iPhone/MTG/downloadPrices.php?version=%ld",
                     (long)[AppDelegate cardPriceVersion]];

    NSLog( @"Want to get prices from %@", url );

    // We got data
    NSData * data = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
    if(nil == data) return NO;

    // Write our data
    [data writeToFile: file
           atomically: YES];

    NSLog(@"Downloaded %ld bytes.", (unsigned long)data.length);

    return YES;
} // End of downloadPrices

+ (BOOL) extract: (NSString*) file
{
    return NO;
#if todo
    // Write to temp directory
    // We need to unzip the file
    CkoZip *zip = [[CkoZip alloc] init];
    zip.VerboseLogging = YES;
    zip.DiscardPaths = YES;
    zip.TempDir      = NSTemporaryDirectory();
    
    if(![zip UnlockComponent: @"KYLHNKZIP_7FAxZSC92Ppx"])
    {
        NSLog(@"Unable to unlock component: %@", zip.LastErrorText);
        return 0;
    }
    
    if(![zip OpenZip: file])
    {
        NSLog(@"Error");
        return 0;
    }
    
    // Unzip to the temp directory
    NSInteger totalFiles = [zip Unzip: NSTemporaryDirectory()].integerValue;
    if(0 == totalFiles)
    {
        NSLog(@"Unable to extract any files.");
        return 0;
    }

    // Close our zip
    [zip CloseZip];

    return YES;
#endif
}

@end
