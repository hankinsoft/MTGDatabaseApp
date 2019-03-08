//
//  MTGLifeCounterViewController.m
//  MTG Deck Builder
//
//  Created by kylehankinson on 2018-08-14.
//  Copyright © 2018 Hankinsoft Development, Inc. All rights reserved.
//

#import "MTGLifeCounterViewController.h"
#import "MTGPlayer.h"
#import "MTGPlayerCollectionViewCell.h"
#import "MTGLifeCounterFlowLayout.h"
#import "MTGLifeCounterSettingsViewController.h"
#import "MTGLifeCounter.h"
#import "MTGLifeCounterEDHViewController.h"
#import "MTGLifeCounterEDHNavigationController.h"
#import "MTGLifeCounterGlobalCollectionViewCell.h"

#define kCollectionViewGlobalReuseIdentifier   @"MTGLifeCounterGlobalCollectionViewCell"
#define kCollectionViewReuseIdentifier         @"kMTGPlayerViewCell"

@interface MTGLifeCounterViewController ()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, MTGLifeCounterSettingsViewControllerDelegate, MTGPlayerCollectionViewCellDelegate, MTGLifeCounterGlobalCollectionViewCell, MTGLifeCounterEDHViewControllerDelegate>
{
    UICollectionView        * playersCollectionView;
    UIBarButtonItem         * settingsButton;
    UIPopoverController     * popoverController;

    MTGLifeCounterEDHViewController * edhViewController;
    MTGLifeCounterEDHNavigationController * edhNavController;
}
@end

@implementation MTGLifeCounterViewController
{
    RevealBlock           _revealBlock;
    MTGLifeCounterFlowLayout * flowLayout;
}

- (id) initWithRevealBlock: (RevealBlock) revealBlock
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
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [[HSLogHelper sharedInstance] logEvent: @"LifeCounterOpened"
                                   withDetails: nil];
    });

    self.title = @"Life counter";

    flowLayout = [[MTGLifeCounterFlowLayout alloc] init];
    [flowLayout setShowsPoison: MTGLifeCounter.sharedInstance.poisonEnabled
              commanderEnabled: MTGLifeCounter.sharedInstance.commanderEnabled];

    playersCollectionView = [[UICollectionView alloc] initWithFrame: CGRectZero
                                               collectionViewLayout: flowLayout];
    playersCollectionView.backgroundColor = SQLProAppearanceManager.sharedInstance.darkTableBackgroundColor;
    playersCollectionView.delegate = self;
    playersCollectionView.dataSource = self;

    playersCollectionView.translatesAutoresizingMaskIntoConstraints = false;
    [self.view addSubview: playersCollectionView];

    [playersCollectionView.topAnchor constraintEqualToAnchor: self.view.topAnchor].active = true;
    [playersCollectionView.leftAnchor constraintEqualToAnchor: self.view.leftAnchor].active = true;
    [playersCollectionView.rightAnchor constraintEqualToAnchor: self.view.rightAnchor].active = true;
    [playersCollectionView.bottomAnchor constraintEqualToAnchor: self.view.bottomAnchor].active = true;

    [playersCollectionView registerNib: [UINib nibWithNibName: @"MTGPlayerCollectionViewCell"
                                                    bundle: nil]
            forCellWithReuseIdentifier: kCollectionViewReuseIdentifier];

    [playersCollectionView registerNib: [UINib nibWithNibName: @"MTGLifeCounterGlobalCollectionViewCell"
                                                       bundle: nil]
            forCellWithReuseIdentifier: kCollectionViewGlobalReuseIdentifier];

    // Setup our right bar button item
    settingsButton =
        [[UIBarButtonItem alloc] initWithImage: [UIImage imageNamed: @"Settings"]
                                         style: UIBarButtonItemStylePlain
                                        target: self
                                        action: @selector(onSettings:)];

    self.navigationItem.rightBarButtonItems = @[settingsButton];
}

- (void) viewDidAppear: (BOOL) animated
{
    [super viewDidAppear: animated];
    [playersCollectionView reloadData];

    BOOL disableIdleTimer = [[NSUserDefaults standardUserDefaults] boolForKey: kMTGLockScreenIdleTimerDisabled];
    if(disableIdleTimer)
    {
        [UIApplication sharedApplication].idleTimerDisabled = YES;
    }
}

- (void) viewDidDisappear: (BOOL) animated
{
    [super viewDidDisappear: animated];

    if([UIApplication sharedApplication].idleTimerDisabled)
    {
        [UIApplication sharedApplication].idleTimerDisabled = NO;
    }
} // End of viewDidDissapear:

