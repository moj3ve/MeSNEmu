#import "LMGameControllerManager.h"

#import <GameController/GameController.h>

#import "../SNES9XBridge/Snes9xMain.h"

@implementation LMGameControllerManager(Privates)

#pragma mark Game Controller Handling

- (void)LM_setupController
{
  if([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0f)
  {
    NSArray* controllers = [GCController controllers];
    // Grab first controller
    // TODO: Add support for multiple controllers
    _gameController = [controllers firstObject];
    
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

- (BOOL)gameControllerConnected
{
  return (_gameController != nil);
}

+ (instancetype)sharedInstance
{
  static dispatch_once_t p = 0;
  
  __strong static id _sharedInstance = nil;
  
  dispatch_once(&p, ^{
    _sharedInstance = [[self alloc] init];
  });
  
  return _sharedInstance;
}

+ (BOOL)gameControllersMightBeAvailable
{
  if([GCController class] != nil)
    return YES;
  return NO;
}

@end

#pragma mark -

@implementation LMGameControllerManager(NSObject)

- (instancetype)init
{
  self = [super init];
  if(self != nil)
  {
    [self LM_setupController];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(LM_controllerConnected:)
                                                 name:GCControllerDidConnectNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(LM_controllerDisconnected:)
                                                 name:GCControllerDidDisconnectNotification
                                               object:nil];
  }
  return self;
}

- (void)dealloc
{
  [[NSNotificationCenter defaultCenter] removeObserver:self
                                                  name:GCControllerDidConnectNotification
                                                object:nil];
  [[NSNotificationCenter defaultCenter] removeObserver:self
                                                  name:GCControllerDidDisconnectNotification
                                                object:nil];
}

@end
