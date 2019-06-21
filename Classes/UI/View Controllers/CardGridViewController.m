//
//  DetailViewController.m
//  MTG Deck Builder
//
//  Created by Kyle Hankinson on 10-06-15.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "CardGridViewController.h"
#import "BrowseSetViewController.h"
#import "MTGCardSet.h"
#import "MTGCard.h"
#import "CardDetailsViewController.h"
#import "MTGSmartSearch.h"
#import "MTGCardSortOptionsViewController.h"
#import "AppDelegate.h"

#import "ListCardCustomCell.h"

#import "CardCollectionViewCell.h"
#import "HorizontalPagedCollectionViewFlowLayout.h"

#import "HSSearchBarWithSpinner.h"
#import "MTGGridFlowLayout.h"
#import "MTGLargeGridFlowLayout.h"
#import "MTGTableFlowLayout.h"
#import "HSDividerView.h"
#import "DRPLoadingSpinner.h"

#import "SQLProAppearanceManager.h"
#import "MTGCardImageHelper.h"
#import "MTGPriceManager.h"

#define kTableViewReuseIdentifier            @"kMTGTableViewCell"
#define kCollectionViewReuseIdentifier       @"kMTGCollectionViewCell"

@interface CardGridViewController ()<UICollectionViewDataSource, UICollectionViewDelegate, UISearchBarDelegate>
{
    UIPopoverController     * popoverController;

    UIView                  * wrapView;
    UICollectionView        * cardCollectionView;

    // Searching
    IBOutlet HSSearchBarWithSpinner * searchBar;

    UIBarButtonItem                 * settingsButton;

    UIBarButtonItem                 * segmentedBarButtonItem;
    UISegmentedControl              * listStyleSegmentedControl;
}

- (BOOL) isGridViewVisible;
- (void) startLoadingResults;
- (void) endLoadingSequence;

@property (nonatomic, assign) BOOL needsReload;

@end

@implementation CardGridViewController
{
    NSString                    * currentCellIdentifier;
    CGFloat                     searchBarBoundsY;
    RevealBlock                 _revealBlock;
    BOOL                        loading;
    MTGSmartSearch                 * smartSearch;
    BOOL                        needsReload;

    NSArray						* cards;

    NSLayoutConstraint          * searchYOffsetConstraint;
    BOOL                        isRemovingTextWithBackspace;

    MTGGridFlowLayout           * gridFlowLayout;
    MTGTableFlowLayout          * tableFlowLayout;
    MTGLargeGridFlowLayout      * largeGridFlowLayout;
}

@synthesize smartSearch;
@synthesize needsReload;

#pragma mark -
#pragma mark View lifecycle

- (id) init
{
    self = [super initWithNibName: @"CardGridViewController" bundle: nil];
    return self;
} // End of init

