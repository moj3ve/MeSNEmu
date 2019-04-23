#import "LMGameControllerManager.h"
#import "LMSettingsController.h"
#import <GameController/GameController.h>
#import "../SNES9XBridge/Snes9xMain.h"

@implementation LMGameControllerManager(Privates)

#pragma mark Game Controller Handling

- (void)LM_setupController
{
   if([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0f)
   {
      NSArray* controllers = [GCController controllers];
      _gameController = [controllers firstObject];
      _gameController.playerIndex = 0;
      
      if (_gameController) {
          [self.delegate gameControllerManagerGamepadDidConnect:self];
      } else {
          [self.delegate gameControllerManagerGamepadDidDisconnect:self];
      }
    
      __weak id weakSelf = self;
    
      _gameController.gamepad.valueChangedHandler = ^(GCGamepad* gamepad, GCControllerElement* element) {
          [weakSelf LM_getCurrentControllerInput];
      };
      _gameController.extendedGamepad.valueChangedHandler = ^(GCExtendedGamepad* gamepad, GCControllerElement* element) {
          [weakSelf LM_getCurrentControllerInput];
      };
   }
}

- (void)LM_controllerConnected:(NSNotification*)notification
{
  [self LM_setupController];
  [self.delegate gameControllerManagerGamepadDidConnect:self];
}

- (void)LM_controllerDisconnected:(NSNotification*)notification
{
  [self LM_setupController];
  [self.delegate gameControllerManagerGamepadDidDisconnect:self];
}

- (void)LM_getCurrentControllerInput
{
    if(_gameController)
    {
        if(_gameController.extendedGamepad)
        {
            GCExtendedGamepad* extendedGamepad = _gameController.extendedGamepad;
            
            if (extendedGamepad.leftThumbstick.up.pressed) {
                SISetControllerPushButton(SI_BUTTON_UP);
            }
            else if (extendedGamepad.dpad.up.pressed) {
                SISetControllerPushButton(SI_BUTTON_UP);
            }
            else {
                SISetControllerReleaseButton(SI_BUTTON_UP);
            }
            if (extendedGamepad.leftThumbstick.down.pressed) {
                SISetControllerPushButton(SI_BUTTON_DOWN);
            }
            else if (extendedGamepad.dpad.down.pressed) {
                SISetControllerPushButton(SI_BUTTON_DOWN);
            }
            else {
                SISetControllerReleaseButton(SI_BUTTON_DOWN);
            }
            if (extendedGamepad.leftThumbstick.left.pressed) {
                SISetControllerPushButton(SI_BUTTON_LEFT);
            }
            else if (extendedGamepad.dpad.left.pressed) {
                SISetControllerPushButton(SI_BUTTON_LEFT);
            }
            else {
                SISetControllerReleaseButton(SI_BUTTON_LEFT);
            }
            if (extendedGamepad.leftThumbstick.right.pressed) {
                SISetControllerPushButton(SI_BUTTON_RIGHT);
            }
            else if (extendedGamepad.dpad.right.pressed) {
                SISetControllerPushButton(SI_BUTTON_RIGHT);
            }
            else {
                SISetControllerReleaseButton(SI_BUTTON_RIGHT);
            }
            if (extendedGamepad.buttonA.pressed) {
                SISetControllerPushButton(SI_BUTTON_B);
            }
            else {
                SISetControllerReleaseButton(SI_BUTTON_B);
            }
            if (extendedGamepad.buttonB.pressed) {
                SISetControllerPushButton(SI_BUTTON_A);
            }
            else {
                SISetControllerReleaseButton(SI_BUTTON_A);
            }
            if (extendedGamepad.buttonX.pressed) {
                SISetControllerPushButton(SI_BUTTON_Y);
            }
            else {
                SISetControllerReleaseButton(SI_BUTTON_Y);
            }
            if (extendedGamepad.buttonY.pressed) {
                SISetControllerPushButton(SI_BUTTON_X);
            }
            else {
                SISetControllerReleaseButton(SI_BUTTON_X);
            }
            if (extendedGamepad.leftShoulder.pressed) {
                SISetControllerPushButton(SI_BUTTON_L);
            }
            else {
                SISetControllerReleaseButton(SI_BUTTON_L);
            }
            if (extendedGamepad.rightShoulder.pressed) {
                SISetControllerPushButton(SI_BUTTON_R);
            }
            else {
                SISetControllerReleaseButton(SI_BUTTON_R);
            }
            BOOL lrThree = [[NSUserDefaults standardUserDefaults] boolForKey:kLMSettingsLRThree];
            if (lrThree == YES) {
                if (@available(iOS 12.1, *)) {
                    if (extendedGamepad.leftTrigger.pressed) {
                    SISetControllerPushButton(SI_BUTTON_SELECT);
                    }
                    else if (extendedGamepad.rightThumbstickButton.pressed) {
                        SISetControllerPushButton(SI_BUTTON_SELECT);
                    }
                    else {
                        SISetControllerReleaseButton(SI_BUTTON_SELECT);
                    }
                    if (extendedGamepad.rightTrigger.pressed) {
                        SISetControllerPushButton(SI_BUTTON_START);
                    }
                    else if (extendedGamepad.leftThumbstickButton.pressed) {
                        SISetControllerPushButton(SI_BUTTON_START);
                    }
                    else {
                        SISetControllerReleaseButton(SI_BUTTON_START);
                    }
                }
                else {
                    if (extendedGamepad.leftTrigger.pressed) {
                        SISetControllerPushButton(SI_BUTTON_SELECT);
                    }
                    else {
                        SISetControllerReleaseButton(SI_BUTTON_SELECT);
                    }
                    if (extendedGamepad.rightTrigger.pressed) {
                        SISetControllerPushButton(SI_BUTTON_START);
                    }
                    else {
                        SISetControllerReleaseButton(SI_BUTTON_START);
                    }
                }
            }
            else {
                if (extendedGamepad.leftTrigger.pressed) {
                    SISetControllerPushButton(SI_BUTTON_SELECT);
                }
                else {
                    SISetControllerReleaseButton(SI_BUTTON_SELECT);
                }
                if (extendedGamepad.rightTrigger.pressed) {
                    SISetControllerPushButton(SI_BUTTON_START);
                }
                else {
                    SISetControllerReleaseButton(SI_BUTTON_START);
                }
            }
            extendedGamepad.controller.controllerPausedHandler = ^(GCController *controller) {
                if (extendedGamepad.leftShoulder.pressed) {
                    SISetControllerPushButton(SI_BUTTON_SELECT);
                    [self performSelector:@selector(releaseSelect) withObject:nil afterDelay:0.1];
                }
                else {
                    SISetControllerPushButton(SI_BUTTON_START);
                    [self performSelector:@selector(releaseStart) withObject:nil afterDelay:0.1];
                }
            };
        }
        else if(_gameController.gamepad)
        {
            GCGamepad* gamepad = _gameController.gamepad;
            
            if (gamepad.buttonA.pressed) {
                SISetControllerPushButton(SI_BUTTON_B);
            }
            else {
                SISetControllerReleaseButton(SI_BUTTON_B);
            }
            if (gamepad.buttonB.pressed) {
                SISetControllerPushButton(SI_BUTTON_A);
            }
            else {
                SISetControllerReleaseButton(SI_BUTTON_A);
            }
            if (gamepad.buttonX.pressed) {
                SISetControllerPushButton(SI_BUTTON_Y);
            }
            else {
                SISetControllerReleaseButton(SI_BUTTON_Y);
            }
            if (gamepad.buttonY.pressed) {
                SISetControllerPushButton(SI_BUTTON_X);
            }
            else {
                SISetControllerReleaseButton(SI_BUTTON_X);
            }
            if (gamepad.leftShoulder.pressed) {
                SISetControllerPushButton(SI_BUTTON_L);
            }
            else {
                SISetControllerReleaseButton(SI_BUTTON_L);
            }
            if (gamepad.rightShoulder.pressed) {
                SISetControllerPushButton(SI_BUTTON_R);
            }
            else {
                SISetControllerReleaseButton(SI_BUTTON_R);
            }
            if (gamepad.dpad.up.pressed) {
                SISetControllerPushButton(SI_BUTTON_UP);
            }
            else {
                SISetControllerReleaseButton(SI_BUTTON_UP);
            }
            if (gamepad.dpad.down.pressed) {
                SISetControllerPushButton(SI_BUTTON_DOWN);
            }
            else {
                SISetControllerReleaseButton(SI_BUTTON_DOWN);
            }
            if (gamepad.dpad.left.pressed) {
                SISetControllerPushButton(SI_BUTTON_LEFT);
            }
            else {
                SISetControllerReleaseButton(SI_BUTTON_LEFT);
            }
            if (gamepad.dpad.right.pressed) {
                SISetControllerPushButton(SI_BUTTON_RIGHT);
            }
            else {
                SISetControllerReleaseButton(SI_BUTTON_RIGHT);
            }
            gamepad.controller.controllerPausedHandler = ^(GCController *controller) {
                if (gamepad.leftShoulder.pressed) {
                    SISetControllerPushButton(SI_BUTTON_SELECT);
                    [self performSelector:@selector(releaseSelect) withObject:nil afterDelay:0.1];
                }
                else {
                    SISetControllerPushButton(SI_BUTTON_START);
                    [self performSelector:@selector(releaseStart) withObject:nil afterDelay:0.1];
                }
            };
        }
    }
}

- (void)releaseSelect {
    SISetControllerReleaseButton(SI_BUTTON_SELECT);
}

- (void)releaseStart {
    SISetControllerReleaseButton(SI_BUTTON_START);
}

@end

#pragma mark -

@implementation LMGameControllerManager

- (BOOL)gameControllerConnected {
    BOOL result = (_gameController != nil);
    return result;
}

+ (instancetype)sharedInstance {
  static dispatch_once_t p = 0;
  
  __strong static id _sharedInstance = nil;
  
  dispatch_once(&p, ^{
    _sharedInstance = [[self alloc] init];
  });
  
  return _sharedInstance;
}

+ (BOOL)gameControllersMightBeAvailable {
    if ([GCController class] != nil) {
        return YES;
    }
    return NO;
}
@end

#pragma mark -

@implementation LMGameControllerManager(NSObject)

- (instancetype)init {
    self = [super init];
    if (self) {
        [GCController startWirelessControllerDiscoveryWithCompletionHandler:^{
            [self LM_setupController];
        }];
        
        [self LM_setupController];
        NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
        [defaultCenter addObserver:self
                          selector:@selector(LM_setupController)
                              name:GCControllerDidConnectNotification
                            object:nil];
        [defaultCenter addObserver:self
                          selector:@selector(LM_setupController)
                              name:GCControllerDidDisconnectNotification
                            object:nil];
        [defaultCenter addObserver:self
                          selector:@selector(LM_setupController)
                              name:UIApplicationDidBecomeActiveNotification
                            object:nil];
        
    }
    return self;
}

- (void)dealloc {
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    [defaultCenter removeObserver:self
                             name:GCControllerDidConnectNotification
                           object:nil];
    [defaultCenter removeObserver:self
                             name:GCControllerDidDisconnectNotification
                           object:nil];
    [defaultCenter removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
}

@end
