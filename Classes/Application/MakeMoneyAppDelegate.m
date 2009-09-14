//
//  MakeMoneyAppDelegate.m
//  MakeMoney
//
#import "MakeMoneyAppDelegate.h"
#import "RootViewController.h"
#import "ASIHTTPRequest.h"
#import "ASINetworkQueue.h"
#import "Reachability.h"
#import "cocos2d.h"
#import "SplashScene.h"

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

	//prepare the window into the brain of human beings
	window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

	if ([[[self stage] valueForKey:@"2D"] boolValue]) {
		//run in cocos2d style

		// director attaches to the window
		[[Director sharedDirector] attachInWindow:window];
		
		// before creating any layer, set the landscape mode
		[[Director sharedDirector] setDeviceOrientation:CCDeviceOrientationLandscapeLeft];
		
		//show the window
		[window makeKeyAndVisible];

		// Create and initialize parent and empty Scene
		Scene *scene = [SplashScene node];
		
		// Create and initialize our HelloWorld Layer
//		Layer *layer = [HelloWorld node];
		// add our HelloWorld Layer as a child of the main scene
//		[scene addChild:layer];
		
		// Run!
		[[Director sharedDirector] runWithScene: scene];

	} else {
		//run in UIKit style
		
		//prepare the rootview
		rootViewController = [[RootViewController alloc] init];	
		[window addSubview:[rootViewController view]];
		
		//show the window
		[window makeKeyAndVisible];
	}
		

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
