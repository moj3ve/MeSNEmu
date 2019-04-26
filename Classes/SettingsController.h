#import <UIKit/UIKit.h>

#import "../iCade/BTControllerView.h"

extern NSString* const kSettingsChangedNotification;

extern NSString* const kSettingsBluetoothController;

extern NSString* const kSettingsSmoothScaling;
extern NSString* const kSettingsFullScreen;
extern NSString* const kSettingsDarkMode;
extern NSString* const kSettingsRYGBButtons;

extern NSString* const kSettingsSound;
extern NSString* const kSettingsLRThree;
extern NSString* const kSettingsAutoFrameskip;
extern NSString* const kSettingsFrameskipValue;

@class SettingsController;

@protocol SettingsControllerDelegate <NSObject>

- (void)settingsDidDismiss:(SettingsController*)settingsController;

@end

#pragma mark -

@interface SettingsController : UITableViewController
{
  BOOL _hideSettingsThatRequireReset;
  BOOL _changed;
  
  NSIndexPath* _smoothScalingIndexPath;
  NSIndexPath* _fullScreenIndexPath;
  NSIndexPath* _darkModeIndexPath;
  NSIndexPath* _rygbButtonsIndexPath;

  NSIndexPath* _soundIndexPath;
  NSIndexPath* _lrThreeIndexPath;
  NSIndexPath* _autoFrameskipIndexPath;
  NSIndexPath* _frameskipValueIndexPath;
  
  id<SettingsControllerDelegate> _delegate;
}

@property (assign) id<SettingsControllerDelegate> delegate;

- (void)hideSettingsThatRequireReset;

+ (void)setDefaultsIfNotDefined;

@end
