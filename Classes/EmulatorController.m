#import "EmulatorController.h"

#import "ButtonView.h"
#import "DPadView.h"
#import "EmulatorControllerView.h"
#import "GameControllerManager.h"
#import "PixelLayer.h"
#import "PixelView.h"
#ifdef SI_ENABLE_SAVES
#import "SaveManager.h"
#endif
#import "SettingsController.h"

#import "../Snes9xBridge/Snes9xMain.h"
#import "../Snes9xBridge/SISaveDelegate.h"

#import "../iCade/BTControllerView.h"

typedef enum _EmulatorAlert
{
  EmulatorAlertReset,
  EmulatorAlertSave,
  EmulatorAlertLoad
} EmulatorAlert;

#pragma mark -

@interface EmulatorController(Privates) <UIActionSheetDelegate, UIAlertViewDelegate, SettingsControllerDelegate, SISaveDelegate, iCadeEventDelegate, SIScreenDelegate, GameControllerManagerDelegate>
@end

#pragma mark -

@implementation EmulatorController(Privates)

- (void)emulationThreadMethod:(NSString*)romFileName;
{
  NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
  
  if(_emulationThread == [NSThread mainThread])
    _emulationThread = [NSThread currentThread];
  
  const char* originalString = [romFileName UTF8String];
  char* romFileNameCString = (char*)calloc(strlen(originalString)+1, sizeof(char));
  strcpy(romFileNameCString, originalString);
  originalString = nil;

  SISetEmulationPaused(0);
  SISetEmulationRunning(1);
  SIStartWithROM(romFileNameCString);
  SISetEmulationRunning(0);
  
  free(romFileNameCString);
  
  if(_emulationThread == [NSThread currentThread])
    _emulationThread = nil;
  
  [pool release];
}

- (void)dismantleExternalScreen
{
  if(_externalEmulator != nil)
  {
    _customView.viewMode = EmulatorControllerViewModeNormal;
    
    SISetScreenDelegate(self);
    [_customView setPrimaryBuffer];

    [_externalEmulator release];
    _externalEmulator = nil;
  }
  
  [_externalWindow release];
  _externalWindow = nil;
  
  if(_customView.superview != nil)
  {
    [UIView animateWithDuration:0.3 animations:^{
      [_customView layoutIfNeeded];
    }];
  }
}

- (void)showSettings
{
  SettingsController* c = [[SettingsController alloc] init];
  [c hideSettingsThatRequireReset];
  c.delegate = self;
  UINavigationController* n = [[UINavigationController alloc] initWithRootViewController:c];
  n.modalPresentationStyle = UIModalPresentationFormSheet;
  [self presentViewController:n animated:YES completion:nil];
  [c release];
  [n release];
}

#pragma mark UI Interaction Handling

