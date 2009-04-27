//
//  MessageViewController.m
//  MakeMoney
//
#import "MessageViewController.h"

@implementation MessageViewController
#pragma mark IIController overrides
- (void)functionalize {
	message.lineBreakMode = UILineBreakModeWordWrap;
	message.numberOfLines = 0;
	
	if ([options valueForKey:@"background"])
		[background setImage: [transender imageNamed:[options valueForKey:@"background"]]];//[[UIImage alloc] initWithContentsOfFile:[options valueForKey:@"image"]]];
	if ([options valueForKey:@"message"])
		[message setText:[options valueForKey:@"message"]];		
}

- (void)stopFunctioning {
	DebugLog(@"MessageViewController#stopFunctioning");
}
- (void)startFunctioning {
	if ([options valueForKey:@"background_url"]) {
		[indica startAnimating];
		UIImage *img = [Kriya imageWithUrl:[options valueForKey:@"background_url"]];
		if (img) {
			if ([img size].width > background.frame.size.width && [img size].height > background.frame.size.height)
				[background setContentMode:UIViewContentModeCenter];
			[background setImage:img];
		}
		[indica stopAnimating];
	}
	DebugLog(@"MessageViewController#startFunctioning");
}


@end
