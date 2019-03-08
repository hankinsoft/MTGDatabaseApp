//
//  SettingsViewController.m
//  MTG Deck Builder
//
//  Created by Kyle Hankinson on 10-08-28.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "MTGSettingsViewController.h"
#import "MTGCard.h"
#import "AppDelegate.h"
#import "AboutViewController.h"
#import "CardGridViewController.h"

@interface MTGSettingsViewController ()
{
    IBOutlet UITableView            * settingsTable;
}

@property (nonatomic, retain) ImageCacheDownloader		* imageCacheDownloader;
@property (nonatomic, retain) NSDictionary				* settingsCells;
@end

@implementation MTGSettingsViewController
{
    NSString        * folderDisplaySize;
    NSUInteger      downloadedCardsCount;
    NSUInteger      totalCards;
}

@synthesize detailViewController;
@synthesize imageCacheDownloader;
@synthesize settingsCells;

#pragma mark -
#pragma mark View lifecycle

- (id)initWithRevealBlock:(RevealBlock)revealBlock
{
    if (self = [super initWithNibName:nil bundle:nil])
    {
		_revealBlock = [revealBlock copy];
		self.navigationItem.leftBarButtonItem = [GHRootViewController generateMenuBarButtonItem: self
                                                                                       selector: @selector(revealSidebar)];
	}
	return self;
}

- (void) revealSidebar
{
	_revealBlock();
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Settings";
    self.navigationController.navigationBar.barStyle = [AppDelegate barButtonStyle];

	static NSString * CellIdentifier = @"SettingsCellIdentifier";
	NSMutableDictionary * settingsDictionary = [[NSMutableDictionary alloc] init];

    weakify(self);
    [[AppDelegate databaseQueue] inDatabase: ^(FMDatabase * database) {
        strongify(self);

        FMResultSet * results = [database executeQuery: @"SELECT COUNT(DISTINCT multiverseId) FROM card"];
        while([results next])
        {
            self->totalCards = [results intForColumnIndex: 0];
        }
    }];

    NSError * error = nil;
    folderDisplaySize = [self nr_getAllocatedSizeOfDirectoryAtURL: [NSURL fileURLWithPath: [AppDelegate cardsPath]]
                                                            error: &error];

    // Create our cache options
	NSMutableArray	* cellArray;
	UITableViewCell * cell;

    cellArray = [[NSMutableArray alloc] init];
    if ( [AppDelegate isIPad] )
    {
		cell = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleSubtitle
                                      reuseIdentifier: CellIdentifier];
		cell.textLabel.text = @"Auto cache";

		[cellArray addObject: cell];
    }

    cell = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleSubtitle
                                  reuseIdentifier: CellIdentifier];

    cell.textLabel.text = @"Clear cache";
    [cellArray addObject: cell];

    [settingsDictionary setObject: cellArray forKey: @"Image Cache"];

	[self setSettingsCells: settingsDictionary];
}

- (void) viewWillAppear: (BOOL) animated
{
    NSError * error = nil;
    NSArray * fileList = [[NSFileManager defaultManager] contentsOfDirectoryAtPath: [AppDelegate cardsPath] error: &error];
    downloadedCardsCount = [fileList count];

    [settingsTable reloadData];
    
    [ImageCacheDownloader setDelegate: self];

    [super viewWillAppear:animated];
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [ImageCacheDownloader setDelegate: nil];
}

/*
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}
*/

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if ( 0 == section)
    {
        return @"Image Cache";
    }
    else if ( 1 == section)
    {
        return @"Usage";
    }
    
    return @"";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	NSString * key = [self tableView:tableView titleForHeaderInSection: section];
	NSArray * cells = [self.settingsCells objectForKey: key];

    // Return the number of rows in the section.
    return [cells count];
}

