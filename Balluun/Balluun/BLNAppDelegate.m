#import "BLNAppDelegate.h"
#import "BLNManager.h"

@interface BLNAppDelegate ()

@end

@implementation BLNAppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    ;
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    ;
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    ;
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    ;
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    ;
}

- (void)applicationShouldRequestHealthAuthorization:(nonnull UIApplication *)application
{
    [[BLNManager sharedInstance] requestPermissions];
}

@end