- (void)options:(UIButton*)sender
{
    /* int resetIndex = 1;
    
    #ifdef SI_ENABLE_SAVES
        int loadIndex = 2;
        int saveIndex = 3;
        int settingsIndex = 4;
    #else
        int loadIndex = -1;
        int saveIndex = -1;
        int settingsIndex = 2;
    #endif */
    
    SISetEmulationPaused(1);
  
    _customView.iCadeControlView.active = NO;
    if([GameControllerManager gameControllersMightBeAvailable] == YES)
      [_customView setControlsHidden:[GameControllerManager sharedInstance].gameControllerConnected animated:NO];
    else
        [_customView setControlsHidden:NO animated:YES];
    
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIView *firstSubview = actionSheet.view.subviews.firstObject;
    
    UIView *alertContentView = firstSubview.subviews.firstObject;
    for (UIView *subSubView in alertContentView.subviews) {
        BOOL darkMode = [[NSUserDefaults standardUserDefaults] boolForKey:kSettingsDarkMode];
        if (darkMode == YES) {
            subSubView.backgroundColor = [UIColor colorWithRed:0.10 green:0.10 blue:0.10 alpha:0.1];
        }
    }
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"BACK_TO_GAME", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
         SISetEmulationPaused(0);
    }]];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"EXIT_GAME", nil) style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        [self dismantleExternalScreen];
        SISetEmulationRunning(0);
        SIWaitForEmulationEnd();
        [self dismissViewControllerAnimated:YES completion:nil];
    }]];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"RESET", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        UIAlertController * alert = [UIAlertController
                                     alertControllerWithTitle:NSLocalizedString(@"RESET_GAME?", nil)
                                     message:NSLocalizedString(@"RESET_CONSEQUENCES", nil)
                                     preferredStyle:UIAlertControllerStyleAlert];
        
        UIView *firstSubview = alert.view.subviews.firstObject;
        
        UIView *alertContentView = firstSubview.subviews.firstObject;
        for (UIView *subSubView in alertContentView.subviews) {
            BOOL darkMode = [[NSUserDefaults standardUserDefaults] boolForKey:kSettingsDarkMode];
            if (darkMode == YES) {
                subSubView.backgroundColor = [UIColor colorWithRed:0.10 green:0.10 blue:0.10 alpha:0.3];
            }
        }
        
        UIAlertAction* noButton = [UIAlertAction
                                   actionWithTitle:NSLocalizedString(@"CANCEL", nil)
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction * action) {
                                       SISetEmulationPaused(0);
                                   }];
        
        UIAlertAction* yesButton = [UIAlertAction
                                    actionWithTitle:NSLocalizedString(@"RESET", nil)
                                    style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction * action) {
                                        SIReset();
                                    }];
        
        [alert addAction:noButton];
        [alert addAction:yesButton];
        
        [self presentViewController:alert animated:YES completion:nil];
    }]];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"LOAD_STATE", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        UIAlertController * alert = [UIAlertController
                                     alertControllerWithTitle:NSLocalizedString(@"LOAD_SAVE?", nil)
                                     message:NSLocalizedString(@"EXIT_CONSEQUENCES", nil)
                                     preferredStyle:UIAlertControllerStyleAlert];
        
        UIView *firstSubview = alert.view.subviews.firstObject;
        
        UIView *alertContentView = firstSubview.subviews.firstObject;
        for (UIView *subSubView in alertContentView.subviews) {
            BOOL darkMode = [[NSUserDefaults standardUserDefaults] boolForKey:kSettingsDarkMode];
            if (darkMode == YES) {
                subSubView.backgroundColor = [UIColor colorWithRed:0.10 green:0.10 blue:0.10 alpha:0.3];
            }
        }
        
        UIAlertAction* noButton = [UIAlertAction
                                   actionWithTitle:NSLocalizedString(@"CANCEL", nil)
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction * action) {
                                       SISetEmulationPaused(0);
                                   }];
        
        UIAlertAction* yesButton = [UIAlertAction
                                    actionWithTitle:NSLocalizedString(@"LOAD", nil)
                                    style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction * action) {
                                        SISetEmulationPaused(1);
                                        SIWaitForPause();
                                        [SaveManager loadStateForROMNamed:_romFileName slot:1];
                                        SISetEmulationPaused(0);
                                    }];
        
        [alert addAction:noButton];
        [alert addAction:yesButton];
        
        [self presentViewController:alert animated:YES completion:nil];
    }]];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"SAVE_STATE", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        UIAlertController * alert = [UIAlertController
                                     alertControllerWithTitle:NSLocalizedString(@"SAVE_SAVE?", nil)
                                     message:NSLocalizedString(@"SAVE_CONSEQUENCES", nil)
                                     preferredStyle:UIAlertControllerStyleAlert];
        
        UIView *firstSubview = alert.view.subviews.firstObject;
        
        UIView *alertContentView = firstSubview.subviews.firstObject;
        for (UIView *subSubView in alertContentView.subviews) {
            BOOL darkMode = [[NSUserDefaults standardUserDefaults] boolForKey:kSettingsDarkMode];
            if (darkMode == YES) {
                subSubView.backgroundColor = [UIColor colorWithRed:0.10 green:0.10 blue:0.10 alpha:0.3];
            }
        }
        
        UIAlertAction* noButton = [UIAlertAction
                                   actionWithTitle:NSLocalizedString(@"CANCEL", nil)
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction * action) {
                                       SISetEmulationPaused(0);
                                   }];
        
        UIAlertAction* yesButton = [UIAlertAction
                                    actionWithTitle:NSLocalizedString(@"SAVE", nil)
                                    style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction * action) {
                                        SISetEmulationPaused(1);
                                        SIWaitForPause();
                                        [SaveManager saveStateForROMNamed:_romFileName slot:1];
                                        SISetEmulationPaused(0);
                                    }];
        
        [alert addAction:noButton];
        [alert addAction:yesButton];
        
        [self presentViewController:alert animated:YES completion:nil];
    }]];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"SETTINGS", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self showSettings];
    }]];
    
    [self presentViewController:actionSheet animated:YES completion:nil];
    _customView.iCadeControlView.active = YES;
}

