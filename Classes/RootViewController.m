//
//  RootViewController.m
//  MakeMoney
//
#import "RootViewController.h"
#import "IITransenderViewController.h"
#import "IINotControls.h"
#import "iAlert.h"
#import "MakeMoneyAppDelegate.h"

@implementation RootViewController

@synthesize notControls, transenderViewController;

- (void)loadView {
	UIView *primaryView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
    primaryView.backgroundColor = [UIColor clearColor];
	
    // Start in landscape orientation, and stay that way
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (orientation == UIInterfaceOrientationLandscapeRight) 
    {
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

	notControls = [[[IINotControls alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) withOptions:[[MakeMoneyAppDelegate app] stage]] retain];
	[notControls setBackLight:[UIImage imageNamed:@"backlight.png"] withAlpha:1.0];
	[notControls setCanOpen:[[[[MakeMoneyAppDelegate app] stage] valueForKey:@"button_opens_not_controls"] boolValue]];
	[self.view addSubview:notControls];
	[notControls setNotController:self];
	
	self.transenderViewController = [[IITransenderViewController alloc] initWithTransenderProgram:[[[MakeMoneyAppDelegate app] stage] valueForKey:@"program"] andStage:[[MakeMoneyAppDelegate app] stage]];
	[notControls setDelegate:transenderViewController];
	[transenderViewController setNotControls:notControls];
	[transenderViewController setDelegate:self];

    [self.view insertSubview:transenderViewController.view belowSubview:notControls];

	[[transenderViewController transender] reVibe:[[[[MakeMoneyAppDelegate app] stage] valueForKey:@"vibe"] floatValue]];
	
	//TODO - support save_current_program - reload program from cache and remember spot if any
	if ([[[[MakeMoneyAppDelegate app] stage] valueForKey:@"save_current_spot"] boolValue]) {
		[[transenderViewController transender] rememberSpot];
	} else {
		[[transenderViewController transender] transend];
	}
}

//makemoney always runs in widescreen
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return ( (interfaceOrientation == UIInterfaceOrientationLandscapeLeft) || (interfaceOrientation == UIInterfaceOrientationLandscapeRight));//(interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
	[[iAlert instance] alert:@"Received Memory Warning in RootViewController" withMessage:@"Good luck!"];
	DebugLog(@"RootViewController# Too many memories.");
}

- (void)dealloc {
	[notControls release];
    [transenderViewController release];
    [super dealloc];
}

#pragma mark IITransenderViewControllerDelegate
- (void)transending {
	[notControls lightDown];
}
- (void)meditating {
	[notControls lightUp];
}

#pragma mark experiments
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
  TODO put the movie under the notControls view
 
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
