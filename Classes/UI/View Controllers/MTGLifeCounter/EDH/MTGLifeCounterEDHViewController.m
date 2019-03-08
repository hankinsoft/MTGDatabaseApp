//
//  MTGLifeCounterEDHViewController.m
//  MTG Deck Builder
//
//  Created by kylehankinson on 2018-08-16.
//  Copyright © 2018 Hankinsoft Development, Inc. All rights reserved.
//

#import "MTGLifeCounterEDHViewController.h"
#import "MTGPlayer.h"
#import "MTGLifeCounter.h"
#import "MTGLifeButton.h"
#import "MTGLifeCounterEDHCollectionViewCell.h"

#define kMTGLifeCounterEDHCollectionViewCellIdentifier         @"MTGLifeCounterEDHCollectionViewCell"

@interface MTGLifeCounterEDHViewController ()<UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, MTGLifeCounterEDHCollectionViewCellDelegate>
{
    UICollectionView * commandersCollectionView;
}
@end

@implementation MTGLifeCounterEDHViewController
{
    NSArray<MTGPlayer*>* players;
    MTGPlayer * currentPlayer;
}

- (void) loadView
{
    [super loadView];
    
    commandersCollectionView = [[UICollectionView alloc] initWithFrame: CGRectZero
                                                  collectionViewLayout: [[UICollectionViewFlowLayout alloc] init]];
    commandersCollectionView.backgroundColor = [SQLProAppearanceManager.sharedInstance darkTableViewCellBackgroundColor];
    commandersCollectionView.dataSource = self;
    commandersCollectionView.delegate = self;
    
    [self.view addSubview: commandersCollectionView];

    commandersCollectionView.translatesAutoresizingMaskIntoConstraints = NO;
    [commandersCollectionView.leftAnchor constraintEqualToAnchor: self.view.leftAnchor].active = YES;
    [commandersCollectionView.rightAnchor constraintEqualToAnchor: self.view.rightAnchor].active = YES;
    [commandersCollectionView.bottomAnchor constraintEqualToAnchor: self.view.bottomAnchor].active = YES;
    [commandersCollectionView.topAnchor constraintEqualToAnchor: self.view.topAnchor].active = YES;

    // Do any additional setup after loading the view, typically from a nib.
    [commandersCollectionView registerNib: [UINib nibWithNibName: kMTGLifeCounterEDHCollectionViewCellIdentifier
                                                       bundle: nil]
               forCellWithReuseIdentifier: kMTGLifeCounterEDHCollectionViewCellIdentifier];

    UIBarButtonItem * doneButton =
        [[UIBarButtonItem alloc] initWithTitle: NSLocalizedString(@"Done", nil)
                                         style: UIBarButtonItemStylePlain
                                        target: self
                                        action: @selector(onDone:)];

    self.navigationItem.rightBarButtonItem = doneButton;
} // End of loadView

- (IBAction) onDone: (id) sender
{
    [self.presentingViewController dismissViewControllerAnimated: YES
                                                      completion: NULL];
} // End of onCancel

- (void) setPlayers: (NSArray<MTGPlayer*>*) _players
      currentPlayer: (MTGPlayer*) _player
{
    currentPlayer = _player;
    players = _players;
} // End of setPlayers

#pragma mark -
#pragma mark UITableView

- (CGSize) collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(collectionView.frame.size.width, 46);
}

- (NSInteger) collectionView: (UICollectionView *) collectionView
      numberOfItemsInSection: (NSInteger) section
{
    return MTGLifeCounter.sharedInstance.numberOfPlayers;
} // End of collectionView:numberOfItemsInSection

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                           cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    MTGLifeCounterEDHCollectionViewCell * collectionViewCell = nil;

    collectionViewCell = [collectionView dequeueReusableCellWithReuseIdentifier: kMTGLifeCounterEDHCollectionViewCellIdentifier
                                                                   forIndexPath: indexPath];
    collectionViewCell.delegate = self;


    MTGPlayer * player = players[indexPath.row];
    
    NSInteger commanderDamage = [currentPlayer commanderDamageForPlayerIndex: indexPath.row];

    if(currentPlayer == player)
    {
        [collectionViewCell setDamage: commanderDamage
                                title: @"Deaths"
                            indexPath: indexPath];
    }
    else
    {
        [collectionViewCell setDamage: commanderDamage
                                title: player.name
                            indexPath: indexPath];
    }

