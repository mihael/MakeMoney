//
//  MessageViewController.m
//  MakeMoney
//
#import "MessageViewController.h"

@implementation MessageViewController

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	if ([options valueForKey:@"image"])
		[background setImage:[UIImage imageNamed:[options valueForKey:@"image"]]];
	if ([options valueForKey:@"message"])
		[message setText:[options valueForKey:@"message"]];	
	message.font = [UIFont fontWithName:@"Helvetica-Bold" size:23];
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	[self.transender meditate];
	[self.notControls lightUp];
	[[iAlert instance] alert:@"Received Memory Warning in MessageViewController" withMessage:@"Good luck!"];
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

- (void)dealloc {
    [super dealloc];
}

- (void)loadMessage 
{
}

#pragma mark IIController overrides
- (void)stopFunctioning {
	DebugLog(@"RemoteImageViewController#stopFunctioning");
}
- (void)startFunctioning {
	DebugLog(@"RemoteImageViewController#startFunctioning");
}


@end
