#import <UIKit/UIKit.h>

@interface LMTableViewSwitchCell : UITableViewCell
{
  UISwitch* _switch;
}

@property (readonly) UISwitch* switchView;

- (id)initWithReuseIdentifier:(NSString*)reuseIdentifier;

@end
