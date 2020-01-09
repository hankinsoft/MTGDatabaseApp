//
//  AppDelegate.m
//  MTG Deck Builder
//
//  Created by Kyle Hankinson on 10-06-15.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

// NOTES:
// https://www.slightlymagic.net/forum/viewtopic.php?f=15&t=7010&start=315

#import "AppDelegate.h"
#import "MTGSmartSearch.h"
#import "MTGCard.h"
#import "MTGCardSet.h"
#import "BrowseSetViewController.h"
#import "BrowseFormatViewController.h"
#import "MTGBrowseAbilitiesViewController.h"
#import "CardGridViewController.h"
#import "DeckBuilderViewController.h"
#import "UpdateDatabaseViewController.h"
#import "NSString+Extras.h"

#import "GHMenuCell.h"
#import "GHMenuViewController.h"
#import "GHRootViewController.h"
#import "GHRevealViewController.h"


#import "AboutViewController.h"
#import "RulesViewController.h"
#import "MTGSettingsViewController.h"
#import "MTGSmartSearchViewController.h"
#import "CardDetailsViewController.h"

#import "SearchBarWithSpinner.h"

#import "SQLProAppearanceManager.h"
#import "MTGPriceManager.h"
#import "MTGCardSetIconHelper.h"

#import "SQLProLogHelperDelegate.h"
#import "MTGLifeCounterViewController.h"
#import "MTGLifeCounter.h"
#import "MTGLifeCounterSettingsViewController.h"
#import "UIColor+Hex.h"

@import AppCenter;
@import AppCenterAnalytics;
@import AppCenterCrashes;

@interface AppDelegate ()
{
    RevealBlock                 revealBlock;
    
    CardGridViewController      * browseCardsViewController;
    BrowseSetViewController     * browseSetViewController;
    BrowseFormatViewController  * browseFormatViewController;
    MTGBrowseAbilitiesViewController  * browseAbilitiesViewController;
    DeckBuilderViewController   * deckBuilderViewController;
}

@property (nonatomic, strong) GHRevealViewController *revealController;
@property (nonatomic, strong) GHMenuViewController *menuController;

- (BOOL) addSkipBackupAttributeToItemAtURL:(NSURL *)URL;
- (void) getSetIcons;

@end

@implementation AppDelegate

@synthesize window;

@synthesize revealController, menuController;

#pragma mark -
#pragma mark Application lifecycle

static dispatch_semaphore_t    databaseUpdateSemaphore;

+ (NSString*) PurchaseUpdatedNotification
{
    return @"MTG-Purchase-Notification";
}

+ (void) initialize
{
    databaseUpdateSemaphore   = dispatch_semaphore_create(1);
}

+ (UIBarStyle) barButtonStyle
{
    return UIBarStyleDefault;
}

- (void) initLogging
{
    // Set our log helper
    [[HSLogHelper sharedInstance] setDelegate: [SQLProLogHelperDelegate sharedInstance]];
    
    [DDLog addLogger: [DDASLLogger sharedInstance]]; // Apple console logging
#if DEBUG
    [DDLog addLogger: [DDTTYLogger sharedInstance]]; // XCode debugger if applicable
#endif
    
//    [DDLog addLogger: [CrashlyticsLogger sharedInstance]];
    
    [DDLog addLogger: [SQLProLogHelperDelegate sharedInstance].fileLogger];
    
    NSString * version = [[[NSBundle mainBundle] infoDictionary] valueForKey:@"CFBundleVersion"];
    
    DDLogInfo(@"Application %@ v%@ has launched.",
              [[NSBundle mainBundle] bundleIdentifier],
              version);
} // End of initLogging

