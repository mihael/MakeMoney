//
//  StreamingPlayerViewController.m
//
#import "IIController.h"
#import "StreamingPlayerViewController.h"
#import "AudioStreamer.h"
#import <QuartzCore/CoreAnimation.h>

@implementation StreamingPlayerViewController
@synthesize background;

- (void)viewDidLoad
{
	[super viewDidLoad];
	[self playWithStreamURL:[self.options valueForKey:@"url"]];
	[background setImage:[UIImage imageNamed:[self.options valueForKey:@"image"]]];
}


- (void)playWithStreamURL:(NSString*)url
{
	if (!streamer)
	{
		
			NSString *escapedValue =
				[(NSString *)CFURLCreateStringByAddingPercentEscapes(
					nil,
					(CFStringRef)url,
					NULL,
					NULL,
					kCFStringEncodingUTF8)
				autorelease];

		NSURL *url = [NSURL URLWithString:escapedValue];
		streamer = [[AudioStreamer alloc] initWithURL:url];
		[streamer
			addObserver:self
			forKeyPath:@"isPlaying"
			options:0
			context:nil];
		//[streamer start];
	} else	{
		[streamer stop];
	}
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
	change:(NSDictionary *)change context:(void *)context
{
	if ([keyPath isEqual:@"isPlaying"])
	{
		NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

		if ([(AudioStreamer *)object isPlaying]) {
			//do nothing while playing stream
		} else	{ //release otherways?
			[streamer removeObserver:self forKeyPath:@"isPlaying"];
			[streamer release];
			streamer = nil;
		}

		[pool release];
		return;
	}
	
	[super observeValueForKeyPath:keyPath ofObject:object change:change
		context:context];
}


#pragma mark IIController overrides
- (void)stopFunctioning {
	[streamer stop];
	NSLog(@"StreamingPlayerViewController#stopFunctioning");
}
- (void)startFunctioning {
	[streamer start];
	NSLog(@"StreamingPlayerViewController#startFunctioning");
}


@end