- (IBAction) onSettings: (id) sender
{
    MTGLifeCounterSettingsViewController * lifeCounterSettingsViewController = [[MTGLifeCounterSettingsViewController alloc] init];
    lifeCounterSettingsViewController.delegate = self;

    if ( [AppDelegate isIPad] )
    {
        MTGNavigationController * navigationController = [[MTGNavigationController alloc] initWithRootViewController: lifeCounterSettingsViewController];

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
        [self.navigationController pushViewController: lifeCounterSettingsViewController
                                             animated:YES];
    } // End of iPhone
} // End of onSettings:

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark -
#pragma mark UICollectionView

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout*)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    MTGLifeCounterFlowLayout * flowLayout = (MTGLifeCounterFlowLayout*) collectionViewLayout;
    CGSize size = flowLayout.itemSize;

    if(0 == indexPath.row)
    {
        return CGSizeMake(size.width, 42);
    }

    return size;
}

- (NSInteger)collectionView: (UICollectionView *) collectionView
     numberOfItemsInSection: (NSInteger) section
{
    // Add one extra for the global cell
    NSInteger numberOfItemsInSection = MTGLifeCounter.sharedInstance.numberOfPlayers + 1;

    return numberOfItemsInSection;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                           cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if(0 == indexPath.row)
    {
        MTGLifeCounterGlobalCollectionViewCell * collectionViewCell = nil;

        collectionViewCell = [collectionView dequeueReusableCellWithReuseIdentifier: kCollectionViewGlobalReuseIdentifier
                                                                       forIndexPath: indexPath];

        collectionViewCell.delegate = self;

        return collectionViewCell;
    }

    MTGPlayer * player = MTGLifeCounter.sharedInstance.players[indexPath.row - 1];

    MTGPlayerCollectionViewCell * collectionViewCell = nil;

    collectionViewCell = [collectionView dequeueReusableCellWithReuseIdentifier: kCollectionViewReuseIdentifier
                                                                   forIndexPath: indexPath];

    [collectionViewCell willDisplayWithPoison: MTGLifeCounter.sharedInstance.poisonEnabled
                                   edhEnabled: MTGLifeCounter.sharedInstance.commanderEnabled];

    // Set our player
    [collectionViewCell setPlayer: player];
    collectionViewCell.delegate = self;

    return collectionViewCell;
}

#pragma mark - MTGLifeCounterSettingsViewControllerDelegate

- (void) lifeCounterSettingsDidChange: (MTGLifeCounterSettingsViewController*) settingsViewController
{
    // Set our poison setting
    [flowLayout setShowsPoison: MTGLifeCounter.sharedInstance.poisonEnabled
              commanderEnabled: MTGLifeCounter.sharedInstance.commanderEnabled];

    // Reload
    [playersCollectionView reloadData];
} // End of lifeCounterSettingsDidChange:

#pragma mark - MTGPlayerCollectionViewCellDelegate

- (void) playerCollectionViewCell: (MTGPlayerCollectionViewCell*) cell
                wantsEDHForPlayer: (MTGPlayer*) player
{
    edhViewController = [[MTGLifeCounterEDHViewController alloc] init];
    edhNavController = [[MTGLifeCounterEDHNavigationController alloc] initWithRootViewController: edhViewController];
    
    edhViewController.delegate = self;
    edhViewController.title = [NSString stringWithFormat: @"%@", player.name];
    [edhViewController setPlayers: MTGLifeCounter.sharedInstance.players
                    currentPlayer: player];
    
    [edhNavController setModalInPopover: YES];
    [edhNavController setModalPresentationStyle: UIModalPresentationCustom];
    
    [self.view.window.rootViewController presentViewController: edhNavController
                                                      animated: YES
                                                    completion: ^{
                                                           }];
}

#pragma - MTGLifeCounterGlobalCollectionViewCell

- (void) mtgLifeCounterGlobalDamage: (NSInteger) damage
{
    for(NSUInteger index = 0; index < MTGLifeCounter.sharedInstance.numberOfPlayers; ++index)
    {
        MTGPlayer * player = MTGLifeCounter.sharedInstance.players[index];
        player.life -= damage;
    } // End of players in game damage

    // Reload
    [playersCollectionView reloadData];
} // End of mtgLifeCounterGlobalDamage:

#pragma mark - MTGLifeCounterEDHViewControllerDelegate

- (void) edhViewControllerRequiresPlayerUpdate
{
    // Reload
    [playersCollectionView reloadData];
} // End of edhViewControllerRequiresPlayerUpdate

@end
