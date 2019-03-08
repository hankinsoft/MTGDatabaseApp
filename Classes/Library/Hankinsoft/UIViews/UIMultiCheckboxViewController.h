//
//  UIMultiCheckboxViewController.h
//  MTG Deck Builder
//
//  Created by Kyle Hankinson on 10-09-11.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CheckboxObject.h"

typedef void (^OnCheckboxAction)(NSArray* checkboxItems);

@interface UIMultiCheckboxViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
{
	NSArray             * checkboxItems;
}

@property (nonatomic, retain) NSArray       * checkboxItems;
@property(nonatomic,copy) OnCheckboxAction  onCheckboxAction;

@end
