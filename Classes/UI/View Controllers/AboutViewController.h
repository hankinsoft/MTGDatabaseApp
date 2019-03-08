//
//  AboutViewController.h
//  MTG Deck Builder
//
//  Created by Kyle Hankinson on 10-09-08.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GHRootViewController.h"

@interface AboutViewController : UIViewController
{
	UIWebView		* webview;
@private
	RevealBlock _revealBlock;
}

- (id) initWithRevealBlock: (RevealBlock) revealBlock;

@property (nonatomic, retain) IBOutlet UIWebView * webview;
 
@end