#pragma mark SIScreenDelegate

- (void)flipFrontbuffer:(NSArray*)dimensions
{
  [_customView flipFrontBufferWidth:[[dimensions objectAtIndex:0] intValue] height:[[dimensions objectAtIndex:1] intValue]];
}

#pragma mark SISaveDelegate

- (void)loadROMRunningState
{
#ifdef SI_ENABLE_RUNNING_SAVES
  NSLog(@"Loading running state...");
  if(_initialSaveFileName == nil)
  {
    [SaveManager loadRunningStateForROMNamed:_romFileName];
  }
  else
  {
    int slot = [[[_initialSaveFileName stringByDeletingPathExtension] pathExtension] intValue];
    if(slot == 0)
      [SaveManager loadRunningStateForROMNamed:_romFileName];
    else
      [SaveManager loadStateForROMNamed:_romFileName slot:slot];
  }
  NSLog(@"Loaded!");
#endif
}

- (void)saveROMRunningState
{
#ifdef SI_ENABLE_RUNNING_SAVES
  NSLog(@"Saving running state...");
  [SaveManager saveRunningStateForROMNamed:_romFileName];
  NSLog(@"Saved!");
#endif
}

#pragma mark SettingsControllerDelegate

- (void)settingsDidDismiss:(SettingsController*)settingsController
{
    if(_actionSheet == nil)
    {
        [self options:nil];
    }
}

#pragma mark iCadeEventDelegate

- (void)buttonDown:(iCadeState)button
{  
  switch(button)
  {
    case iCadeJoystickRight:
      SISetControllerPushButton(SI_BUTTON_RIGHT);
      break;
    case iCadeJoystickUp:
      SISetControllerPushButton(SI_BUTTON_UP);
      break;
    case iCadeJoystickLeft:
      SISetControllerPushButton(SI_BUTTON_LEFT);
      break;
    case iCadeJoystickDown:
      SISetControllerPushButton(SI_BUTTON_DOWN);
      break;
    case iCadeButtonA:
      SISetControllerPushButton(SI_BUTTON_SELECT);
      break;
    case iCadeButtonB:
      SISetControllerPushButton(SI_BUTTON_START);
      break;
    case iCadeButtonC:
      SISetControllerPushButton(SI_BUTTON_Y);
      break;
    case iCadeButtonD:
      SISetControllerPushButton(SI_BUTTON_B);
      break;
    case iCadeButtonE:
      SISetControllerPushButton(SI_BUTTON_X);
      break;
    case iCadeButtonF:
      SISetControllerPushButton(SI_BUTTON_A);
      break;
    case iCadeButtonG:
      SISetControllerPushButton(SI_BUTTON_L);
      break;
    case iCadeButtonH:
      SISetControllerPushButton(SI_BUTTON_R);
      break;
    default:
      break;
  }
  
  [_customView setControlsHidden:YES animated:YES];
}