#if oldcode
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell =
            [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleSubtitle
                                   reuseIdentifier: CellIdentifier];

        // No selection
        cell.selectionStyle = UITableViewCellSelectionStyleNone;

        MTGLifeButton * addOneComanderDamageButton = [MTGLifeButton buttonWithType: UIButtonTypeCustom];
        [addOneComanderDamageButton setTitle: @"+1" forState: UIControlStateNormal];
        addOneComanderDamageButton.translatesAutoresizingMaskIntoConstraints = false;
        [cell.contentView addSubview: addOneComanderDamageButton];
        [addOneComanderDamageButton.widthAnchor constraintEqualToConstant: 46.0f].active = YES;
        [addOneComanderDamageButton.heightAnchor constraintEqualToConstant: 46.0f].active = YES;
        [addOneComanderDamageButton.centerYAnchor constraintEqualToAnchor: cell.contentView.centerYAnchor].active = YES;
        [addOneComanderDamageButton.rightAnchor constraintEqualToAnchor: cell.contentView.rightAnchor
                                                               constant: -10].active = YES;

        [addOneComanderDamageButton addTarget: self
                                       action: @selector(onAddOneCommanderDamage:)
                             forControlEvents: UIControlEventTouchDown];

        MTGLifeButton * minusOneComanderDamageButton = [MTGLifeButton buttonWithType: UIButtonTypeCustom];
        [minusOneComanderDamageButton setTitle: @"-1" forState: UIControlStateNormal];
        minusOneComanderDamageButton.translatesAutoresizingMaskIntoConstraints = false;
        [cell.contentView addSubview: minusOneComanderDamageButton];
        [minusOneComanderDamageButton.widthAnchor constraintEqualToConstant: 46.0f].active = YES;
        [minusOneComanderDamageButton.heightAnchor constraintEqualToConstant: 46.0f].active = YES;
        [minusOneComanderDamageButton.centerYAnchor constraintEqualToAnchor: cell.contentView.centerYAnchor].active = YES;
        [minusOneComanderDamageButton.rightAnchor constraintEqualToAnchor: addOneComanderDamageButton.leftAnchor
                                                                 constant: -5].active = YES;

        [minusOneComanderDamageButton addTarget: self
                                         action: @selector(onMinusOneCommanderDamage:)
                               forControlEvents: UIControlEventTouchDown];
    } // End of we did not have a cell



    cell.detailTextLabel.textColor = [[UIColor whiteColor] colorWithAlphaComponent: 0.60];
#endif

    return collectionViewCell;
} // End of tableView:cellForRowAtIndexPath:

- (NSInteger) commanderIndexFromIndexPath: (NSIndexPath*) indexPath
{
    NSInteger commanderIndex = indexPath.row;

    return commanderIndex;
} // End of commanderIndexFromSender

#pragma mark - MTGLifeCounterEDHCollectionViewCellDelegate

- (void) addCommaderDamageForIndexPath: (NSIndexPath*) indexPath
{
    NSInteger commanderIndex = [self commanderIndexFromIndexPath: indexPath];
    NSInteger commanderDamage = [currentPlayer commanderDamageForPlayerIndex: commanderIndex];

    // If another commander caused damage/life (add life is incase a user fucks up life totals),
    // then we need to adjust the players life total.
    MTGPlayer * targetPlayer = players[commanderIndex];
    if(targetPlayer != currentPlayer)
    {
        currentPlayer.life -= 1;
        [self.delegate edhViewControllerRequiresPlayerUpdate];
    }

    [currentPlayer setCommanderDamage: commanderDamage + 1
                       forPlayerIndex: commanderIndex];
    
    [MTGLifeCounter.sharedInstance save];
    [commandersCollectionView reloadData];
} // End of addCommaderDamageForIndexPath:

- (void) removeCommaderDamageForIndexPath: (NSIndexPath*) indexPath
{
    NSInteger commanderIndex = [self commanderIndexFromIndexPath: indexPath];
    NSInteger commanderDamage = [currentPlayer commanderDamageForPlayerIndex: commanderIndex];

    // If another commander caused damage/life (add life is incase a user fucks up life totals),
    // then we need to adjust the players life total.
    MTGPlayer * targetPlayer = players[commanderIndex];
    if(targetPlayer != currentPlayer)
    {
        currentPlayer.life += 1;
        [self.delegate edhViewControllerRequiresPlayerUpdate];
    }

    [currentPlayer setCommanderDamage: commanderDamage - 1
                       forPlayerIndex: commanderIndex];
    
    [MTGLifeCounter.sharedInstance save];
    [commandersCollectionView reloadData];
} // End of removeCommaderDamageForIndexPath:

@end