- (id) initWithRevealBlock: (RevealBlock) revealBlock
{
    if (self = [self init])
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

- (void) loadView
{
    if(0 == self.title.length)
    {
        self.title = @"Cards";
    }

    [super loadView];

    largeGridFlowLayout = [[MTGLargeGridFlowLayout alloc] init];
    gridFlowLayout = [[MTGGridFlowLayout alloc] init];
    tableFlowLayout = [[MTGTableFlowLayout alloc] init];

    UIColor * backgroundColor = SQLProAppearanceManager.sharedInstance.darkTableBackgroundColor;

    self.extendedLayoutIncludesOpaqueBars = NO;

    self.view.backgroundColor = backgroundColor;

    UIImage * listViewImage = [UIImage imageNamed: @"ModeListView"];
    UIImage * iconViewImage = [UIImage imageNamed: @"ModeIconView"];
    
    NSArray *segItemsArray = @[
                               listViewImage,
                               iconViewImage
                               ];
    
    listStyleSegmentedControl = [[UISegmentedControl alloc] initWithItems: segItemsArray];
    
    [listStyleSegmentedControl setContentMode: UIViewContentModeScaleToFill];
    [listStyleSegmentedControl setWidth: 40
                      forSegmentAtIndex: 0];
    [listStyleSegmentedControl setWidth: 40
                      forSegmentAtIndex: 1];
    
    listStyleSegmentedControl.selectedSegmentIndex = 1;
    [listStyleSegmentedControl addTarget: self
                                  action: @selector(modeToggled:)
                        forControlEvents: UIControlEventValueChanged];
    
    segmentedBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView: (UIView *) listStyleSegmentedControl];

    wrapView = [[UIView alloc] init];
    wrapView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview: wrapView];

    
    if (@available(iOS 11.0, *))
    {
        [wrapView.topAnchor constraintEqualToAnchor: self.view.safeAreaLayoutGuide.topAnchor].active = YES;
        [wrapView.leftAnchor constraintEqualToAnchor: self.view.safeAreaLayoutGuide.leftAnchor].active = YES;
        [wrapView.rightAnchor constraintEqualToAnchor: self.view.safeAreaLayoutGuide.rightAnchor].active = YES;
        [wrapView.bottomAnchor constraintEqualToAnchor: self.view.safeAreaLayoutGuide.bottomAnchor].active = YES;
    }
    else
    {
        [wrapView.topAnchor constraintEqualToAnchor: self.view.topAnchor].active = YES;
        [wrapView.leftAnchor constraintEqualToAnchor: self.view.leftAnchor].active = YES;
        [wrapView.rightAnchor constraintEqualToAnchor: self.view.rightAnchor].active = YES;
        [wrapView.bottomAnchor constraintEqualToAnchor: self.view.bottomAnchor].active = YES;
    }

    UICollectionViewFlowLayout * layout = gridFlowLayout;
    cardCollectionView = [[UICollectionView alloc] initWithFrame: CGRectZero
                                            collectionViewLayout: layout];

    cardCollectionView.delegate = self;
    cardCollectionView.dataSource = self;
    cardCollectionView.translatesAutoresizingMaskIntoConstraints = NO;
    [wrapView addSubview: cardCollectionView];

    if (@available(iOS 11.0, *))
    {
        [cardCollectionView.topAnchor constraintEqualToAnchor: wrapView.safeAreaLayoutGuide.topAnchor].active = YES;
        [cardCollectionView.leftAnchor constraintEqualToAnchor: wrapView.safeAreaLayoutGuide.leftAnchor].active = YES;
        [cardCollectionView.rightAnchor constraintEqualToAnchor: wrapView.safeAreaLayoutGuide.rightAnchor].active = YES;
        [cardCollectionView.bottomAnchor constraintEqualToAnchor: wrapView.safeAreaLayoutGuide.bottomAnchor].active = YES;
    }
    else
    {
        [cardCollectionView.topAnchor constraintEqualToAnchor: wrapView.topAnchor].active = YES;
        [cardCollectionView.leftAnchor constraintEqualToAnchor: wrapView.leftAnchor].active = YES;
        [cardCollectionView.rightAnchor constraintEqualToAnchor: wrapView.rightAnchor].active = YES;
        [cardCollectionView.bottomAnchor constraintEqualToAnchor: wrapView.bottomAnchor].active = YES;
    }

    cardCollectionView.backgroundColor = backgroundColor;

    // Do any additional setup after loading the view, typically from a nib.
    [cardCollectionView registerNib: [UINib nibWithNibName: @"CardCollectionViewCell"
                                                    bundle: nil]
         forCellWithReuseIdentifier: kCollectionViewReuseIdentifier];

    [cardCollectionView registerNib: [UINib nibWithNibName: @"ListCardCustomCell"
                                                    bundle: nil]
         forCellWithReuseIdentifier: kTableViewReuseIdentifier];

    searchBar = [[HSSearchBarWithSpinner alloc] initWithFrame: CGRectZero];
    searchBar.translatesAutoresizingMaskIntoConstraints = NO;
    searchBar.textColor = [UIColor whiteColor];
    searchBar.autocorrectionType   = UITextAutocorrectionTypeNo;
    searchBar.searchBarStyle       = UISearchBarStyleMinimal;
    searchBar.tintColor            = [UIColor darkGrayColor];   // Tint color is the entered text color + cancel button color
    searchBar.barTintColor         = backgroundColor;
    searchBar.placeholder          = @"Search";
    searchBar.delegate = self;

    // Add our searchbar
    [self.view addSubview: searchBar];

    searchYOffsetConstraint =
        [searchBar.topAnchor constraintEqualToAnchor: self.view.topAnchor
                                            constant: 0];
    searchYOffsetConstraint.active = YES;
    [searchBar.leftAnchor constraintEqualToAnchor: self.view.leftAnchor].active = YES;
    [searchBar.rightAnchor constraintEqualToAnchor: self.view.rightAnchor].active = YES;
    [searchBar.heightAnchor constraintEqualToConstant: 56.0f].active = YES;

    loading = NO;
    
    [self addObservers];
    [NSNotificationCenter.defaultCenter addObserver: self
                                           selector: @selector(onPricesUpdated)
                                               name: MTGPriceManager.pricesUpdatedNotificationName
                                             object: nil];
}

