#import <UIKit/UIKit.h>

#import "../iCade/BTControllerView.h"

extern NSString* const kSettingsChangedNotification;

extern NSString* const kSettingsBluetoothController;

extern NSString* const kSettingsFullScreen;
extern NSString* const kSettingsDarkMode;
extern NSString* const kSettingsRYGBButtons;

extern NSString* const kSettingsSmoothScaling;
extern NSString* const kSettingsShowFPS;

extern NSString* const kSettingsSound;
extern NSString* const kSettingsSoundSync;
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
  
  NSIndexPath* _fullScreenIndexPath;
  NSIndexPath* _darkModeIndexPath;
  NSIndexPath* _rygbButtonsIndexPath;
    
  NSIndexPath* _smoothScalingIndexPath;
  NSIndexPath* _showFPSIndexPath;

  NSIndexPath* _soundIndexPath;
  NSIndexPath* _soundSyncIndexPath;
  NSIndexPath* _autoFrameskipIndexPath;
  NSIndexPath* _frameskipValueIndexPath;
    
  NSIndexPath* _controllerIndexPath;
  NSIndexPath* _lrThreeIndexPath;
  
  id<SettingsControllerDelegate> _delegate;
}

@property (assign) id<SettingsControllerDelegate> delegate;

- (void)hideSettingsThatRequireReset;

+ (void)setDefaultsIfNotDefined;

@end
