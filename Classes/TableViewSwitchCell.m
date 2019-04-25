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
    BOOL darkMode = [[NSUserDefaults standardUserDefaults] boolForKey:kLMSettingsDarkMode];
    if (darkMode == YES) {
        self.backgroundColor = [UIColor colorWithRed:0.10 green:0.10 blue:0.10 alpha:0.9];
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
  BOOL darkMode = [[NSUserDefaults standardUserDefaults] boolForKey:kLMSettingsDarkMode];
  if (darkMode == YES) {
    self.backgroundColor = [UIColor colorWithRed:0.10 green:0.10 blue:0.10 alpha:0.9];
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
