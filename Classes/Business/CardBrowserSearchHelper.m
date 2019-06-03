//
//  CardBrowserSearchHelper.m
//  MTG Deck Builder
//
//  Created by Kyle Hankinson on 2014-09-22.
//  Copyright (c) 2014 Hankinsoft Development, Inc. All rights reserved.
//

#import "CardBrowserSearchHelper.h"
#import "MTGSmartSearch.h"

@implementation CardBrowserSearchHelper
{
    bool cancelled;
}
@synthesize delegate;

- (void) cancel
{
    cancelled = true;
} // End of cancel

- (void) beginSearchWithSmartSearch: (MTGSmartSearch*) smartSearch
{
    weakify(self);
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        strongify(self);

        NSUInteger count = [MTGSmartSearch countWithSmartSearch: smartSearch];
        NSArray * cards  = [MTGSmartSearch searchWithSmartSearch: smartSearch
                                                           limit: NSMakeRange(0, 5000)];

        if(!self->cancelled && nil != self.delegate)
        {
            [self.delegate finishedSearchingWithCards: cards
                                         hasMoreCards: count != cards.count];
        }
    });
} // End of beginSearchWithSmartSearch

@end