- (BOOL)          application: (UIApplication *) application
didFinishLaunchingWithOptions: (NSDictionary *) launchOptions
{
    [[NSUserDefaults standardUserDefaults] registerDefaults: @{kMTGLockScreenIdleTimerDisabled: @(YES)}];

    [self initLogging];
    [self initializeTheme];

    [MSAppCenter start:@"6ab96e92-eb55-4ad6-bf96-8f40d3709ecf" withServices:@[
                                                                              [MSAnalytics class],
                                                                              [MSCrashes class]
                                                                              ]];

    [MSCrashes setDelegate: [SQLProLogHelperDelegate sharedInstance]];

    NSDictionary * defaults = @{@"toggleMode":[NSNumber numberWithInt: 0]};

    [[NSUserDefaults standardUserDefaults] registerDefaults: defaults];

    // Initialize our database
    [self initializeDatabaseOnApplicationFreshStart];

    // Configure our main window
    [self configureMainWindow];

    NSFileManager * fileManager = [NSFileManager defaultManager];

    // Create our cards directory if it does not exist
    if (![fileManager fileExistsAtPath: [AppDelegate cardsPath]])
    {
		[fileManager createDirectoryAtPath: [AppDelegate cardsPath]
			   withIntermediateDirectories: YES
								attributes: nil
									 error: nil];
    } // End of create cards directory if required

    NSLog(@"Application finished launching");

    // ImageCacheDownloader is disabled by default. (TODO: Fix in future)
    [ImageCacheDownloader setPaused: YES];

    return YES;
}

- (void) applicationWillEnterForeground: (UIApplication *) application
{
} // End of applicationWillEnterForeground:

