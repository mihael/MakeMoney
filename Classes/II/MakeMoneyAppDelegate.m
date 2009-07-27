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

- (void)dealloc {
    [rootViewController release];
    [window release];
    [super dealloc];
}

#pragma mark UIApplicationDelegate methods
- (void)applicationDidFinishLaunching:(UIApplication *)application {
	app = self;
	[Kriya prayInCode];
	
	//load the stage - a simple settings file
	[self setStage:[Kriya stage]];

	window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] retain];
	rootViewController = [[[RootViewController alloc] init] retain];	
	[window addSubview:[rootViewController view]];
    [window makeKeyAndVisible];

	//rekord this apps startup
	[self startup];
	
	//rekord this apps run count
	[Kriya incrementAppRunCount];
}

- (void)applicationWillTerminate:(UIApplication *)application {
	// Store current spot, so it can be used the next time the app is launched
	[rootViewController saveState]; 	
}
/*
 - (void)application:(UIApplication *)application willChangeStatusBarOrientation:(UIInterfaceOrientation)newStatusBarOrientation duration:(NSTimeInterval)duration;
 {
 // This prevents the view from autorotating to portrait in the simulator
 if ((newStatusBarOrientation == UIInterfaceOrientationPortrait) || (newStatusBarOrientation == UIInterfaceOrientationPortraitUpsideDown))
 [application setStatusBarOrientation:UIInterfaceOrientationLandscapeRight animated:NO];
 }
 */

@end
