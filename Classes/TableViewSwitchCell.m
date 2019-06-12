#import "TableViewSwitchCell.h"
#import "SettingsController.h"

@implementation TableViewSwitchCell(Privates)

- (void)setup
{
  [_switch removeTarget:nil action:nil forControlEvents:UIControlEventAllEvents];
  
  self.accessoryType = UITableViewCellAccessoryNone;
  self.selectionStyle = UITableViewCellSelectionStyleNone;
  
  self.textLabel.text = nil;
  self.detailTextLabel.text = nil;
}

@end

#pragma mark -

@implementation TableViewSwitchCell

- (UISwitch*)switchView
{
  if(_switch == nil)
  {
    _switch = [[UISwitch alloc] initWithFrame:(CGRect){0,0, 0,0}];
    self.accessoryView = _switch;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    BOOL darkMode = [[NSUserDefaults standardUserDefaults] boolForKey:kSettingsDarkMode];
    if (darkMode == YES) {
        self.backgroundColor = [UIColor colorWithRed:0.11 green:0.11 blue:0.12 alpha:1.0];
    }
  }
  return _switch;
}

- (id)initWithReuseIdentifier:(NSString*)reuseIdentifier
{
  self = [self initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
  return self;
}

@end

#pragma mark -

@implementation TableViewSwitchCell(UITableViewCell)

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString*)reuseIdentifier
{
  BOOL darkMode = [[NSUserDefaults standardUserDefaults] boolForKey:kSettingsDarkMode];
  if (darkMode == YES) {
      self.backgroundColor = [UIColor colorWithRed:0.11 green:0.11 blue:0.12 alpha:1.0];
  }
  self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
  if (self)
  {
  }
  return self;
}

- (void)prepareForReuse
{
  [super prepareForReuse];
  
  [self setup];
}

@end

#pragma mark -

@implementation TableViewSwitchCell(NSObject)

- (void)dealloc
{
  [_switch release];
  _switch = nil;
  
  [super dealloc];
}

@end
