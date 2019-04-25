#import <UIKit/UIKit.h>

#import "../iCade/LMBTControllerView.h"

extern NSString* const kLMSettingsChangedNotification;

extern NSString* const kLMSettingsBluetoothController;

extern NSString* const kLMSettingsSmoothScaling;
extern NSString* const kLMSettingsFullScreen;
extern NSString* const kLMSettingsDarkMode;
extern NSString* const kLMSettingsRYGBButtons;

extern NSString* const kLMSettingsSound;
extern NSString* const kLMSettingsLRThree;
extern NSString* const kLMSettingsAutoFrameskip;
extern NSString* const kLMSettingsFrameskipValue;

@class SettingsController;

@protocol LMSettingsControllerDelegate <NSObject>

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
  
  id<LMSettingsControllerDelegate> _delegate;
}

@property (assign) id<LMSettingsControllerDelegate> delegate;

- (void)hideSettingsThatRequireReset;

+ (void)setDefaultsIfNotDefined;

@end
