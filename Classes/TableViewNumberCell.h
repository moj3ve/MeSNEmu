#import <UIKit/UIKit.h>

#import "TableViewCellDelegate.h"


@interface TableViewNumberCell : UITableViewCell
{
    int _value;
    int _minimumValue;
    int _maximumValue;
    NSString* _suffix;
    BOOL _usesDefaultValue;
    BOOL _allowsDefault;
    
    UIView* _plusMinusAccessoryView;
    UIButton* _plusButton;
    UIButton* _minusButton;
    UIButton* _defaultButton;
    
    id<TableViewCellDelegate> _delegate;
}

@property (readonly) UIView* plusMinusAccessoryView;
@property (nonatomic) int value;
@property int minimumValue;
@property int maximumValue;
@property (nonatomic, copy) NSString* suffix;
@property (nonatomic) BOOL usesDefaultValue;
@property (nonatomic) BOOL allowsDefault;

@property (assign) id<TableViewCellDelegate> delegate;

- (id)initWithReuseIdentifier:(NSString*)reuseIdentifier;

@end
