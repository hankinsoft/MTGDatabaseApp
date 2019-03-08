//
//  HSDividerView.h
//  SQLPro (iOS)
//
//  Created by Kyle Hankinson on 2017-06-02.
//  Copyright © 2017 Hankinsoft Development, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum HSDividerViewDividerPosition
{
    HSDividerViewDividerPositionNone     = 0,
    HSDividerViewDividerPositionBottom   = 1,
    HSDividerViewDividerPositionTop      = 2,
    HSDividerViewDividerPositionLeft     = 3,
    HSDividerViewDividerPositionRight    = 4
} HSDividerViewDividerPosition;

@interface HSDividerView : UIView

@property(nonatomic,assign) HSDividerViewDividerPosition dividerPosition;
@property(nonatomic,retain) UIColor * dividerColor UI_APPEARANCE_SELECTOR;

@end