// Customize the appearance of table view cells.
- (UITableViewCell *) tableView: (UITableView *) tableView
          cellForRowAtIndexPath: (NSIndexPath *)indexPath
{
    static UIImage * checkedImage = nil;
    static UIImage * uncheckedImage = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        checkedImage = [UIImage imageNamed:@"SquareCheckbox_yes.png"];
        uncheckedImage = [UIImage imageNamed:@"SquareCheckbox_no.png"];
    });

	NSString * key = [self tableView:tableView titleForHeaderInSection:indexPath.section];
	NSArray * cells = [self.settingsCells objectForKey: key];

    UITableViewCell * cell = [cells objectAtIndex: indexPath.row];

    if(NSOrderedSame == [@"Auto cache" caseInsensitiveCompare: cell.textLabel.text])
    {
        if([ImageCacheDownloader enabled])
        {
            [[cell imageView] setImage: checkedImage];
        }
        else
        {
            [[cell imageView] setImage: uncheckedImage];
        }

        NSString * baseString =
            [NSString stringWithFormat: @"%lu of %lu cached.",
                (unsigned long)downloadedCardsCount, (unsigned long)totalCards];

        NSMutableString * displayString = [[NSMutableString alloc] initWithString:baseString];

        uint64_t freeDiskSpace = [self getFreeDiskspace];
        if(freeDiskSpace < 1024 * 1024 * 100)
        {
            [displayString appendString: @" Free disk space is less than 100mb. Images may be unable to download."];
        }

        cell.detailTextLabel.text = displayString;
        cell.detailTextLabel.textColor = [[UIColor whiteColor] colorWithAlphaComponent: 0.60];
    }
    else if(NSOrderedSame == [@"Clear cache" caseInsensitiveCompare: cell.textLabel.text])
    {
        cell.detailTextLabel.text = folderDisplaySize;
        cell.detailTextLabel.textColor = [[UIColor whiteColor] colorWithAlphaComponent: 0.60];
    } // End of clearCache

	return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	// Deselect our row
	[tableView deselectRowAtIndexPath: indexPath animated:YES];

	// Get the selected item
	UITableViewCell * cell = [tableView cellForRowAtIndexPath: indexPath];

	if ( [@"Auto cache" isEqualToString: cell.textLabel.text] )
	{
        [ImageCacheDownloader setEnabled: ![ImageCacheDownloader enabled]];
        [settingsTable reloadData];
	} // End of cache
	else if ( [@"Clear cache" isEqualToString: cell.textLabel.text] )
	{
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Clear Cache?" message:@"Clearing the image cache will free space on your device but may slow down the application. Do you want to clear your cache?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK",nil];
		alert.delegate = self;
		[alert show];
	} // End of clear cache
}

- (void)   alertView: (UIAlertView *) alertView
clickedButtonAtIndex: (NSInteger) buttonIndex
{
	if ( 1 == buttonIndex )
	{
		NSLog( @"Clearing image cache" );
		NSFileManager * fileManager = [NSFileManager defaultManager];

		NSError * error = nil;

		// Try to remove and re-create our cards directory
		[fileManager removeItemAtPath:[AppDelegate cardsPath] error: &error];
		[fileManager createDirectoryAtPath: [AppDelegate cardsPath]
			   withIntermediateDirectories: YES
								attributes: nil
									 error: nil];

        error = nil;
        NSArray * fileList = [[NSFileManager defaultManager] contentsOfDirectoryAtPath: [AppDelegate cardsPath] error: &error];
        downloadedCardsCount = [fileList count];
        
        NSLog(@"Total downloadedCards: %lu", (unsigned long)downloadedCardsCount);
        
        [settingsTable reloadData];
	}
}

#pragma mark -
#pragma mark HUD & ImageCacheDownloader delegation

- (void) imageCacheProgressChanged: (float) progress
{
    NSError * error = nil;
    NSString * folderSize = [self nr_getAllocatedSizeOfDirectoryAtURL: [NSURL fileURLWithPath: [AppDelegate cardsPath]]
                                                                error: &error];

    weakify(self);
    dispatch_async(dispatch_get_main_queue(), ^{
        strongify(self);

        ++self->downloadedCardsCount;
        self->folderDisplaySize = folderSize;
        [self->settingsTable reloadData];
    });
}

#pragma mark -
#pragma mark MKStoreKitDelegate

- (void) productPurchased: (NSString *) productId
{
	NSLog( @"Product id: %@ was purchased.", productId );

    UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"Ads Removed" message:@"All advertisements have been removed." delegate:self cancelButtonTitle: nil otherButtonTitles:nil];

    [alertView setDelegate: self];
    [alertView show];
} // End of productPurchased

