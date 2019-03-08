//
//  MTGLifeCounterFlowLayout.h
//  MTG Deck Builder
//
//  Created by kylehankinson on 2018-08-14.
//  Copyright © 2018 Hankinsoft Development, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MTGLifeCounterFlowLayout : UICollectionViewFlowLayout

- (void) setShowsPoison: (BOOL) showsPoison
       commanderEnabled: (BOOL) commanderEnabled;

@end
