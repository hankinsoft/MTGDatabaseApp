//
//  UITableViewCell+SQLProApperance.h
//  SQLPro (iOS)
//
//  Created by Kyle Hankinson on 2016-11-25.
//  Copyright © 2016 Hankinsoft Development, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITableViewCell (SQLProApperance)

@property (nonatomic, assign) BOOL darkUI UI_APPEARANCE_SELECTOR;

@property (nonatomic, copy) UIColor * darkTextColor UI_APPEARANCE_SELECTOR;
@property (nonatomic, copy) UIColor * lightTextColor UI_APPEARANCE_SELECTOR;

@end
