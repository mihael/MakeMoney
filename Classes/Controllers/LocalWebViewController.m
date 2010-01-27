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
	if (!www) {

		www = [[iWWWView alloc] initWithFrame:[Kriya orientedFrame]];

		NSString* path = [[NSUserDefaults standardUserDefaults] valueForKey:@"localweb_path"];
		if (!path) {
			path = [options valueForKey:@"path"];
			[www setNSURL:[NSURL fileURLWithPath: [[NSBundle mainBundle] pathForResource:path ofType:@"xhtml"] isDirectory:NO]];
		} else {
			[www setNSURL:[NSURL fileURLWithPath: path isDirectory:NO]];
		}
		
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
}

- (void)saveState 
{
	NSString* path = [www eval:@"window.location.pathname"];
	[[NSUserDefaults standardUserDefaults] setValue:path forKey:@"localweb_path"];
	
	int scrollPosition = [[www eval:@"scrollY"] intValue];
	//int sizePage = [[www eval:@"document.getElementById(\"foo\").offsetHeight;"] intValue];
	[[NSUserDefaults standardUserDefaults] setInteger:scrollPosition forKey: @"scrollY"];
	DebugLog(@"LocalWebViewController# SAVING STATE Scroll Y Offset: %i PATH: %@", scrollPosition, path);	
	
}

- (void)layout:(CGRect)rect
{
	[www setFrame:rect];
}


@end
