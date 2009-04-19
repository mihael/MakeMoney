//
//  RemoteImageViewController.m
//  MakeMoney
//
#import "RemoteImageViewController.h"
#import <QuartzCore/QuartzCore.h>
#define kImageAnimationKey @"imageViewAnimation"


@implementation RemoteImageViewController
@synthesize imageView, indica;

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
	[self loadImage];

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
    [super dealloc];
}

#pragma mark AssetDownloadDelegate
- (void)downloaded:(id)a 
{	
	[self showImage:[a image]];
	NSLog(@"downloaded %@", a);
}

- (void)notDownloaded:(id)a 
{
	NSLog(@"Image not downloaded...");
}

#pragma mark load
- (void)showImage:(UIImage*)img
{
	[indica stopAnimating];
	[indica setHidden:YES];
	[self.imageView setHidden:NO];
	[self.imageView setImage:img];
	[self animateImage];
}

- (void)loadImage 
{
	[indica setHidden:NO];
	[indica startAnimating];
	UIImage *img = [[AssetRepository one] imageForURL:[self.options valueForKey:@"url"] notify:self];
	if (img) {
		[self showImage:img];
	}
	
}

- (void)fakeImage
{
	NSLog(@"Should show a fake image?");
}

- (void)animateImage
{
	CATransition *animation = [CATransition animation];
	[animation setType:kCATransitionReveal];
	[animation setDuration:3];
	[animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
	//	[animation setSubtype:kCATransitionFromTop];
	//[[self.imageView layer] addAnimation:animation forKey:kImageAnimationKey];
}

#pragma mark IIController overrides
- (void)stopFunctioning {
	NSLog(@"RemoteImageViewController#stopFunctioning");
}
- (void)startFunctioning {
	NSLog(@"RemoteImageViewController#startFunctioning");
}


@end
