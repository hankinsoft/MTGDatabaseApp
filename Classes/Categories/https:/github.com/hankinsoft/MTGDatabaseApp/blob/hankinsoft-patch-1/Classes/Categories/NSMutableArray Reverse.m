//  NSMutableArray+Extensions.m
//
//  Created by Kyle Hankinson on 2012-11-30.
//  Copyright (c) 2012 Hankinsoft. All rights reserved.
//
#import "NSMutableArray+Reverse.h"
@implementation NSMutableArray (Reverse)
- (void) reverse
{
    if ([self count] == 0)
        return;
   
 
NSUInteger i = 0;
     NSUInteger j = [self count] - 1;
    while (i < j) {
        [self exchangeObjectAtIndex:i
                  withObjectAtIndex:j];
i++;
j--; }
} // End of reverse
@end
