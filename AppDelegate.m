#import "AppDelegate.h"
#import "OverviewViewController.h"
#import "ProcessesViewController.h"

@implementation AppDelegate

@synthesize window = _window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];

    OverviewViewController *overview = [[[OverviewViewController alloc] initWithStyle:UITableViewStyleGrouped] autorelease];
    UINavigationController *overviewNav = [[[UINavigationController alloc] initWithRootViewController:overview] autorelease];
    overviewNav.tabBarItem = [[[UITabBarItem alloc] initWithTitle:@"Overview" image:nil tag:0] autorelease];

    ProcessesViewController *processes = [[[ProcessesViewController alloc] initWithStyle:UITableViewStylePlain] autorelease];
    UINavigationController *processesNav = [[[UINavigationController alloc] initWithRootViewController:processes] autorelease];
    processesNav.tabBarItem = [[[UITabBarItem alloc] initWithTitle:@"Processes" image:nil tag:1] autorelease];

    UITabBarController *tabs = [[[UITabBarController alloc] init] autorelease];
    tabs.viewControllers = [NSArray arrayWithObjects:overviewNav, processesNav, nil];

    self.window.rootViewController = tabs;
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)dealloc {
    [_window release];
    [super dealloc];
}

@end