- (void)buttonUp:(iCadeState)button
{  
  switch(button)
  {
    case iCadeJoystickRight:
      SISetControllerReleaseButton(SI_BUTTON_RIGHT);
      break;
    case iCadeJoystickUp:
      SISetControllerReleaseButton(SI_BUTTON_UP);
      break;
    case iCadeJoystickLeft:
      SISetControllerReleaseButton(SI_BUTTON_LEFT);
      break;
    case iCadeJoystickDown:
      SISetControllerReleaseButton(SI_BUTTON_DOWN);
      break;
    case iCadeButtonA:
      SISetControllerReleaseButton(SI_BUTTON_SELECT);
      break;
    case iCadeButtonB:
      SISetControllerReleaseButton(SI_BUTTON_START);
      break;
    case iCadeButtonC:
      SISetControllerReleaseButton(SI_BUTTON_Y);
      break;
    case iCadeButtonD:
      SISetControllerReleaseButton(SI_BUTTON_B);
      break;
    case iCadeButtonE:
      SISetControllerReleaseButton(SI_BUTTON_X);
      break;
    case iCadeButtonF:
      SISetControllerReleaseButton(SI_BUTTON_A);
      break;
    case iCadeButtonG:
      SISetControllerReleaseButton(SI_BUTTON_L);
      break;
    case iCadeButtonH:
      SISetControllerReleaseButton(SI_BUTTON_R);
      break;
    default:
      break;
  } 
}

#pragma mark GameControllerManagerDelegate

- (void)gameControllerManagerGamepadDidConnect:(GameControllerManager*)controllerManager
{
  [_customView setControlsHidden:YES animated:YES];
}

- (void)gameControllerManagerGamepadDidDisconnect:(GameControllerManager*)controllerManager
{
  [_customView setControlsHidden:NO animated:YES];
}

#pragma mark Notifications

- (void)didBecomeInactive
{
  UIBackgroundTaskIdentifier identifier = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
    [[UIApplication sharedApplication] endBackgroundTask:identifier];
  }];
  SISetEmulationPaused(1);
  SIWaitForPause();
  [[UIApplication sharedApplication] endBackgroundTask:identifier];
}

- (void)didBecomeActive
{
    if(_actionSheet == nil)
    {
        [self options:nil];
    }
    [self screensChanged];
}

- (void)screensChanged
{
#ifdef LOG_SCREENS
  NSLog(@"Screens changed");
  for(UIScreen* screen in [UIScreen screens])
  {
    NSLog(@"Screen: %@", screen);
    for (UIScreenMode* mode in screen.availableModes)
    {
      NSLog(@"Mode: %@", mode);
    }
  }
#endif
  
  if([[UIScreen screens] count] > 1)
  {
    if(_externalWindow == nil)
    {
      UIScreen* screen = [[UIScreen screens] objectAtIndex:1];
      UIWindow* window = [[UIWindow alloc] initWithFrame:screen.bounds];
      window.screen = screen;
      window.backgroundColor = [UIColor redColor];
      
      _externalEmulator = [[EmulatorController alloc] initMirrorOf:self];
      window.rootViewController = _externalEmulator;
      
      window.hidden = NO;
      _externalWindow = window;
      
      _customView.viewMode = EmulatorControllerViewModeControllerOnly;
      [UIView animateWithDuration:0.3 animations:^{
        [_customView layoutIfNeeded];
      }];
    }
  }
  else
  {
    [self dismantleExternalScreen];
  }
}

- (void)settingsChanged
{
  NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
  SISetSoundOn([defaults boolForKey:kSettingsSound]);
  SISetShowFPS([defaults boolForKey:kSettingsShowFPS]);
  if([defaults boolForKey:kSettingsSmoothScaling] == YES)
    [_customView setMinMagFilter:kCAFilterLinear];
  else
    [_customView setMinMagFilter:kCAFilterNearest];
  SISetAutoFrameskip([defaults boolForKey:kSettingsAutoFrameskip]);
  SISetFrameskip([defaults integerForKey:kSettingsFrameskipValue]);
  
  _customView.iCadeControlView.controllerType = [[NSUserDefaults standardUserDefaults] integerForKey:kSettingsBluetoothController];
  
  SIUpdateSettings();
  
  [_customView setNeedsLayout];
  [UIView animateWithDuration:0.3 animations:^{
    [_customView layoutIfNeeded];
  }];
}

@end

#pragma mark -

@implementation EmulatorController

@synthesize romFileName = _romFileName;
@synthesize initialSaveFileName = _initialSaveFileName;

