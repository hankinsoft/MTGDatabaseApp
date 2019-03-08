//
//  HSSearchBarWithSpinner.h
//  MTG Deck Builder
//
//  Created by Kyle Hankinson on 2014-09-22.
//  Copyright (c) 2014 Hankinsoft Development, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HSSearchBarWithSpinner : UISearchBar

- (void) showSpinner;
- (void) hideSpinner;

@property(nonatomic,retain) UIColor * textColor;

@end