- (void) configureMainWindow
{
   	[[UIApplication sharedApplication] setStatusBarStyle: UIStatusBarStyleLightContent
                                                animated: NO];

	UIColor *bgColor = [UIColor colorWithRed:(54.0f/255.0f)
                                       green:(54.0f/255.0f)
                                        blue:(54.0f/255.0f)
                                       alpha:1.0f];

    self.revealController = [[GHRevealViewController alloc] initWithNibName:nil bundle:nil];
    self.revealController.view.backgroundColor = bgColor;
    
    AppDelegate * appDelegate = self;
    revealBlock = ^(){
        [appDelegate.revealController toggleSidebar: !appDelegate.revealController.sidebarShowing
                                           duration: kGHRevealSidebarDefaultAnimationDuration];
    };

    NSMutableArray *headers = @[
                         @"BROWSE",
                         @"CARDS",
                         @"GENERAL"
                         ].mutableCopy;

    browseCardsViewController = [[CardGridViewController alloc] initWithRevealBlock: revealBlock];

    // Note - no need to customize the smart search default. It will use the users
    // saved preference, or if none exist than the default sort order.
    MTGSmartSearch * smartSearch = [[MTGSmartSearch alloc] init];
    browseCardsViewController.smartSearch = smartSearch;

    browseSetViewController = [[BrowseSetViewController alloc] initWithRevealBlock: revealBlock];

    MTGNavigationController * browseSetsNavigationController = [[MTGNavigationController alloc] initWithRootViewController: browseSetViewController];

    browseFormatViewController = [[BrowseFormatViewController alloc] initWithRevealBlock: revealBlock];
    
    MTGNavigationController * browseFormatsNavigationController = [[MTGNavigationController alloc] initWithRootViewController: browseFormatViewController];

    browseAbilitiesViewController = [[MTGBrowseAbilitiesViewController alloc] initWithRevealBlock: revealBlock];

    MTGNavigationController * browseAbilitiesNavigationController = [[MTGNavigationController alloc] initWithRootViewController: browseAbilitiesViewController];
    
    deckBuilderViewController = [[DeckBuilderViewController alloc] initWithRevealBlock: revealBlock];
    MTGNavigationController * deckBuilderNavigationController = [[MTGNavigationController alloc] initWithRootViewController: deckBuilderViewController];
    
    MTGNavigationController * advancedSearchNavigationController = [[MTGNavigationController alloc] initWithRootViewController: [[MTGSmartSearchViewController alloc] initWithRevealBlock: revealBlock]];

    NSMutableArray *controllers = @[
                             @[
                                 [[MTGNavigationController alloc] initWithRootViewController: browseCardsViewController],
                                 browseSetsNavigationController,
                                 browseFormatsNavigationController,
                                 browseAbilitiesNavigationController,
                             ],
                             @[
                                 advancedSearchNavigationController,
                                 deckBuilderNavigationController
                             ],
                             @[
                                 [[MTGNavigationController alloc] initWithRootViewController: [[MTGLifeCounterViewController alloc] initWithRevealBlock: revealBlock]],
                                 [[MTGNavigationController alloc] initWithRootViewController: [[RulesViewController alloc] initWithRevealBlock: revealBlock]],
                                 [[MTGNavigationController alloc] initWithRootViewController: [[MTGSettingsViewController alloc] initWithRevealBlock: revealBlock]]
                                 ]
                             ].mutableCopy;

    NSMutableArray *cellInfos = @[
                           @[
                               @{kSidebarCellImageKey: [UIImage imageNamed:@"Menu_Cards"], kSidebarCellTextKey: NSLocalizedString(@"by Card", @"")},
                               @{kSidebarCellImageKey: [UIImage imageNamed:@"Menu_Formats"], kSidebarCellTextKey: NSLocalizedString(@"by Sets", @"")},
                               @{kSidebarCellImageKey: [UIImage imageNamed:@"Menu_Sets"], kSidebarCellTextKey: NSLocalizedString(@"by Formats", @"")},
                               @{kSidebarCellImageKey: [UIImage imageNamed:@"Menu_Abilities"], kSidebarCellTextKey: NSLocalizedString(@"by Abilities", @"")},
                               ],
                           @[
                               @{kSidebarCellImageKey: [UIImage imageNamed:@"Menu_Search"], kSidebarCellTextKey: NSLocalizedString(@"Advanced search", @"")},
                               @{kSidebarCellImageKey: [UIImage imageNamed:@"Menu_Decks"], kSidebarCellTextKey: NSLocalizedString(@"My collections", @"")},
                            ],
                           @[
                               @{kSidebarCellImageKey: [UIImage imageNamed:@"Menu_LifeCounter"], kSidebarCellTextKey: NSLocalizedString(@"Life counter", @"")},
                               @{kSidebarCellImageKey: [UIImage imageNamed:@"Menu_Rules"], kSidebarCellTextKey: NSLocalizedString(@"Rules", @"")},
                               @{kSidebarCellImageKey: [UIImage imageNamed:@"Menu_Settings"], kSidebarCellTextKey: NSLocalizedString(@"Settings", @"")}
                            ]
                        ].mutableCopy;

    // Add drag feature to each root navigation controller
    [controllers enumerateObjectsUsingBlock :^(id obj, NSUInteger idx, BOOL *stop){
        [((NSArray *)obj) enumerateObjectsUsingBlock: ^(id obj2, NSUInteger idx2, BOOL *stop2) {
            if([obj2 isKindOfClass: [UINavigationController class]])
            {
                UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self.revealController
                                                                                             action:@selector(dragContentView:)];
                panGesture.cancelsTouchesInView = YES;
                [((MTGNavigationController *)obj2).navigationBar addGestureRecognizer:panGesture];
            }
        }];
    }];

    self.menuController = [[GHMenuViewController alloc] initWithSidebarViewController: self.revealController
                                                                          withHeaders:headers
                                                                      withControllers:controllers 
                                                                        withCellInfos:cellInfos];

    // Launched
    [[HSLogHelper sharedInstance] logMessage: @"Launched"];
    
    [[SQLProAppearanceManager sharedInstance] updateTheme: SQLProThemeDark
                                          completionBlock: ^{
        // Create our window
        self.window.rootViewController = self.revealController;
        [self.window makeKeyAndVisible];
    }];
} // End of configureMainWindow

- (void) initializeDatabaseOnApplicationFreshStart
{
    [[AppDelegate databaseQueue] inDatabase: ^(FMDatabase * database) {
        FMResultSet * results = nil;
        results = [database executeQuery: @"SELECT DISTINCT value FROM settings WHERE name = 'databaseVersion'"];

        while([results next])
        {
            NSInteger version = [results intForColumnIndex: 0];
            [[NSUserDefaults standardUserDefaults] setInteger: version
                                                       forKey: DATABASE_VERSION_KEY];
            NSLog(@"Settings database version to be: %ld", (long) version);
        }

        [results close];
    }];
}

