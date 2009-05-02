//
//  FecherViewController.m
//  MakeMoney
//
#import "FecherViewController.h"
#import "IIWWW.h"
#import "JSON.h"

@implementation FecherViewController
@synthesize button, background;

- (IBAction)buttonTouched:(id)sender
{
	[indica startAnimating];
	[button setHidden:YES];
	[www fech];	
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}


- (void)dealloc {
	[www release];
	www = nil;
    [super dealloc];
}

#pragma mark IIWWWDelegate
- (void)notFeched:(NSString*)err
{
	DebugLog(@"FecherViewController#notFeched %@ : %@", [self.options valueForKey:@"url"], err);
	[indica stopAnimating];
	[button setHidden:NO];
	
}

- (void)feched:(NSMutableArray*)listing
{
	[indica stopAnimating];
	//[self.transender spot]; //rewind memory spots

	//inventing remote coding here - listing.json is a new way to program iphone and ipod apps
	//[self.transender rememberMemories:listing];
	[self.transender putMemories:listing];
	//prepare next page fecher to add last in listing - so we have next page
	int page = [[options valueForKey:@"page"] intValue] + 1;	
	NSMutableDictionary *repaged_options = [NSMutableDictionary dictionaryWithDictionary:options];
	[repaged_options setValue:[NSString stringWithFormat:@"%i",page] forKey:@"page"];	
	[self.transender addMemorieWithString:[NSString stringWithFormat:@"{\"ii\":\"FecherView\", \"ions\":%@, \"ior\":%@}", [repaged_options JSONFragment], [behavior JSONFragment]]];

	//insert current fecher - so we have previous also
	//[self.transender addMemorieWithString:[NSString stringWithFormat:@"{\"name\":\"FecherView\", \"options\":%@, \"behavior\":%@}", [options JSONFragment], [behavior JSONFragment]]];

	if (self.notControls)
		[self.notControls lightDown];
	[self.transender transendNow];
}

#pragma mark IIController
- (void)functionalize {
	//if (www)
		[www release];
	www = [[IIWWW alloc] initWithOptions:options];
	//[www setProgressDelegate:progress];
	[www setDelegate:self];
	if ([options valueForKey:@"background"])
		[self.background setImage:[self.transender imageNamed:[options valueForKey:@"background"]]];
	if ([options valueForKey:@"button_title"])
		[self.button setTitle:[options valueForKey:@"button_title"] forState:UIControlStateNormal];	
//only SDK 3.0
	button.titleLabel.lineBreakMode = UILineBreakModeWordWrap;
	button.titleLabel.textAlignment = UITextAlignmentCenter;

//SDK <3.0
//	button.lineBreakMode = UILineBreakModeWordWrap;
}

- (void)stopFunctioning {
	//DebugLog(@"#stopFunctioning");
}

- (void)startFunctioning {
	//DebugLog(@"#startFunctioning");
	[button setHidden:NO];
}

@end
