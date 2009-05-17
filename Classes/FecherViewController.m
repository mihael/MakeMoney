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

- (void)feched:(id)information
{
	[indica stopAnimating];
	//[self.transender spot]; //rewind memory spots
	//[self.transender rememberMemories:listing]; //replaces transender mem
	if ([options valueForKey:@"message"]) { //delete self from program, if this is an automatic fech
		[self.transender trimMemories]; //trim all that follows
		[self.transender vipeCurrentMemorie]; //vipe self
	}
	
	[self.transender putMemories:information]; //inserts into transender mem
	
	if ([options valueForKey:@"page"]) { //program says we want automatic repage
		NSUInteger page = [[options valueForKey:@"page"] intValue];
		int page_plus = [[options valueForKey:@"page_plus"] intValue];
		if (page_plus<=0) {
			page_plus = 1;
		}
		NSUInteger nextPage = page + page_plus;	
		NSMutableDictionary *repaged_options = [NSMutableDictionary dictionaryWithDictionary:options];
		[repaged_options setValue:[NSString stringWithFormat:@"%i",nextPage] forKey:@"page"];	
		
		[self.transender addMemorieWithString:[NSString stringWithFormat:@"{\"ii\":\"FecherView\", \"ions\":%@, \"ior\":%@}", [repaged_options JSONFragment], [behavior JSONFragment]]];
	}
	
	if (self.notControls)
		[self.notControls lightDown];

	//do not wait for timer, since data is already feched
	[self.transender transend];
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
	if ([options valueForKey:@"button_title"]) {
		[self.button setTitle:[options valueForKey:@"button_title"] forState:UIControlStateNormal];	
		[self.button setEnabled:YES];
	} else if ([options valueForKey:@"message"]) {
		[self.button setTitle:[options valueForKey:@"message"] forState:UIControlStateNormal];	
		[self.button setEnabled:NO];
	} else {
		[self.button setTitle:@"+fech" forState:UIControlStateNormal];
		[self.button setEnabled:YES];
	}
	button.titleLabel.lineBreakMode = UILineBreakModeWordWrap;
	button.titleLabel.textAlignment = UITextAlignmentCenter;
}

- (void)stopFunctioning {
	//DebugLog(@"#stopFunctioning");
}

- (void)startFunctioning {
	//DebugLog(@"#startFunctioning");
	[button setHidden:NO];
	[www fech];

}

@end
