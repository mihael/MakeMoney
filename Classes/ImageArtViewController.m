//
//  ImageArtViewController.m
//  MakeMoney
//
#import "ImageArtViewController.h"

@implementation ImageArtViewController
#pragma mark IIController overrides
- (void)functionalize {
}

- (void)stopFunctioning {
}

- (void)startFunctioning {
	if ([options valueForKey:@"background_url"]) {
		UIImage *img = [Kriya imageWithUrl:[options valueForKey:@"background_url"]];
		if (img) {
			[background setImage:img];
		}
	} else if ([options valueForKey:@"background"]) {
		DebugLog(@"IMAGE ART");
		[background setImage: [transender imageNamed:[options valueForKey:@"background"]]];
	}

	NSString *msg = [options valueForKey:@"message"];
	if (msg) {
		[message setText:msg];
	}
}

@end
