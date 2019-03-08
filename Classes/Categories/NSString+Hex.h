//
//  NSString+Hex.h
//  HSCore
//
//  Created by Kyle Hankinson on 2016-12-09.
//  Copyright © 2016 Hankinsoft Development, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#if TARGET_OS_IPHONE
@import UIKit;
#elif TARGET_OS_MAC
@import Foundation;
#endif

@interface NSString (Hex)

- (UIColor*) hexToColor;
- (UIColor*) hexToColorWithAlpha: (float) alpha;

@end
