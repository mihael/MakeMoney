//
//  MoonTimeViewController.m
//  MakeMoney
//
//  Created by Mihael on 3/31/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//
#import "ASIHTTPRequest.h"
#import "MoonTimeViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "MakeMoneyAppDelegate.h"
#define kMoonAnimationKey @"moonViewAnimation"

@implementation MoonTimeViewController
@synthesize moonView;
/*
// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	networkQueue = [[ASINetworkQueue alloc] init];	
	[self.moonView setHidden:YES];
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}


- (void)dealloc {
	[networkQueue release];
    [super dealloc];
}

#pragma mark where is this moon 
- (void)takeTheMoon 
{
	[indica setHidden:NO];
	[indica startAnimating];
	
	[networkQueue cancelAllOperations];
	[networkQueue setRequestDidFinishSelector:@selector(viewMoon:)];
	[networkQueue setRequestDidFailSelector:@selector(viewMoon:)];
	[networkQueue setDelegate:self];
	
	ASIHTTPRequest *request = [[[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:@"http://tycho.usno.navy.mil/cgi-bin/phase.gif"]] autorelease];
	[request setRequestMethod:@"GET"];
	[networkQueue addOperation:request];
	[networkQueue go];
}

- (void)viewMoon:(ASIHTTPRequest *)request 
{
	if (request) {
		NSLog(@"moon arrived.");
		[self.moonView setHidden:NO];
		[self.moonView setImage:[UIImage imageWithData:[request responseData]]];
		[self animateMoon];
	} else {
		[self fakeMoon];
	}
	[indica stopAnimating];
}

- (void)fakeMoon
{
	NSLog(@"Should show a fake moon?");
}

- (void)animateMoon
{
	CATransition *animation = [CATransition animation];
	[animation setType:kCATransitionReveal];
	[animation setDuration:3];
	[animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
//	[animation setSubtype:kCATransitionFromTop];
	[[self.moonView layer] addAnimation:animation forKey:kMoonAnimationKey];
}
#pragma mark IIController overrides
- (void)functionalize {
}
- (void)stopFunctioning {
	NSLog(@"MoonTimeViewController#stopFunctioning");
}
- (void)startFunctioning {
	[self takeTheMoon];
	NSLog(@"MoonTimeViewController#startFunctioning");
}
@end
