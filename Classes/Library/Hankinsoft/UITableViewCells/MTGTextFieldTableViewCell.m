#import "MTGTextFieldTableViewCell.h"

#define CellTextFieldWidth		90.0
#define MarginBetweenControls	20.0

@implementation MTGTextFieldTableViewCell

@synthesize textField;

- (id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)identifier
{
	if ( self = [super initWithStyle:style reuseIdentifier:identifier] )
	{
		// Adding the text field
		textField = [[UITextField alloc] initWithFrame: CGRectMake ( 0, 1, 100, 100 )];
		textField.clearsOnBeginEditing = NO;
		textField.borderStyle = UITextBorderStyleNone;
		textField.returnKeyType = UIReturnKeyDone;
        textField.textAlignment = NSTextAlignmentRight;

		[self.contentView addSubview: textField];
		
		// Un-selectable
		[self setSelectionStyle: UITableViewCellSelectionStyleNone];
    }
    return self;
}

#pragma mark -
#pragma mark Laying out subviews

- (void) layoutSubviews
{
	// Super layout
	[super layoutSubviews];

    CGFloat offset = -self.layoutMargins.right;

    textField.translatesAutoresizingMaskIntoConstraints = NO;
    [textField.centerYAnchor constraintEqualToAnchor: self.centerYAnchor].active = YES;
    [textField.heightAnchor constraintEqualToAnchor: self.heightAnchor].active = YES;
    [textField.rightAnchor constraintEqualToAnchor: self.rightAnchor
                                          constant: offset].active = YES;
    [textField.widthAnchor constraintEqualToAnchor: self.self.widthAnchor
                                        multiplier: 0.5f].active = YES;

	textField.borderStyle = UITextBorderStyleNone;
} // End of layoutSubviews

@end