- (void) applicationDidEnterBackground:(UIApplication *)application
{
    [ImageCacheDownloader setPaused: YES];
}

- (void) applicationWillTerminate: (UIApplication *) application
{
}

- (void) applicationDidBecomeActive:(UIApplication *)application
{
    [MTGCardSetIconHelper downloadMissingIcons];
    [browseFormatViewController loadFormats];
    [ImageCacheDownloader setPaused: YES];

    NSLog(@"Application became active");

    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [MTGPriceManager beginUpdatePrices];
    });
} // End of app became active

+ (NSString*) cardsPath
{
    static NSString * docDirectory = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSArray  * sysPaths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES );
        docDirectory = [[NSString alloc] initWithFormat: @"%@/cards", [sysPaths objectAtIndex:0]];
    });

    return docDirectory;
} // End of cardsPath

#pragma mark -
#pragma mark Database

+ (int) databaseVersion
{
	return 101;
}

+ (NSInteger) cardPriceVersion
{
    if ( nil == [[NSUserDefaults standardUserDefaults] objectForKey: @"CardPriceVersion"] )
    {
        [[NSUserDefaults standardUserDefaults] setInteger: 0 forKey: @"CardPriceVersion"];
    }

    return [[NSUserDefaults standardUserDefaults] integerForKey: @"CardPriceVersion"];
} // End of cardPriceVersion

+ (void) setCardPriceVersion: (NSInteger) version
{
    [[NSUserDefaults standardUserDefaults] setInteger: version
                                               forKey: @"CardPriceVersion"];
}

- (BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)URL
{
    NSError *error = nil;
    [URL setResourceValue:[NSNumber numberWithBool:YES] forKey:NSURLIsExcludedFromBackupKey error:&error];
    return error == nil;
}

