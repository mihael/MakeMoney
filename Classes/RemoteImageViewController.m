//
//  RemoteImageViewController.m
//  MakeMoney
//
#import "RemoteImageViewController.h"
#import <QuartzCore/QuartzCore.h>
#define kImageAnimationKey @"imageViewAnimation"


@implementation RemoteImageViewController
@synthesize imageView, indica, image;

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	[self.transender meditate];
	[self.notControls lightUp];
	[[iAlert instance] alert:@"Received Memory Warning in RemoteImageViewController" withMessage:@"Good luck!"];
}

- (void)viewDidUnload {
	DebugLog(@"RemoteImageViewController#viewDidUnload");
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
	DebugLog(@"RemoteImageViewController#downloaded %@", a);
}

- (void)notDownloaded:(id)a 
{
	DebugLog(@"RemoteImageViewController#Image not downloaded...");
}

#pragma mark load
- (void)showImage:(UIImage*)img
{
	[indica stopAnimating];
	[self setImage:img];
	[self.imageView setHidden:NO];
	[self.imageView setImage:image];
}

- (void)loadRemoteImage 
{
	UIImage *img = [[AssetRepository one] imageForURL:[self.options valueForKey:@"url"] notify:self];
	if (img) {
		[self showImage:img];
		[img release];
	}
}

- (void)fakeImage
{
	DebugLog(@"Should show a fake image?");
}

#pragma mark IIController overrides
- (void)functionalize {
}

- (void)stopFunctioning {
	if (image) 
		[image release];
	DebugLog(@"RemoteImageViewController#stopFunctioning");
}
- (void)startFunctioning {
	[self loadRemoteImage];
	DebugLog(@"RemoteImageViewController#startFunctioning");
}


@end
