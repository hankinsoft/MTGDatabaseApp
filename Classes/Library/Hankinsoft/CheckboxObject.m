//
//  NSKeyValuePair.m
//  MTG Deck Builder
//
//  Created by Kyle Hankinson on 11-06-19.
//  Copyright 2011 Hankinsoft. All rights reserved.
//

#import "CheckboxObject.h"

@implementation CheckboxObject

@synthesize display, value, checked;

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }

    return self;
} // End of init

- (id) initWithDisplay: (NSString*) _display value: (NSObject*) _value checked: (BOOL) _checked
{
    self = [super init];
    if ( self )
    {
        self.display = _display;
        self.value = _value;
        self.checked = _checked;
    } // End of self initialized
    
    return self;
} // End of initWithDisplay

@end
