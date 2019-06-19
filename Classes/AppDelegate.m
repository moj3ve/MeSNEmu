#import "AppDelegate.h"

#import "RomBrowserController.h"
#import "SettingsController.h"

@implementation AppDelegate

@synthesize window = _window;
@synthesize viewController = _viewController;

- (void)dealloc
{
    [_window release];
    [_viewController release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    #if TARGET_IPHONE_SIMULATOR
        NSLog(@"\nDocuments Directory:\n%@\n\n", [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject]);
    #endif
  
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    self.window.frame = [[UIScreen mainScreen] bounds];
    RomBrowserController* romBrowser = [[RomBrowserController alloc] init];
    UINavigationController* nav = [[UINavigationController alloc] initWithRootViewController:romBrowser];
    self.viewController = nav;
    [nav release];
    [romBrowser release];
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    // if ([[NSUserDefaults standardUserDefaults] boolForKey:@"alertShownOnce"] == NO) {
        
        UIWindow *alertWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        alertWindow.rootViewController = [[UIViewController alloc] init];
        alertWindow.windowLevel = UIWindowLevelAlert + 1;
        
        UIAlertController * alert = [UIAlertController
                                     alertControllerWithTitle:@"Notice"
                                     message:@"Exit Saves & Save States from MeSNEmu v1.4.6.4 and below will not work."
                                     preferredStyle:UIAlertControllerStyleAlert];
    
        UIView *firstSubview = alert.view.subviews.firstObject;
    
        UIView *alertContentView = firstSubview.subviews.firstObject;
        for (UIView *subSubView in alertContentView.subviews) {
            BOOL darkMode = [[NSUserDefaults standardUserDefaults] boolForKey:kSettingsDarkMode];
            if (darkMode == YES) {
                subSubView.backgroundColor = [UIColor colorWithRed:0.10 green:0.10 blue:0.10 alpha:0.3];
            }
        }
        
        UIAlertAction* okayButton = [UIAlertAction
                                     actionWithTitle:@"Okay"
                                     style:UIAlertActionStyleDefault
                                     handler:^(UIAlertAction * action) {
                                         alertWindow.hidden = YES;
                                         [alert dismissViewControllerAnimated:YES completion:nil];
                                     }];
        
        [alert addAction:okayButton];
        
        [alertWindow makeKeyAndVisible];
        [alertWindow.rootViewController presentViewController:alert animated:YES completion:nil];
        
        // [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"alertShownOnce"];
        // [[NSUserDefaults standardUserDefaults] synchronize];
    // }
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
}

- (void)applicationWillTerminate:(UIApplication *)application
{
}

@end
