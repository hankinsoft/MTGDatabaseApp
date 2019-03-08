//
//  GHSidebarMenuCell.m
//  GHSidebarNav
//
//  Created by Greg Haines on 11/20/11.
//

#import "GHMenuCell.h"


#pragma mark -
#pragma mark Constants
NSString const *kSidebarCellTextKey = @"CellText";
NSString const *kSidebarCellImageKey = @"CellImage";

#pragma mark -
#pragma mark Implementation
@implementation GHMenuCell

#pragma mark Memory Management
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        self.clipsToBounds = YES;
        self.backgroundColor = [UIColor clearColor];
        
        UIView *bgView = [[UIView alloc] init];
        
        // Selected cells color
        bgView.backgroundColor = [UIColor colorWithRed:(30.0f/255.0f)
                                                 green:(30.0f/255.0f)
                                                  blue:(30.0f/255.0f)
                                                 alpha:1.0f];
        
        self.selectedBackgroundView = bgView;
        
        self.imageView.contentMode = UIViewContentModeCenter;
        
        self.textLabel.font = [UIFont fontWithName:@"Helvetica"
                                              size:([UIFont systemFontSize] * 1.2f)];
        
        self.textLabel.shadowOffset = CGSizeMake(0.0f, 1.0f);
        self.textLabel.shadowColor = [UIColor colorWithWhite:0.0f alpha:0.25f];
        self.textLabel.textColor = [UIColor colorWithRed:(196.0f/255.0f)
                                                   green:(204.0f/255.0f)
                                                    blue:(218.0f/255.0f)
                                                   alpha:1.0f];
        
        UIView *topLine = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, [UIScreen mainScreen].bounds.size.height, 1.0f)];
        topLine.backgroundColor = [UIColor colorWithRed:(54.0f/255.0f)
                                                  green:(54.0f/255.0f)
                                                   blue:(54.0f/255.0f) alpha:1.0f];
        [self.textLabel.superview addSubview:topLine];
        
        UIView *topLine2 = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 1.0f, [UIScreen mainScreen].bounds.size.height, 1.0f)];
        
        topLine2.backgroundColor = [UIColor colorWithRed:(54.0f/255.0f)
                                                   green:(54.0f/255.0f)
                                                    blue:(54.0f/255.0f)
                                                   alpha:1.0f];
        
        [self.textLabel.superview addSubview:topLine2];
        
        UIView *bottomLine = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 43.0f, [UIScreen mainScreen].bounds.size.height, 1.0f)];
        
        bottomLine.backgroundColor = [UIColor colorWithRed:(54.0f/255.0f)
                                                     green:(54.0f/255.0f)
                                                      blue:(54.0f/255.0f)
                                                     alpha:1.0f];
        [self.textLabel.superview addSubview:bottomLine];
    }
    return self;
}

#pragma mark UIView
- (void)layoutSubviews {
    [super layoutSubviews];
    self.textLabel.frame = CGRectMake(50.0f, 0.0f, 200.0f, 43.0f);
    self.imageView.frame = CGRectMake(0.0f, 0.0f, 50.0f, 43.0f);
}

@end
