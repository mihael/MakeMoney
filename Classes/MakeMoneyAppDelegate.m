//
//  MakeMoneyAppDelegate.m
//  MakeMoney
//
#import "MakeMoneyAppDelegate.h"
#import "RootViewController.h"
#import "ASIHTTPRequest.h"
#import "ASINetworkQueue.h"
#import "Reachability.h"

@implementation MakeMoneyAppDelegate


@synthesize window;
@synthesize rootViewController, stage;

static MakeMoneyAppDelegate* app = nil;

+ (MakeMoneyAppDelegate*)app {
	return app;
}

+ (NSString*) version {
	return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
}

- (void)applicationDidFinishLaunching:(UIApplication *)application {
	//[[UIApplication sharedApplication] setStatusBarHidden:YES];
	//[[NSUserDefaults standardUserDefaults] setInteger:0 forKey:RUNS];
	//[[NSUserDefaults standardUserDefaults] synchronize];
	app = self;
	[Kriya prayInCode];
	[self setStage:[Kriya stage]];
	
	window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	rootViewController = [[[RootViewController alloc] init] retain];
	
	[window addSubview:[rootViewController view]];
    [window makeKeyAndVisible];
	[Kriya incrementAppRunCount];
}

// Invoked immediately before the application terminates.
- (void)applicationWillTerminate:(UIApplication *)application {
	// Store current spot, so it is used the next time the app is launched
    [[NSUserDefaults standardUserDefaults] setInteger:[[[rootViewController mainViewController] transender] currentSpot]
											   forKey:SPOT];
	NSLog(@"Saved spot: %i", [[[rootViewController mainViewController] transender] currentSpot]);
}

- (void)dealloc {
    [rootViewController release];
    [window release];
    [super dealloc];
}

@end
