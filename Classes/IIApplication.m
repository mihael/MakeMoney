//
//  IIApplication.m
//  MakeMoney
//
#import "IIApplication.h"
#import "Reachability.h"
#import "ASIHTTPRequest.h"

@implementation IIApplication

#pragma mark registration and startup count
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

- (void)startupFinished:(ASIHTTPRequest *)request
{
	NSInteger startupz = [[request responseString] intValue];
	[[NSUserDefaults standardUserDefaults] setValue:[NSString stringWithFormat:@"Downloaded: %@", [Kriya howManyTimes:startupz]] forKey:STARTUPS];
	[[NSUserDefaults standardUserDefaults] synchronize];
}


- (void)startupFailed:(ASIHTTPRequest *)request
{
	DebugLog(@"Failed startup.");
}

@end