+ (BOOL) isIPad
{
	return [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad;
}

+ (AppDelegate*) instance
{
	return (AppDelegate*)[[UIApplication sharedApplication] delegate];
} // End of instance

+ (FMDatabaseQueue*) databaseQueue
{
    FMDatabaseQueue * dbQueue = nil;

    static NSString * latestDatabasePath = nil;
    static NSString * bundledDatabasePath = nil;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory , NSUserDomainMask, YES);
        NSString *documentsDir = [paths objectAtIndex:0];
        latestDatabasePath = [documentsDir stringByAppendingPathComponent: @"mtg.sqlite"];

        NSBundle * databaseBundle = [NSBundle bundleWithIdentifier: @"com.hankinsoft.MTGDatabase"];
        bundledDatabasePath = [databaseBundle.resourcePath stringByAppendingPathComponent: @"mtg.sqlite"];
    });

    // Try loading our latest file if it exists.
    if([[NSFileManager defaultManager] fileExistsAtPath: latestDatabasePath])
    {
        // Try and open documents database first as it contains newer details.
        dbQueue = [[FMDatabaseQueue alloc] initWithPath: latestDatabasePath
                                                  flags: SQLITE_OPEN_READONLY];
    } // End of documents file exists

    if(nil == dbQueue)
    {
        dbQueue = [[FMDatabaseQueue alloc] initWithPath: bundledDatabasePath
                                                  flags: SQLITE_OPEN_READONLY];
    } // End of no local dbQueue

    [dbQueue inDatabase: ^(FMDatabase * _Nonnull db) {
        [db makeFunctionNamed: @"highPrice"
             maximumArguments: 1
                    withBlock: ^(void *context, int argc, void **argv) {
                        int dataType = sqlite3_value_type(argv[0]);
                        if(dataType == SQLITE_INTEGER)
                        {
                            int multiverseId = sqlite3_value_int(argv[0]);
                            float price = [MTGPriceManager priceForMultiverseId: multiverseId].highPrice.floatValue;
                            sqlite3_result_int(context, (int)price);
                        }
                        else if(dataType == SQLITE_TEXT)
                        {
                            const unsigned char *a = sqlite3_value_text(argv[0]);
                            const unsigned char *b = sqlite3_value_text(argv[1]);
                            
                            CFStringRef as = CFStringCreateWithCString(0x00, (const char*)a, kCFStringEncodingUTF8);
                            CFStringRef bs = CFStringCreateWithCString(0x00, (const char*)b, kCFStringEncodingUTF8);
                            
                            sqlite3_result_int(context, UTTypeConformsTo(as, bs));
                            
                            CFRelease(as);
                            CFRelease(bs);
                        }
                        else
                        {
                            NSLog(@"Unknown formart for UTTypeConformsToSQLiteCallBackFunction (%d) %s:%d", sqlite3_value_type(argv[0]), __FUNCTION__, __LINE__);
                            sqlite3_result_null(context);
                        }
                    }];

        [db makeFunctionNamed: @"rarityIndex"
                    arguments: 1
                        block: ^(void *context, int argc, void **argv) {
                            int dataType = sqlite3_value_type(argv[0]);
                            if(dataType == SQLITE_TEXT)
                            {
                                const unsigned char *a = sqlite3_value_text(argv[0]);
                                
                                CFStringRef as = CFStringCreateWithCString(0x00, (const char*)a, kCFStringEncodingUTF8);
                                
                                int returnValue = 0;
                                
                                NSString * rarity = (__bridge NSString *)as;
                                if(nil == rarity || 0 == rarity.length)
                                {
                                    returnValue = 10;
                                }
                                else if(NSOrderedSame == [@"basic land" caseInsensitiveCompare: rarity])
                                {
                                    returnValue = 0;
                                }
                                else if(NSOrderedSame == [@"land" caseInsensitiveCompare: rarity])
                                {
                                    returnValue = 0;
                                }
                                else if(NSOrderedSame == [@"common" caseInsensitiveCompare: rarity])
                                {
                                    returnValue = 1;
                                }
                                else if(NSOrderedSame == [@"uncommon" caseInsensitiveCompare: rarity])
                                {
                                    returnValue = 2;
                                }
                                else if(NSOrderedSame == [@"rare" caseInsensitiveCompare: rarity])
                                {
                                    returnValue = 3;
                                }
                                else if(NSOrderedSame == [@"Mythic Rare" caseInsensitiveCompare: rarity])
                                {
                                    returnValue = 4;
                                }
                                else if(NSOrderedSame == [@"Special" caseInsensitiveCompare: rarity])
                                {
                                    returnValue = 5;
                                }
                                else if(NSOrderedSame == [@"Bonus" caseInsensitiveCompare: rarity])
                                {
                                    returnValue = 6;
                                }
                                else
                                {
                                    NSLog(@"UNKNOWN");
                                }
                                
                                sqlite3_result_int(context, returnValue);
                                
                                CFRelease(as);
                            }
                            else
                            {
                                NSLog(@"Unknown formart for UTTypeConformsToSQLiteCallBackFunction (%d) %s:%d", sqlite3_value_type(argv[0]), __FUNCTION__, __LINE__);
                                sqlite3_result_null(context);
                            }
                        }];
    }];

    // returns the same object each time
    return dbQueue;
}

