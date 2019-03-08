//
//  NSKeyValuePair.h
//  MTG Deck Builder
//
//  Created by Kyle Hankinson on 11-06-19.
//  Copyright 2011 Hankinsoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CheckboxObject : NSObject
{
    NSString    * display;
    NSObject    * value;
    BOOL        checked;
}

- (id) initWithDisplay: (NSString*) display value: (NSObject*) value checked: (BOOL) checked;

@property ( nonatomic, retain ) NSString    * display;
@property ( nonatomic, retain ) NSObject    * value;
@property ( nonatomic, assign ) BOOL        checked;

@end
