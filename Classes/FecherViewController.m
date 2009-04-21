//
//  FecherViewController.m
//  MakeMoney
//
#import "FecherViewController.h"
#import "IIWWW.h"

@implementation FecherViewController

- (IBAction)buttonTouched:(id)sender
{
	[indica setHidden:NO];
	[button setHidden:YES];
	[www fech];	
}

- (void)notFeched:(NSString*)err
{
	DebugLog(@"FecherViewController#notFeched %@ : %@", [self.options valueForKey:@"url"], err);

}

- (void)feched:(NSMutableArray*)listing
{
	[indica setHidden:YES];
	DebugLog(@"FecherViewController#feched %@", listing);
	[self.transender spot]; //rewind memory spot

	[self.transender rememberMemories:listing];
	//(TODO)	[self.transender addMemories:[request responseString]];
	if (self.notControls)
		[self.notControls lightDown];
	[self.transender transendNow];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	www = [[IIWWW alloc] initWithOptions:self.options];
	//[www setProgressDelegate:progress];
	[www setDelegate:self];
	
	if ([options valueForKey:@"background"])
		[background setImage:[UIImage imageNamed:[options valueForKey:@"background"]]];
	if ([options valueForKey:@"button_title"])
		[button setTitle:[options valueForKey:@"button_title"] forState:UIControlStateNormal];	
}

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
