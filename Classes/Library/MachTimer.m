// MachTimer.m
#import "MachTimer.h"

static mach_timebase_info_data_t timeBase;

@implementation MachTimer
{
    uint64_t timeZero;
}

+ (void) initialize
{
    static dispatch_once_t onceToken = 0;
    
    dispatch_once(&onceToken, ^{
        (void) mach_timebase_info( &timeBase );
    });
}

+ (id) startTimer
{
    MachTimer * timer =
#if( __has_feature( objc_arc ) )
    [[[self class] alloc] init];
#else
    [[[[self class] alloc] init] autorelease];
#endif
    
    [timer start];
    return timer;
}

- (id) init
{
    if( (self = [super init]) ) {
        timeZero = mach_absolute_time();
    }
    return self;
}

- (void) start
{
    timeZero = mach_absolute_time();
}

- (uint64_t) elapsed
{
    return mach_absolute_time() - timeZero;
}

- (CGFloat) elapsedSeconds
{
    return ((CGFloat)(mach_absolute_time() - timeZero))
    * ((CGFloat)timeBase.numer) / ((CGFloat)timeBase.denom) / 1000000000.0;
} // End of elapsedSeconds

- (void) logSlow: (NSString*) logTitle
  ifOverXSeconds: (CGFloat) compare
{
    if(compare < self.elapsedSeconds)
    {
        NSLog(@"%@ (slow) took %f.", logTitle, self.elapsedSeconds);
    }
}

@end