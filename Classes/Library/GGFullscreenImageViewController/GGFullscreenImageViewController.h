//
//  GGFullscreenImageViewController.h
//  TFM
//
//  Created by John Wu on 6/5/12.
//  Copyright (c) 2012 TFM. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GGFullscreenImageViewController : UIViewController

@property (nonatomic, retain) UIImageView *liftedImageView;
@property (nonatomic, assign) UIInterfaceOrientationMask supportedOrientations;

@end
