//
//  SearchBarWithSpinner.h
//  MTG Deck Builder
//
//  Created by Kyle Hankinson on 2013-05-09.
//
//

#import <Foundation/Foundation.h>

@interface SearchBarWithSpinner : UISearchBar
{
    UIActivityIndicatorView *_spinnerView;
    UIView                  *_searchIconView;
    UITextField             *_internalTextField;
}

- (void)showSpinner;
- (void)hideSpinner;

@end