- (void) dealloc
{
    [NSNotificationCenter.defaultCenter removeObserver: self
                                                  name: MTGPriceManager.pricesUpdatedNotificationName
                                                object: nil];

    [self removeObservers];
} // End of dealloc

- (void) onPricesUpdated
{
    [self startLoadingResults];
} // End of onPricesUpdated

- (void) viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    self.navigationController.navigationBar.translucent = NO;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void) viewDidLoad
{
	// By default we need to reload when the index changes
	needsReload = YES;

    [super viewDidLoad];

	BOOL gridVisible = false;

    // Set our toggle
    NSUInteger index = ((NSNumber*)[[NSUserDefaults standardUserDefaults] objectForKey: @"toggleMode"]).intValue;

    [listStyleSegmentedControl setSelectedSegmentIndex: index];

    if ( 1 != listStyleSegmentedControl.selectedSegmentIndex )
    {
        gridVisible = true;
    }

    [self modeToggled: nil];

    // Setup our right bar button item
    settingsButton = [[UIBarButtonItem alloc] initWithImage: [UIImage imageNamed: @"Settings"]
                                                      style: UIBarButtonItemStylePlain
                                                     target: self
                                                     action: @selector(onSettings:)];

    self.navigationItem.rightBarButtonItems = @[settingsButton, segmentedBarButtonItem];
}

- (void) updateGrid
{
//    bool horizontal = [[NSUserDefaults standardUserDefaults] boolForKey: @"gridScrollsHorizontal"];
//    bool paged      = [[NSUserDefaults standardUserDefaults] boolForKey: @"gridScrollsPaged"];

    UICollectionViewFlowLayout * flowLayout = nil;
    if([self isGridViewVisible])
    {
        flowLayout = gridFlowLayout;
    }
    else
    {
        flowLayout = tableFlowLayout;
    }

#if todo
    if(paged)
    {
        flowLayout = [[HorizontalPagedCollectionViewFlowLayout alloc] init];
    }

    if(horizontal)
    {
        [flowLayout setScrollDirection: UICollectionViewScrollDirectionHorizontal];
    }
    else
    {
        [flowLayout setScrollDirection: UICollectionViewScrollDirectionVertical];
    }
#endif

    weakify(self);
    dispatch_async(dispatch_get_main_queue(), ^{
        strongify(self);

        [self->cardCollectionView setCollectionViewLayout: flowLayout];
//        cardCollectionView.pagingEnabled = paged;
        self->cardCollectionView.pagingEnabled = NO;
    });

    [cardCollectionView reloadData];
} // End of updateGrid

- (void) onSettings: (id) sender
{
	MTGCardSortOptionsViewController * cardSortViewController =
        [[MTGCardSortOptionsViewController alloc] initWithNibName:@"MTGCardSortOptionsViewController" bundle: nil];

    [cardSortViewController setDelegate: self];

    if ( [AppDelegate isIPad] )
    {
        MTGNavigationController * navigationController = [[MTGNavigationController alloc] initWithRootViewController: cardSortViewController];
        
        if ( nil != popoverController )
        {
            [popoverController dismissPopoverAnimated: YES];
            popoverController = nil;
        }
        
        // Create our popover controller
        popoverController = [[UIPopoverController alloc] initWithContentViewController: navigationController]; 
        
        // Show our popover and reload the data
        [popoverController presentPopoverFromBarButtonItem: sender 
                                  permittedArrowDirections: UIPopoverArrowDirectionAny 
                                                  animated: YES];
    }
    // Otherwise we are on the iPhone
    else
    {
		[self.navigationController pushViewController: cardSortViewController animated:YES];
    } // End of iPhone
} // End of onSettings

- (UIInterfaceOrientationMask) supportedInterfaceOrientations
{
    if([AppDelegate isIPad])
    {
        return UIInterfaceOrientationMaskAll;
    }

    return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown;
}

- (void) viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id <UIViewControllerTransitionCoordinator>)coordinator
{
    // Update our grid
    [self updateGrid];

	// Need to reload on a rotate
	needsReload = YES;
}