- (void) transactionCanceled
{
	NSLog( @"Transaction cancelled" );
	
	[self.navigationItem.rightBarButtonItem setEnabled: YES];
}

- (void) productFetchComplete
{
	NSLog( @"Product fetch complete" );
}

- (NSString*) nr_getAllocatedSizeOfDirectoryAtURL:(NSURL *)directoryURL error:(NSError * __autoreleasing *)error
{
    NSParameterAssert(directoryURL != nil);
    
    // We'll sum up content size here:
    unsigned long long accumulatedSize = 0;
    
    // prefetching some properties during traversal will speed up things a bit.
    NSArray *prefetchedProperties = @[
                                      NSURLIsRegularFileKey,
                                      NSURLFileAllocatedSizeKey,
                                      NSURLTotalFileAllocatedSizeKey,
                                      ];
    
    // The error handler simply signals errors to outside code.
    __block BOOL errorDidOccur = NO;
    BOOL (^errorHandler)(NSURL *, NSError *) = ^(NSURL *url, NSError *localError) {
        if (error != NULL)
            *error = localError;
        errorDidOccur = YES;
        return NO;
    };

    // We have to enumerate all directory contents, including subdirectories.
    NSDirectoryEnumerator *enumerator = [[NSFileManager defaultManager] enumeratorAtURL:directoryURL
                                                             includingPropertiesForKeys:prefetchedProperties
                                                                                options:(NSDirectoryEnumerationOptions)0
                                                                           errorHandler:errorHandler];
    
    // Start the traversal:
    for (NSURL *contentItemURL in enumerator)
    {
        
        // Bail out on errors from the errorHandler.
        if (errorDidOccur)
        {
            return @"Unknown";
        }

        // Get the type of this item, making sure we only sum up sizes of regular files.
        NSNumber *isRegularFile;
        if (! [contentItemURL getResourceValue:&isRegularFile forKey:NSURLIsRegularFileKey error:error])
        {
            return @"Unknown";
        }

        if (! [isRegularFile boolValue])
        {
            continue; // Ignore anything except regular files.
        }
        
        // To get the file's size we first try the most comprehensive value in terms of what the file may use on disk.
        // This includes metadata, compression (on file system level) and block size.
        NSNumber *fileSize;
        if (! [contentItemURL getResourceValue:&fileSize forKey:NSURLTotalFileAllocatedSizeKey error:error])
        {
            return @"Unknown";
        }
        
        // In case the value is unavailable we use the fallback value (excluding meta data and compression)
        // This value should always be available.
        if (fileSize == nil)
        {
            if (! [contentItemURL getResourceValue: &fileSize
                                            forKey: NSURLFileAllocatedSizeKey
                                             error: error])
            {
                return @"Unknown";
            }

            NSAssert(fileSize != nil, @"huh? NSURLFileAllocatedSizeKey should always return a value");
        }
        
        // We're good, add up the value.
        accumulatedSize += [fileSize unsignedLongLongValue];
    }
    
    // Bail out on errors from the errorHandler.
    if (errorDidOccur)
    {
        return @"Unknown";
    }

    //This line will give you formatted size from bytes ....
    NSString *folderSizeStr = [NSByteCountFormatter stringFromByteCount: accumulatedSize
                                                             countStyle: NSByteCountFormatterCountStyleFile];

    return folderSizeStr;
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (uint64_t) getFreeDiskspace
{
    uint64_t totalSpace = 0;
    uint64_t totalFreeSpace = 0;
    NSError *error = nil;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSDictionary *dictionary = [[NSFileManager defaultManager] attributesOfFileSystemForPath:[paths lastObject] error: &error];

    if (dictionary)
    {
        NSNumber *fileSystemSizeInBytes = [dictionary objectForKey: NSFileSystemSize];
        NSNumber *freeFileSystemSizeInBytes = [dictionary objectForKey:NSFileSystemFreeSize];
        totalSpace = [fileSystemSizeInBytes unsignedLongLongValue];
        totalFreeSpace = [freeFileSystemSizeInBytes unsignedLongLongValue];
    }
    else
    {
        NSLog(@"Error Obtaining System Memory Info: Domain = %@, Code = %ld",
              [error domain], (long)[error code]);
    }
    
    return totalFreeSpace;
}

@end

