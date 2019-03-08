//
//  UISetTableViewCell.m
//  MTG Deck Builder
//
//  Created by Kyle Hankinson on 10-08-01.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import "UISetTableCell.h"

@implementation UISetTableCell

@synthesize setImageView, cardSet;

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier
{
	if (self = [super initWithStyle: style
                    reuseIdentifier:reuseIdentifier])
    {
        self.setImageView = [[UIImageView alloc] initWithFrame:(CGRect){.size={32, 32}}];
        self.setImageView.bounds = CGRectMake(5,0,39,40);
        self.setImageView.frame = CGRectMake(2 + (42 / 2 - (32 / 2)),
                                             (40 / 2 - (32 / 2)),
                                             32,
                                             32);//CGRectMake(1, 0, 39, 32);
        self.setImageView.contentMode =  UIViewContentModeScaleAspectFit;
        [self.contentView addSubview: self.setImageView];
    }

    return self;
}

@end