- (void) viewWillAppear: (BOOL) animated
{
    [super viewWillAppear: animated];

    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(receivedPricesUpdatedNotification:)
                                                 name: [AppDelegate PurchaseUpdatedNotification]
                                               object: nil];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear: animated];

    if(nil != popoverController)
    {
        [popoverController dismissPopoverAnimated: YES];
    }
} // End of viewWillDisappear

- (void) viewDidAppear: (BOOL) animated
{
	// If we have not yet loaded our cards
	if ( nil == cards )
	{
        [self startLoadingResults];
	} // End of no cards

    [super viewDidAppear: animated];
}

- (void) startLoadingResults
{
    [searchBar showSpinner];
    loading = YES;

    NSString * searchText = searchBar.text;

    weakify(self);
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        strongify(self);

        MTGSmartSearch * targetSmartSerach = self.smartSearch;

        if(searchText.length)
        {
            targetSmartSerach = [self.smartSearch copy];
            targetSmartSerach.andCustomClause =
                [[NSString alloc] initWithFormat: @"card.name LIKE '%%%@%%' OR card.type LIKE '%%%@%%' OR cardSet.name LIKE '%%%@%%' ", [MTGSmartSearch escapeString: searchText], [MTGSmartSearch escapeString: searchText],
                 [MTGSmartSearch escapeString: searchText]];
        }

        MachTimer * searchTimer = [MachTimer startTimer];
        [MTGSmartSearch countWithSmartSearch: targetSmartSerach];

        NSArray * tempCards =
            [MTGSmartSearch searchWithSmartSearch: targetSmartSerach
                                         limit: NSMakeRange(0, 5000)];

        NSLog(@"Search took %0.2f seconds", searchTimer.elapsedSeconds);

        dispatch_async(dispatch_get_main_queue(), ^{
            strongify(self);

            self->cards = tempCards;
            [self endLoadingSequence];
            self->loading = NO;
        });
    });
} // End of startLoadingResults

#pragma mark -
#pragma mark Notifications

-(void) receivedPricesUpdatedNotification: (id) notification
{
    NSLog(@"Prices have been updated. Going to reload results.");
    [self startLoadingResults];
}

#pragma mark -
#pragma mark Managing the detail item

- (void) endLoadingSequence
{
	NSLog ( @"endLoadingSequence called" );

    [cardCollectionView reloadData];
    cardCollectionView.scrollEnabled = YES;

    [searchBar hideSpinner];
} // End of endLoadingSequence

#pragma mark -
#pragma mark UICollectionView

- (UIEdgeInsets) collectionView: (UICollectionView *) collectionView
                         layout: (UICollectionViewLayout*) collectionViewLayout
         insetForSectionAtIndex: (NSInteger) section
{
    UICollectionViewFlowLayout * flowLayout = (id) collectionViewLayout;
    UIEdgeInsets layoutInsets = flowLayout.sectionInset;

    return UIEdgeInsetsMake(searchBar.frame.size.height, layoutInsets.left, layoutInsets.bottom, layoutInsets.right);
}

