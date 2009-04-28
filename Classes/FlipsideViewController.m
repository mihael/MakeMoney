//
//  FlipsideViewController.m
//  MakeMoney
//
#import "ASIHTTPRequest.h"
#import "ASINetworkQueue.h"
#import "FlipsideViewController.h"
#import "MakeMoneyAppDelegate.h"
#import "iAlert.h"
#import "Reachability.h"

@implementation FlipsideViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //self.view.backgroundColor = [UIColor viewFlipsideBackgroundColor];     
	networkQueue = [[ASINetworkQueue alloc] init];	
	if ([[Reachability sharedReachability] internetConnectionStatus]==NotReachable) {
		version.text = @"Please connect device to internet. Thanks.";
	} else {
		[self fetchStartupCount];	
	}
}

- (void)dealloc {
	[networkQueue release];
    [super dealloc];
}

#pragma mark Startups
- (void)fetchStartupCount
{
	[progressIndicator setHidden:NO];

	[networkQueue cancelAllOperations];
	[networkQueue setDownloadProgressDelegate:progressIndicator];
	[networkQueue setRequestDidFinishSelector:@selector(showStartupCount:)];
	[networkQueue setRequestDidFailSelector:@selector(showStartupCount:)];
	[networkQueue setShowAccurateProgress:YES];
	[networkQueue setDelegate:self];

	//testing like this
	//NSString * url = [NSString stringWithFormat:@"http://localhost:3000/brickboxes/%@/%@", MANTRA, [Kriya deviceId]];	
	//NSString * url = [NSString stringWithFormat:@"http://kitschmaster.com/brickboxes/%@/%@", MANTRA, [Kriya deviceId]];
	
	ASIHTTPRequest *request = [[[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:[Kriya brickbox_url]]] autorelease];
	[request setRequestMethod:@"POST"];
	[networkQueue addOperation:request];
	[networkQueue go];
	
	[web loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://kitschmaster.com/kiches/%@", APP_URL]]]];
	
}

- (void)showStartupCount:(ASIHTTPRequest *)request
{
	if (request) {
		NSInteger startupz = [[request responseString] intValue];
		[self showStartups:[Kriya howManyTimes:startupz] andMadeMoney:[NSString stringWithFormat:@"%1.2f", startupz * PRICE * IRS]];	
	}
}

- (void)showStartups:(NSString*)s andMadeMoney:(NSString*)m {
	version.text = [NSString stringWithFormat:@"Version %@", [MakeMoneyAppDelegate version]];
	startups.text = [NSString stringWithFormat:@"%@ was purchased %@.", APP_TITLE, s];
	moneymade.text = [NSString stringWithFormat:@"%@ made $%@.", APP_TITLE, m];
	startups.hidden = NO;
	moneymade.hidden = NO;
	progressIndicator.hidden = YES;
	app_runs.text = [NSString stringWithFormat:@"You run %@ %@.", APP_TITLE, [Kriya howManyTimes:[Kriya appRunCount]]];
	app_runs.hidden = NO;
}

#pragma mark web Indica
- (void) startLoading {
	[indica startAnimating];
	//[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void) stopLoading {
	[indica stopAnimating];
	//[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

#pragma mark UIWebView
- (void)webViewDidFinishLoad:(UIWebView *)webView {
	[self stopLoading];
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
	[self startLoading];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
	[self stopLoading];
	switch (error.code) {
		case NSURLErrorCannotFindHost:
			[[iAlert instance] alert:@"Web" withMessage:@"Host not found."];
			break;
		case NSURLErrorTimedOut:
			[[iAlert instance] alert:@"Web" withMessage:@"Timed out."];
			break;
		default:
			DebugLog(@"WebViewController#didFailWithError %@ code %i ", [error localizedDescription], error.code);			
			break;
	}//hide all other errors for now :) and be happy	
}

- (void)webViewClearToBlack {
	[web loadHTMLString:@"<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Transitional//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd\"><html xmlns=\"http://www.w3.org/1999/xhtml\" xml:lang=\"en\" lang=\"en\"><head><title></title></head><body style=\"background:black;\"></body></html>" baseURL: [NSURL URLWithString:@"http://kitschmaster.com"]];
}

- (void)webViewClearToWhite {
	[web loadHTMLString:@"<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Transitional//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd\"><html xmlns=\"http://www.w3.org/1999/xhtml\" xml:lang=\"en\" lang=\"en\"><head><title></title></head><body style=\"background:white;\"></body></html>" baseURL: [NSURL URLWithString:@"http://kitschmaster.com"]];
}

#pragma mark IIController
- (void)functionalize {
}
- (void)startFunctioning {
}
- (void)stopFunctioning {
}


@end
