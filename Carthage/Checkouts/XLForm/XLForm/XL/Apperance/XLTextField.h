//
//  XLTextField.h
//  XLForm
//
//  Created by Kyle Hankinson on 2016-11-28.
//  Copyright © 2016 XLForm. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XLTextField : UITextField

@property(nonatomic,retain) UIColor * backgroundColor UI_APPEARANCE_SELECTOR;
@property(nonatomic,retain) UIColor * textColorDisabled UI_APPEARANCE_SELECTOR;
@property(nonatomic,retain) UIColor * textColorEnabled UI_APPEARANCE_SELECTOR;

@end
