#import "AppDelegate.h"

#import "RomBrowserController.h"

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
