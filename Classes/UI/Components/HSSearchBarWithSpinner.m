//
//  HSSearchBarWithSpinner.m
//  MTG Deck Builder
//
//  Created by Kyle Hankinson on 2014-09-22.
//  Copyright (c) 2014 Hankinsoft Development, Inc. All rights reserved.
//

#import "HSSearchBarWithSpinner.h"

@implementation HSSearchBarWithSpinner
{
    UIActivityIndicatorView *_spinnerView;
    UIView                  *_searchIconView;
    UITextField             *_internalTextField;
}

@synthesize textColor;

- (id) initWithFrame: (CGRect) frame
{
    self = [super initWithFrame:frame];
    if(self)
    {
        NSNotificationCenter * nc = NSNotificationCenter.defaultCenter;
        [nc addObserver: self
               selector: @selector(textFieldDidBeginEditingNotification:)
                   name: UITextFieldTextDidBeginEditingNotification
                 object: nil];
    }

    return self;
}

- (void) dealloc
{
    NSNotificationCenter * nc = NSNotificationCenter.defaultCenter;
    [nc removeObserver: self];
} // End of dealloc

- (void) showSpinner
{
    if(_internalTextField)
    {
        if(_spinnerView == nil)
        {
            _spinnerView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        }

        [_internalTextField setLeftView:_spinnerView];
        [_spinnerView startAnimating];
    }
}

- (void) hideSpinner
{
    [_spinnerView stopAnimating];
    [_internalTextField setLeftView:_searchIconView];
}

#pragma mark - Private

- (void) textFieldDidBeginEditingNotification: (NSNotification *) notification
{
    if(_internalTextField == nil)
    {
        UITextField *editedTextField    = notification.object;
        UIView      *superView          = editedTextField.superview;
        
        while(superView && superView != self)
        {
            superView = superView.superview;
        }
        
        if(superView == self)
        {
            _internalTextField  = editedTextField;
            if (@available(iOS 11.0, *))
            {
                _internalTextField.smartQuotesType = UITextSmartQuotesTypeNo;
            }

            if(nil != textColor)
            {
                _internalTextField.textColor = textColor;
            }

            _searchIconView     = _internalTextField.leftView;
        }
    }
}

@end