- (void)startWithROM:(NSString*)romFileName
{
  if(_emulationThread != nil)
    return;
  
  [SettingsController setDefaultsIfNotDefined];
  
  [self settingsChanged];
  
  _emulationThread = [NSThread mainThread];
  [NSThread detachNewThreadSelector:@selector(emulationThreadMethod:) toTarget:self withObject:romFileName];
}

- (id)initMirrorOf:(EmulatorController*)mainController
{
  self = [self init];
  if(self)
  {
    _isMirror = YES;
    [self view];
    _customView.viewMode = EmulatorControllerViewModeScreenOnly;
    _customView.iCadeControlView.active = NO;
  }
  return self;
}

@end

#pragma mark -

@implementation EmulatorController(UIViewController)

- (void)loadView
{
  _customView = [[EmulatorControllerView alloc] initWithFrame:CGRectZero];
  _customView.iCadeControlView.delegate = self;
  [_customView.optionsButton addTarget:self action:@selector(options:) forControlEvents:UIControlEventTouchUpInside];
  self.view = _customView;
}

- (void)viewDidUnload
{
  [super viewDidUnload];
  
  [_customView release];
  _customView = nil;
}

- (void)viewWillAppear:(BOOL)animated
{  
  [super viewWillAppear:animated];
  
  [UIApplication sharedApplication].idleTimerDisabled = YES;
  
  if(_isMirror == NO)
  {
    [self screensChanged];
    
    if([GameControllerManager gameControllersMightBeAvailable] == YES)
    {
      GameControllerManager* gameControllerManager = [GameControllerManager sharedInstance];
      gameControllerManager.delegate = self;
      [_customView setControlsHidden:gameControllerManager.gameControllerConnected animated:NO];
    }
  }
}

- (void)viewDidAppear:(BOOL)animated
{
  [super viewDidAppear:animated];
  
  if(_isMirror == NO)
  {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didBecomeInactive) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(screensChanged) name:UIScreenDidConnectNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(screensChanged) name:UIScreenDidDisconnectNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(saveROMRunningState:) name:SISaveRunningStateNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadROMRunningState:) name:SILoadRunningStateNotification object:nil];
  }
  
  if(_externalEmulator == nil)
  {
    SISetScreenDelegate(self);
    [_customView setPrimaryBuffer];
  }
  
  if(_isMirror == NO)
  {
    SISetSaveDelegate(self);
    if(_emulationThread == nil)
      [self startWithROM:_romFileName];
  }
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
  
  [UIApplication sharedApplication].idleTimerDisabled = NO;
  
  if([GameControllerManager gameControllersMightBeAvailable] == YES)
  {
    GameControllerManager* gameControllerManager = [GameControllerManager sharedInstance];
    if(gameControllerManager.delegate == self)
      gameControllerManager.delegate = nil;
  }
  
  [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
  [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
  [[NSNotificationCenter defaultCenter] removeObserver:self name:UIScreenDidConnectNotification object:nil];
  [[NSNotificationCenter defaultCenter] removeObserver:self name:UIScreenDidDisconnectNotification object:nil];
  [[NSNotificationCenter defaultCenter] removeObserver:self name:SISaveRunningStateNotification object:nil];
  [[NSNotificationCenter defaultCenter] removeObserver:self name:SILoadRunningStateNotification object:nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
  if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
  else
    return YES;
}

- (BOOL)prefersStatusBarHidden
{
  return YES;
}

@end

#pragma mark -

@implementation EmulatorController(NSObject)

- (id)init
{
  self = [super init];
  if(self)
  {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(settingsChanged) name:kSettingsChangedNotification object:nil];
  }
  return self;
}

- (void)dealloc
{
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  
  if(_isMirror == NO)
  {
    SISetEmulationRunning(0);
    SIWaitForEmulationEnd();
    SISetScreenDelegate(nil);
    SISetSaveDelegate(nil);
  }
    
  _actionSheet = nil;
  
  [self dismantleExternalScreen];
  
  [_customView release];
  _customView = nil;
  
  self.romFileName = nil;
  self.initialSaveFileName = nil;
  
  [super dealloc];
}

@end
