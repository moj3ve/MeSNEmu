#import <UIKit/UIKit.h>

@interface TableViewSwitchCell : UITableViewCell
{
  UISwitch* _switch;
}

@property (readonly) UISwitch* switchView;

- (id)initWithReuseIdentifier:(NSString*)reuseIdentifier;

@end
