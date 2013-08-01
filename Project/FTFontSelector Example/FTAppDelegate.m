#import "FTAppDelegate.h"
#import "FTViewController.h"


@implementation FTAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions;
{
  self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
  self.window.rootViewController = [FTViewController new];
  [self.window makeKeyAndVisible];
  return YES;
}

@end
