//
//  MTGLifeCounterEDHViewController.h
//  MTG Deck Builder
//
//  Created by kylehankinson on 2018-08-16.
//  Copyright © 2018 Hankinsoft Development, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MTGLifeCounterEDHPresentationController.h"

@class MTGPlayer;

@protocol MTGLifeCounterEDHViewControllerDelegate <NSObject>

- (void) edhViewControllerRequiresPlayerUpdate;

@end

@interface MTGLifeCounterEDHViewController : UIViewController

- (void) setPlayers: (NSArray<MTGPlayer*>*) players
      currentPlayer: (MTGPlayer*) player;

@property(nonatomic,weak) id<MTGLifeCounterEDHViewControllerDelegate> delegate;

@end
