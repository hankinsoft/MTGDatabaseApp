#import <UIKit/UIKit.h>

@interface MTGTextFieldTableViewCell : UITableViewCell

- (id)initWithStyle: (UITableViewCellStyle) style
    reuseIdentifier: (NSString *)identifier;

@property (nonatomic, retain) UITextField *textField;

@end
