//
//  UIColor+Hex.h
//
//  Created by Kyle Hankinson on 2014-05-05.
//  Copyright (c) 2014 com.hankinsoft.osx. All rights reserved.
//
#import <UIKit/UIKit.h>

@interface UIColor (Hex)

- (NSString *) hexadecimalValue;
- (UIImage *) solidImageWithWidth: (CGFloat) width
                           height: (CGFloat) height;

- (UIColor*) inverseColor;

@end
