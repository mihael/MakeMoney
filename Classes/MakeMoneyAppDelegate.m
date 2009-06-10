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
	app = self;
	[Kriya prayInCode];
	[self setStage:[Kriya stage]];
	[self brickboxStartup];
	window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	rootViewController = [[[RootViewController alloc] init] retain];	
	[window addSubview:[rootViewController view]];
    [window makeKeyAndVisible];
	[Kriya incrementAppRunCount];
}

- (void)applicationWillTerminate:(UIApplication *)application {
	// Store current spot, so it is used the next time the app is launched
    [[NSUserDefaults standardUserDefaults] setInteger:[[[rootViewController transenderViewController] transender] currentSpot]
											   forKey:SPOT];
	[[NSUserDefaults standardUserDefaults] synchronize];
	DebugLog(@"Terminated with spot: %i", [[[rootViewController transenderViewController] transender] currentSpot]);
}
/*
- (void)application:(UIApplication *)application willChangeStatusBarOrientation:(UIInterfaceOrientation)newStatusBarOrientation duration:(NSTimeInterval)duration;
{
    // This prevents the view from autorotating to portrait in the simulator
    if ((newStatusBarOrientation == UIInterfaceOrientationPortrait) || (newStatusBarOrientation == UIInterfaceOrientationPortraitUpsideDown))
        [application setStatusBarOrientation:UIInterfaceOrientationLandscapeRight animated:NO];
}
*/
- (void)dealloc {
    [rootViewController release];
    [window release];
    [super dealloc];
}

#pragma mark registration and startup count
- (void)brickboxStartup 
{
	//ensure EDGE network comes on
	NSURL *brickboxUrl = [NSURL URLWithString:[Kriya brickbox_url]];
	[[Reachability sharedReachability] setHostName:[brickboxUrl host]];
	[[Reachability sharedReachability] remoteHostStatus];

	ASIHTTPRequest *request = [[[ASIHTTPRequest alloc] initWithURL:brickboxUrl] autorelease];
	[request setRequestMethod:@"POST"];
	[request setDelegate:self];
	[request setDidFinishSelector:@selector(brickboxStartupFinished:)];
	[request setDidFailSelector:@selector(brickboxStartupFailed:)];
	NSOperationQueue *queue = [[[NSOperationQueue alloc] init] autorelease];
	[queue addOperation:request];	
}

- (void)brickboxStartupFinished:(ASIHTTPRequest *)request
{
	NSInteger startupz = [[request responseString] intValue];
	[[NSUserDefaults standardUserDefaults] setValue:[NSString stringWithFormat:@"%@ downloaded %@.", APP_TITLE, [Kriya howManyTimes:startupz]] forKey:STARTUPS];
	[[NSUserDefaults standardUserDefaults] synchronize];
}


- (void)brickboxStartupFailed:(ASIHTTPRequest *)request
{
	DebugLog(@"Failed brickbox startup.");
}

@end
