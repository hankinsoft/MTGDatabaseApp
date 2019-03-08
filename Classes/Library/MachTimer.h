// MachTimer.h
// Based on: http://zpasternack.org/high-resolution-timing-in-cocoa/
@import Darwin.Mach.mach_time;
@import Foundation;

#if TARGET_OS_IPHONE

#import <UIKit/UIKit.h>

#else

#import <Cocoa/Cocoa.h>

#endif

@interface MachTimer : NSObject

+ (id) startTimer;

- (void) start;
- (uint64_t) elapsed;
- (CGFloat) elapsedSeconds;

- (void) logSlow: (NSString*) logTitle
  ifOverXSeconds: (CGFloat) compare;

@end