- (NSInteger) collectionView: (UICollectionView *) collectionView
      numberOfItemsInSection: (NSInteger) section
{
    return cards.count;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView: (UICollectionView *) collectionView
                  cellForItemAtIndexPath: (NSIndexPath *) indexPath
{
    MTGCard* card = [cards objectAtIndex: indexPath.row];

    if([currentCellIdentifier isEqualToString: kTableViewReuseIdentifier])
    {
        UICollectionViewCell * cell = [self cellForRowAtIndexPath: indexPath];
        return cell;
    }

    CardCollectionViewCell * collectionViewCell = nil;

    collectionViewCell = [collectionView dequeueReusableCellWithReuseIdentifier: kCollectionViewReuseIdentifier
                                                                   forIndexPath: indexPath];

    [collectionViewCell startAnimating];

    collectionViewCell.cardImageView.backgroundColor = [UIColor blackColor];

    __weak CardCollectionViewCell  * weakCollectionViewCell = collectionViewCell;
    collectionViewCell.cardNameLabel.text = card.name;

    static UIImage * backOfCardImage      = nil;
    
    static dispatch_once_t onceToken      = 0;
    dispatch_once(&onceToken, ^{
        backOfCardImage = [UIImage imageNamed: @"BackOfMagicCard"];
    });

    [MTGCardImageHelper loadImage: card.multiverseId
                  targetImageView: collectionViewCell.cardImageView
                 placeholderImage: backOfCardImage
                     didLoadBlock:^(UIImage *image, BOOL wasCached) {
                         // Sometimes if we are scrolling quickly, we may queue up a few image loads. This
                         // check makes sure that the image being loaded is for the proper card.
                         if(![collectionViewCell.cardNameLabel.text isEqualToString: card.name])
                         {
                             return;
                         } // End of card has already changed

                         [weakCollectionViewCell stopAnimating: NO];

                         if(!wasCached)
                         {
                             [UIView transitionWithView: weakCollectionViewCell.cardImageView
                                               duration: 1.0f
                                                options: UIViewAnimationOptionTransitionFlipFromLeft
                                             animations:^{[weakCollectionViewCell.cardImageView setImage:image];}
                                             completion: NULL];
                         }
                         else
                         {
                             [weakCollectionViewCell.cardImageView setImage:image];
                         }
                     } didFailBlock:^{
                         [weakCollectionViewCell stopAnimating: NO];
                         [UIView transitionWithView: weakCollectionViewCell.cardImageView
                                           duration: 1.0f
                                            options: UIViewAnimationOptionTransitionFlipFromLeft
                                         animations: ^{
                                             [weakCollectionViewCell.cardImageView setImage: [UIImage imageNamed: @"NoImageCard"]];
                                         }
                                         completion: NULL];
                     }];

    // No need for opaque
    collectionViewCell.contentView.backgroundColor = collectionView.backgroundColor;

    return collectionViewCell;
}

// Customize the appearance of table view cells.
- (ListCardCustomCell *) cellForRowAtIndexPath: (NSIndexPath *) indexPath
{
    ListCardCustomCell *cell = (id)[cardCollectionView dequeueReusableCellWithReuseIdentifier: kTableViewReuseIdentifier
                                                                                 forIndexPath: indexPath];

    MTGCard* card = [cards objectAtIndex: indexPath.row];
    
    [cell populateWithCard: card
                 indexPath: indexPath];

    return cell;
} // End of cellForRowAtIndexPath:

- (void)  collectionView: (UICollectionView *)collectionView
didSelectItemAtIndexPath: (NSIndexPath *)indexPath
{
    MTGCard * selectedCard = (MTGCard*)[cards objectAtIndex: indexPath.row];

    [self displayCard: selectedCard];
} // End of collectionView:didSelectItemAtIndexPath:

#pragma mark -
#pragma mark Misc

- (void) displayCard: (MTGCard*) selectedCard
{
    CardDetailsViewController * cardViewController = [[CardDetailsViewController alloc] init];
    cardViewController.card = selectedCard;

    MTGNavigationController * navController =
        [[MTGNavigationController alloc] initWithRootViewController: cardViewController];

    navController.modalPresentationStyle = UIModalPresentationFormSheet;
    navController.modalTransitionStyle   = UIModalTransitionStyleCoverVertical;

    if([AppDelegate isIPad])
    {
        navController.preferredContentSize = CGSizeMake(540, 620);
    }
    else
    {
        navController.preferredContentSize = CGSizeMake(320, 620);
    }

    [self presentViewController: navController
                       animated: YES
                     completion: nil];
} // End of displayCard:

- (void) modeToggled: (id) sender
{
	// Update our user defaults
    NSNumber * toggleMode = [NSNumber numberWithInteger: listStyleSegmentedControl.selectedSegmentIndex];

	[[NSUserDefaults standardUserDefaults] setObject: toggleMode
                                              forKey:@"toggleMode"];

	NSLog( @"Mode toggled" );
    UICollectionViewLayout * layout = nil;
	if ( [self isGridViewVisible] )
	{
        currentCellIdentifier = kCollectionViewReuseIdentifier;
        layout = gridFlowLayout;
    }
    else
    {
        currentCellIdentifier = kTableViewReuseIdentifier;
        layout = tableFlowLayout;
    }

    // NOTE: UICollectionView has a built in visible items, but its NOT ALWAYS CORRECT.
    // Instead, we will manually figure out our first visible item (and we need to take the
    // searchbar into account for generating our location).
    CGPoint visiblePoint = cardCollectionView.contentOffset;
    visiblePoint.y += searchBar.frame.size.height;
    NSIndexPath * firstVisibleIndexPath = [cardCollectionView indexPathForItemAtPoint: visiblePoint];

    CGFloat searchBarOffset = fabs(searchYOffsetConstraint.constant);

    BOOL animated = NO;

    if(animated)
    {
        NSArray * visibleItems =
            [cardCollectionView indexPathsForVisibleItems];
        
        [cardCollectionView reloadItemsAtIndexPaths: visibleItems];
    }
    else
    {
        [cardCollectionView reloadData];
    }

    weakify(self);
    void (^animationAction)(void) = ^void() {
        strongify(self);

        [self->cardCollectionView.collectionViewLayout invalidateLayout];
        [self->cardCollectionView setCollectionViewLayout: layout
                                                 animated: animated];

        // If the search bar was partially visible, then we will scroll to the same positon.
        // This makes it look to the user like just the grid/table style swapped.
        if(searchBarOffset < self->searchBar.frame.size.height)
        {
            [self->cardCollectionView setContentOffset: CGPointMake(0, searchBarOffset)];
        }
        // If the scroll view was NOT visible and we have an index path available, then we will
        // scroll that to our top.
        else if(firstVisibleIndexPath)
        {
            [self->cardCollectionView scrollToItemAtIndexPath: firstVisibleIndexPath
                                             atScrollPosition: UICollectionViewScrollPositionTop
                                                     animated: animated];
        }
    };

    if(animated)
    {
        [self performAnimation: animationAction];
    }
    else
    {
        animationAction();
    }
}

- (void) performAnimation: (void (^)(void)) animateBlock
{
    [UIView animateWithDuration: 0.5
                          delay: 0
                        options: UIViewAnimationOptionTransitionNone
                     animations: ^{
                         animateBlock();
                     }
                     completion: ^(BOOL finished) {
                         
                     }];
} // End of performAnimation

#pragma mark -
#pragma mark Misc

- (BOOL) isGridViewVisible
{
	// True if our segmented index is selected
	return 1 == [listStyleSegmentedControl selectedSegmentIndex];
}

- (void) sortingChanged
{
    [self startLoadingResults];
} // Load up our results

- (void) scrollingChanged
{
    [self updateGrid];
} // Load up our results

#pragma mark -
#pragma mark UISearchBarDelegate

- (BOOL)      searchBar: (UISearchBar *)searchBar
shouldChangeTextInRange: (NSRange)range
        replacementText: (NSString *)text
{
    isRemovingTextWithBackspace = ([searchBar.text stringByReplacingCharactersInRange:range withString:text].length == 0);

    return YES;
} // End of searchBar:shouldChangeTextInRange:replacementText:

- (void) searchBar: (UISearchBar *) searchBar
     textDidChange: (NSString *) searchText
{
    if ([searchText length] == 0 && !isRemovingTextWithBackspace)
    {
        [self startLoadingResults];
    }
} // End fo searchBar:textDidChange:

- (void) searchBarTextDidBeginEditing: (UISearchBar *) aSearchBar
{
    [aSearchBar setShowsCancelButton: YES
                            animated: YES];
} // End of searchBarTextDidBeginEditing:

- (void) searchBarCancelButtonClicked: (UISearchBar *)aSearchBar
{
    [aSearchBar setShowsCancelButton: NO
                            animated: YES];

    [aSearchBar setText: @""];
    [self searchBarSearchButtonClicked: aSearchBar];
    [aSearchBar resignFirstResponder];
} // End of searchBarCancelButtonClicked:

- (void) searchBarSearchButtonClicked: (UISearchBar *) aSearchBar
{
    [self startLoadingResults];
    [aSearchBar resignFirstResponder];
} // End of searchBarSearchButtonClicked:

#pragma mark - observer

- (void) addObservers
{
    [cardCollectionView addObserver: self
                         forKeyPath: @"contentOffset"
                            options: NSKeyValueObservingOptionNew// | NSKeyValueObservingOptionOld
                            context: nil];
}

- (void) removeObservers
{
    [[NSNotificationCenter defaultCenter] removeObserver: self];

    [cardCollectionView removeObserver: self
                            forKeyPath: @"contentOffset"
                               context: nil];
}

- (void)observeValueForKeyPath: (NSString *)keyPath
                      ofObject: (UICollectionView *)object
                        change: (NSDictionary *)change
                       context: (void *)context
{
    if([keyPath isEqualToString: @"contentOffset"] && object == cardCollectionView)
    {
        searchYOffsetConstraint.constant = -1 * object.contentOffset.y;
    }
}

@end
