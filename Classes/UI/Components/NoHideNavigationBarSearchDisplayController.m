//
//  NoHideNavigationBarSearchDisplayController.m
//  MTG Deck Builder
//
//  Created by Kyle Hankinson on 2014-09-22.
//  Copyright (c) 2014 Hankinsoft Development, Inc. All rights reserved.
//

#import "NoHideNavigationBarSearchDisplayController.h"

@implementation NoHideNavigationBarSearchDisplayController

- (void)setActive:(BOOL)visible animated:(BOOL)animated
{
    [super setActive: visible animated: animated];
    
    [self.searchContentsController.navigationController setNavigationBarHidden: NO animated: NO];
}

@end
