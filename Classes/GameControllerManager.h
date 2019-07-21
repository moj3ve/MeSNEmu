@class GameControllerManager;

@protocol GameControllerManagerDelegate <NSObject>

@required
- (void)gameControllerManagerGamepadDidConnect:(GameControllerManager*)controllerManager;
- (void)gameControllerManagerGamepadDidDisconnect:(GameControllerManager*)controllerManager;

@end

#pragma mark -

@class GCController;

@interface GameControllerManager : NSObject
{
    GCController* _gameController;
}

@property (nonatomic, readonly) BOOL gameControllerConnected;
@property (nonatomic, weak) id<GameControllerManagerDelegate> delegate;

+ (instancetype)sharedInstance;
+ (BOOL)gameControllersMightBeAvailable;

@end
