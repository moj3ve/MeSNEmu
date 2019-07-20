#import <UIKit/UIKit.h>

#import "../Snes9xBridge/SIScreenDelegate.h"

@class EmulatorControllerView;

@interface EmulatorController : UIViewController
{
    EmulatorControllerView* _customView;
    
    UIAlertController* _actionSheet;
    
    volatile NSThread* _emulationThread;
    
    NSString* _romFileName;
    NSString* _initialSaveFileName;
    
    BOOL _isMirror;
    UIWindow* _externalWindow;
    EmulatorController* _externalEmulator;
}

@property (copy) NSString* romFileName;
@property (copy) NSString* initialSaveFileName;

- (void)startWithROM:(NSString*)romFileName;

- (id)initMirrorOf:(EmulatorController*)mainController;

- (UIImage*)getScreen;

@end
