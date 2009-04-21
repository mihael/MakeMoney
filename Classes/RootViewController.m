//
//  RootViewController.m
//  MakeMoney
//
#import "RootViewController.h"
#import "FlipsideViewController.h"
#import "IITransenderViewController.h"
#import "IINotControls.h"
#import "iAlert.h"
#import "MakeMoneyAppDelegate.h"

@implementation RootViewController

@synthesize notControls, flipsideNavigationBar, mainViewController, flipsideViewController;

- (void)loadView {
	UIView *primaryView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
	primaryView.backgroundColor = [UIColor clearColor];
	// Start in landscape orientation, and stay that way
	UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
	if (orientation == UIInterfaceOrientationPortrait) {
		CGAffineTransform transform = primaryView.transform;
		// Use the status bar frame to determine the center point of the window's content area.
		CGRect statusBarFrame = [[UIApplication sharedApplication] statusBarFrame];
		CGRect bounds = CGRectMake(0, 0, statusBarFrame.size.height, statusBarFrame.origin.x);
		CGPoint center = CGPointMake(60.0, bounds.size.height / 2.0);
		// Set the center point of the view to the center point of the window's content area.
		primaryView.center = center;
		// Rotate the view 90 degrees around its new center point.
		transform = CGAffineTransformRotate(transform, (M_PI / 2.0));
		primaryView.transform = transform;
	}   
	self.view = primaryView;
	[primaryView release]; 
}

- (void)viewDidLoad {
    [super viewDidLoad];

	notControls = [[[IINotControls alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)] retain];
	[notControls setBackLight:[UIImage imageNamed:@"backlight.png"] withAlpha:1.0];
	[self.view addSubview:notControls];
	
	IITransenderViewController *viewController = [[IITransenderViewController alloc] initWithTransendsListing:@"listing" andStage:[[MakeMoneyAppDelegate app] stage]];
    self.mainViewController = viewController;
    [viewController release];    
	[notControls setDelegate:self.mainViewController];
	[self.mainViewController setNotControls:notControls];
	[self.mainViewController setDelegate:self];

    [self.view insertSubview:mainViewController.view belowSubview:notControls];

	[[self.mainViewController transender] reVibe:[[[[MakeMoneyAppDelegate app] stage] valueForKey:@"vibe"] floatValue]];
	
	if ([[[[MakeMoneyAppDelegate app] stage] valueForKey:@"save_current_spot"] boolValue]) {
		[[self.mainViewController transender] rememberSpot];
	} else {
		[[self.mainViewController transender] transend];
	}

}


- (void)loadFlipsideViewController {
    FlipsideViewController *viewController = [[FlipsideViewController alloc] initWithNibName:@"FlipsideView" bundle:nil];
    self.flipsideViewController = viewController;
    [viewController release];
}

//this not currently used
- (void)toggleView {    
	if (flipsideViewController == nil) {
        [self loadFlipsideViewController];
    }

	flipsideViewController.view.frame = [Kriya appViewRect]; //for rotation
	mainViewController.view.frame = [Kriya appViewRect]; //for rotation
	
    UIView *mainView = mainViewController.view;
    UIView *flipsideView = flipsideViewController.view;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:1];
    [UIView setAnimationTransition:([mainView superview] ? UIViewAnimationTransitionFlipFromRight : UIViewAnimationTransitionFlipFromLeft) forView:self.view cache:YES];
    
    if ([mainView superview] != nil) {
        [flipsideViewController viewWillAppear:YES];
        [mainViewController viewWillDisappear:YES];
        [mainView removeFromSuperview];
        //[button removeFromSuperview];
        [self.view addSubview:flipsideView];
        //[self.view insertSubview:button aboveSubview:flipsideView];
		//[button setHidden:NO];
		[mainViewController viewDidDisappear:YES];
        [flipsideViewController viewDidAppear:YES];
    } else {
        [mainViewController viewWillAppear:YES];
        [flipsideViewController viewWillDisappear:YES];
        [flipsideView removeFromSuperview];
        [self.view addSubview:mainView];
        //[self.view insertSubview:button aboveSubview:mainViewController.view];
		//[mainViewController hideNotControls];
        [flipsideViewController viewDidDisappear:YES];
        [mainViewController viewDidAppear:YES];
    }
    [UIView commitAnimations];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	//widescreen
    return ( (interfaceOrientation == UIInterfaceOrientationLandscapeLeft) || (interfaceOrientation == UIInterfaceOrientationLandscapeRight));//(interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
	[[iAlert instance] alert:@"Received Memory Warning in RootViewController" withMessage:@"Good luck!"];
	DebugLog(@"RootViewController# Too many memories.");
}

- (void)dealloc {
	[notControls release];
    [mainViewController release];
    [flipsideViewController release];
    [super dealloc];
}

#pragma mark IITransenderViewControllerDelegate
- (void)transending {
	[notControls lightDown];
}
- (void)meditating {
	[notControls lightUp];
}

- (void)rotateView270:(UIView*)w
{
	CGAffineTransform transform = w.transform;
	
	// Rotate the view 90 degrees. 
	transform = CGAffineTransformRotate(transform, (3*M_PI / 2.0));
	
    UIScreen *screen = [UIScreen mainScreen];
    // Translate the view to the center of the screen
    transform = CGAffineTransformTranslate(transform, 
										   ((screen.bounds.size.height) - (w.bounds.size.height))/2, 
										   0);
	w.transform = transform;
}

- (void)moviesStart {
/*
    NSArray *windows = [[UIApplication sharedApplication] windows];
    // Locate the movie player window
    UIWindow *moviePlayerWindow = [windows objectAtIndex:1];
    // Add our overlay view to the movie player's subviews so it’s 
    // displayed above it.
	[notControls removeFromSuperview];
	[moviePlayerWindow addSubview:notControls];
//	[self rotateView270:notControls];
*/
}

- (void)moviesEnd {
//	[self.view addSubview:notControls];	
}
@end
