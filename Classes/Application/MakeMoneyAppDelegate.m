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
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	//todo handle launchOptions -> remote notifications, urlOpen

	app = self;
	[Kriya prayInCode];
	
	//load the stage - a simple settings file
	[self setStage:[Kriya stage]];
	
	//prepare the window into the brain of human beings
	window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	
	if ([[[self stage] valueForKey:@"APN"] boolValue]) {
		//if you want remote notifications you need a full bundle identifier (no wildcards), meaning you have to change it, from com.kitschmaster.* to your com.kitschmaster.XYZApp, you also need to create a provisioning profile for that
		[[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIRemoteNotificationTypeAlert|UIRemoteNotificationTypeBadge|UIRemoteNotificationTypeSound];
	}
	
	if ([[[self stage] valueForKey:@"2D"] boolValue]) {
		//run in cocos2d style
		
		[[CCDirector sharedDirector] attachInWindow:window];
		[[CCDirector sharedDirector] setDeviceOrientation:CCDeviceOrientationLandscapeLeft];
		[window makeKeyAndVisible];
		
		//load splash scene, the initial scene
		NSString *className = [[self stage] valueForKey:@"2D_scene"];
		if (!className)
			className = @"SplashScene";
		Class SceneClass = NSClassFromString(className);
		CCScene *scene = [SceneClass node];
		
		[[CCDirector sharedDirector] runWithScene: scene];
		
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
	
	//NO if the application cannot handle the URL resource, otherwise return YES. The return value is ignored if the application is launched as a result of a remote notification.
	return [self handleLaunchOptions:launchOptions];
}

/*
 This is the original
- (void)applicationDidFinishLaunching:(UIApplication *)application {
	app = self;
	[Kriya prayInCode];
	
	//load the stage - a simple settings file
	[self setStage:[Kriya stage]];

	//prepare the window into the brain of human beings
	window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

	if ([[[self stage] valueForKey:@"APN"] boolValue]) {
		[[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIRemoteNotificationTypeAlert|UIRemoteNotificationTypeBadge|UIRemoteNotificationTypeSound];
	}
	
	if ([[[self stage] valueForKey:@"2D"] boolValue]) {
		//run in cocos2d style
		
		[[CCDirector sharedDirector] attachInWindow:window];
		[[CCDirector sharedDirector] setDeviceOrientation:CCDeviceOrientationLandscapeLeft];
		[window makeKeyAndVisible];

		//load splash scene, the initial scene
		NSString *className = [[self stage] valueForKey:@"2D_scene"];
		if (!className)
			className = @"SplashScene";
		Class SceneClass = NSClassFromString(className);
		CCScene *scene = [SceneClass node];
		
		[[CCDirector sharedDirector] runWithScene: scene];

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
*/
- (void)applicationWillTerminate:(UIApplication *)application {
	// Store current spot, so it can be used the next time the app is launched
	[rootViewController saveState]; 	
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken 
{
	DebugLog(@"didRegisterForRemoteNotificationsWithDeviceToken: %@", deviceToken);
	if ([[[self stage] valueForKey:@"APN"] boolValue] && ([[UIApplication sharedApplication] enabledRemoteNotificationTypes] != UIRemoteNotificationTypeNone) ) {
		//if staged and registered
		[self apnProviderRegisterDeviceWithToken:deviceToken];
	}
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error 
{
	DebugLog(@"didFailRegisterForRemoteNotificationsWithError: %@", error);

}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo 
{
	DebugLog(@"didReceiveRemoteNotification: %@", userInfo);
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