- (void) getSetIcons
{
    NSArray * iconTypes = [NSArray arrayWithObjects: @"Common", @"Mythic Rare", @"Uncommon", @"Rare", nil];

	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory , NSUserDomainMask, YES);
	NSString *documentsDir = [paths objectAtIndex:0];

    [[AppDelegate databaseQueue] inDatabase:
     ^(FMDatabase * database)
    {
        FMResultSet * results = [database executeQuery: @"SELECT DISTINCT shortName FROM cardSet"];
        while ([results next])
        {
            NSString * setShortName = [results stringForColumnIndex: 0];

            // Loop through our icon type
            for (NSString * iconType in iconTypes)
            {
                NSString * fileName = [NSString stringWithFormat: @"setImage-%@%@.png", setShortName, [iconType substringToIndex: 1]];
                NSString * bundleIconPath = [[NSBundle mainBundle] pathForResource: fileName ofType: nil];
                NSString * tempIconPath   = [documentsDir stringByAppendingPathComponent: fileName];

                // If the file does not exist, then
                if(![[NSFileManager defaultManager] fileExistsAtPath: bundleIconPath] &&
                   ![[NSFileManager defaultManager] fileExistsAtPath: tempIconPath])
                {
                    NSString * targetFile = [NSString stringWithFormat: @"http://www.magicthegatheringdatabase.com/images/set/%@", [fileName stringByReplacingOccurrencesOfString: @" " withString: @"%20"]];

//                    NSLog(@"Need to download: %@", targetFile);

                    NSURL  *url = [NSURL URLWithString: targetFile];
                    NSData *urlData = [NSData dataWithContentsOfURL:url];

                    if ( urlData )
                    {
                        if(![urlData writeToFile: tempIconPath atomically:YES])
                        {
                            NSLog(@"Failed to download icon :S");
                        }
                        else
                        {
                            NSLog(@"Successful save of: %@", tempIconPath);
                        }
                    }
                } // End of file exists
            } // End of for loop
        } // End of foreach sqlite loop
    }]; // End of database statement worked

    NSLog(@"Finished get set icons");
}

- (void) initializeTheme
{
    [[UINavigationBar appearance] setBackgroundImage: [UIImage new]
                                       forBarMetrics: UIBarMetricsDefault];
    
    UIColor * borderColor = [@"#3d3d3d" hexToColor];
    UIImage * borderImage = [borderColor solidImageWithWidth: 1
                                                      height: 1];
    
    [[UINavigationBar appearance] setShadowImage: borderImage];
    
    [[UITabBar appearance] setBackgroundImage: [UIImage new]];
    [[UITabBar appearance] setShadowImage: borderImage];

    UIColor * toolbarColor =
        [UIColor colorWithRed: 33.0f / 255.0f
                        green: 33.0f / 255.0f
                         blue: 33.0f / 255.0f
                        alpha: 1.0f];

    UIColor * toolbarTintColor =
        [UIColor colorWithRed: 165.0f / 255.0f
                        green: 165.0f / 255.0f
                         blue: 165.0f / 255.0f
                        alpha: 1.0f];

    UIColor * toolbarFontColor = [UIColor whiteColor];

    UIFont * toolbarFont = [UIFont boldSystemFontOfSize: 17];
    NSMutableDictionary * titleTextAttributes = @{
        NSForegroundColorAttributeName: toolbarFontColor,
        NSFontAttributeName: toolbarFont
    }.mutableCopy;

    NSShadow *shadow = [[NSShadow alloc] init];
    shadow.shadowColor = [UIColor colorWithWhite:.0f alpha:1.f];
    shadow.shadowOffset = CGSizeMake(0, -1);

    titleTextAttributes[NSShadowAttributeName] = shadow;

    [[UINavigationBar appearance] setTitleTextAttributes: titleTextAttributes];
    [[UINavigationBar appearance] setBarTintColor: toolbarColor];
    [[UINavigationBar appearance] setTintColor: toolbarTintColor];

    [[UIToolbar appearance] setBarTintColor: toolbarColor];
    [[UIToolbar appearance] setTintColor: toolbarTintColor];

    // hex #43b4fa
    UIColor * tintColor =
        [UIColor colorWithRed: 67.0f  / 255.0f
                        green: 180.0f / 255.0f
                         blue: 250.0f / 255.0f
                        alpha: 1.0f];

    [[UISwitch appearance] setOnTintColor: tintColor];
    [[UISlider appearance] setTintColor: tintColor];

    [[UISegmentedControl appearance] setTintColor:
        [UIColor colorWithRed: 165.0f / 255.0f
                        green: 165.0f / 255.0f
                         blue: 165.0f / 255.0f
                        alpha: 1.0f]];
}

#pragma mark -
#pragma UIAlertViewDelegate

@end
