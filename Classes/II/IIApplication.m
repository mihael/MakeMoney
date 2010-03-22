//
//  IIApplication.m
//  MakeMoney
//
#import "IIApplication.h"
#import "Reachability.h"
#import "ASIHTTPRequest.h"

@implementation IIApplication
#pragma mark launch
- (BOOL)handleLaunchOptions:(NSDictionary*)launchOptions {
	//write this to get your behavior
	//return YES if your app can handle the launches Options
	return YES;
}

#pragma mark push notifications
- (void)apnProviderRegisterDeviceWithToken:(NSData*)deviceToken
{
	//todo
	//call server
	//ensure EDGE network comes on
	NSURL *regUrl = [NSURL URLWithString:[Kriya apn_register_url_for:[NSString stringWithFormat:@"%@", deviceToken]]];
	[[Reachability sharedReachability] setHostName:[regUrl host]];
	[[Reachability sharedReachability] remoteHostStatus];
	//register this startup(device) if internet present
	if ([[Reachability sharedReachability] internetConnectionStatus]!=NotReachable) {
		ASIHTTPRequest *request = [[[ASIHTTPRequest alloc] initWithURL:regUrl] autorelease];
		[request setRequestMethod:@"POST"];
		[request setDelegate:self];
		[request setDidFinishSelector:@selector(apnProviderRegisterFinished:)];
		[request setDidFailSelector:@selector(apnProviderRegisterFailed:)];
		NSOperationQueue *queue = [[[NSOperationQueue alloc] init] autorelease];
		[queue addOperation:request];	
	}
	
}

//override this to ger your behavior after registering with provider
- (void)apnProviderRegisterFinished:(ASIHTTPRequest *)request
{
	DebugLog(@"Finished APN registering. %@", [request responseString]);
}

//override this to get your behavior after not registering with provider
- (void)apnProviderRegisterFailed:(ASIHTTPRequest *)request
{
	DebugLog(@"Failed register.");
}

#pragma mark startup count
- (void)startup 
{
	//ensure EDGE network comes on
	NSURL *startupUrl = [NSURL URLWithString:[Kriya startup_url]];
	[[Reachability sharedReachability] setHostName:[startupUrl host]];
	[[Reachability sharedReachability] remoteHostStatus];
	//rekord this startup if internet present
	if ([[Reachability sharedReachability] internetConnectionStatus]!=NotReachable) {
		ASIHTTPRequest *request = [[[ASIHTTPRequest alloc] initWithURL:startupUrl] autorelease];
		[request setRequestMethod:@"POST"];
		[request setDelegate:self];
		[request setDidFinishSelector:@selector(startupFinished:)];
		[request setDidFailSelector:@selector(startupFailed:)];
		NSOperationQueue *queue = [[[NSOperationQueue alloc] init] autorelease];
		[queue addOperation:request];	
	}
}

//override this to get your behavior after startingup with server
- (void)startupFinished:(ASIHTTPRequest *)request
{
	NSInteger startupz = [[request responseString] intValue];
	[[NSUserDefaults standardUserDefaults] setValue:[NSString stringWithFormat:@"Downloaded: %@", [Kriya howManyTimes:startupz]] forKey:STARTUPS];
	[[NSUserDefaults standardUserDefaults] synchronize];
}


//override this to get your behavior after not startingup with server
- (void)startupFailed:(ASIHTTPRequest *)request
{
	DebugLog(@"Failed startup.");
}

@end
