//
//  SearchBarWithSpinner.m
//  MTG Deck Builder
//
//  Created by Kyle Hankinson on 2013-05-09.
//
//

#import "SearchBarWithSpinner.h"

@implementation SearchBarWithSpinner

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(textFieldDidBeginEditingNotification:)
                                                     name:UITextFieldTextDidBeginEditingNotification
                                                   object:nil];
    }
    
    return self;
}

- (void)showSpinner
{
    NSLog(@"Showing spinner");
    if(_internalTextField)
    {
        if(_spinnerView == nil)
            _spinnerView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        
        [_internalTextField setLeftView:_spinnerView];
        [_spinnerView startAnimating];
    }
}

- (void)hideSpinner
{
    NSLog(@"Hiding spinner");
    [_spinnerView stopAnimating];
    [_internalTextField setLeftView:_searchIconView];
}

#pragma mark - Private

- (void)textFieldDidBeginEditingNotification:(NSNotification *)notification
{
    if(_internalTextField == nil)
    {
        UITextField *editedTextField    = notification.object;
        UIView      *superView          = editedTextField.superview;
        
        while(superView && superView != self)
            superView = superView.superview;
        
        if(superView == self)
        {
            _internalTextField  = editedTextField;
            _searchIconView     = _internalTextField.leftView;
        }
    }
}

@end