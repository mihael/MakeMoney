//
//  FechSomeViewController.m
//  MakeMoney
//
//  Created by mihael on 4/18/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "FechSomeViewController.h"
#import "IIWWW.h"

@implementation FechSomeViewController

- (IBAction)buttonTouched:(id)sender
{
	[progress setHidden:NO];
	[www fech];	
}

- (void)notFeched:(NSString*)err
{
}

- (void)feched:(NSMutableArray*)listing
{
	[self.transender spot]; //rewind memory spot

	[self.transender rememberMemories:listing];
	//(TODO)	[self.transender addMemories:[request responseString]];
	[self.transender transend];
}

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	www = [[IIWWW alloc] initWithOptions:self.options];
	[www setProgressDelegate:progress];
	[www setDelegate:self];
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
	[www release];
    [super dealloc];
}


@end
