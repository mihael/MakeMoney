//
//  LocalWebViewController.m
//  MakeMoney
//

#import "LocalWebViewController.h"


@implementation LocalWebViewController

//THIS IS CALLED ONCE FOR EVERY LOADED VIEW TRANSEND 
//something like init, since transender can reuse views, they need to be initialized.
- (void)functionalize 
{
	//write this in subclass
	if (!www) {
		www = [[iWWWView alloc] initWithFrame:[Kriya orientedFrame]];
		[www setNSURL:[NSURL fileURLWithPath: [[NSBundle mainBundle] pathForResource:@"index" ofType:@"html"] isDirectory:NO]];
		self.view = www;
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(saveState) name:UIApplicationWillTerminateNotification object:nil];
	}
}

- (void)dealloc {
	[www release];
	[super dealloc];
}

//code you implement here should start some functions or enable something after transending
- (void)startFunctioning 
{

	//NSString *r = [www eval:[NSString stringWithFormat:@"window.scrollTo(0, %d);", [[NSUserDefaults standardUserDefaults] integerForKey:@"scrollY"]]];
	//DebugLog(@"START SCROLL %d %@", [[NSUserDefaults standardUserDefaults] integerForKey:@"scrollY"], r);	
}

//code you implement here should stop some functions or denable something 
- (void)stopFunctioning 
{
	[self saveState];
	
	//write this in subclass
	//[notControls wwwClear];
}

- (void)saveState 
{
	int scrollPosition = [[www eval:@"scrollY"] intValue];
	
	//int sizePage = [[www eval:@"document.getElementById(\"foo\").offsetHeight;"] intValue];
	
	[[NSUserDefaults standardUserDefaults] setInteger:scrollPosition forKey: @"scrollY"];
	
	DebugLog(@"LocalWebViewController# SAVING STATE Scroll Y Offset: %i", scrollPosition);	
	
}
@end
