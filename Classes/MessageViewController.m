//
//  MessageViewController.m
//  MakeMoney
//
#import "MessageViewController.h"
#import "LittleArrowView.h"

@implementation MessageViewController
#pragma mark IIController overrides
- (void)functionalize {
	message.lineBreakMode = UILineBreakModeWordWrap;
	message.numberOfLines = 0;
	
	if ([options valueForKey:@"background"])
		[background setImage: [transender imageNamed:[options valueForKey:@"background"]]];
	NSString *msg = [options valueForKey:@"message"];
	if (msg) {
		NSDictionary *data = [options valueForKey:@"data"];
		if (data) {
			[message setText:[data valueForKey:msg]];		
		} else {
			[message setText:msg];
		}
	}
}

- (void)stopFunctioning {
	DebugLog(@"MessageViewController#stopFunctioning");
}
- (void)startFunctioning {
	if ([options valueForKey:@"icon_url"]) {
		UIImage *img = [Kriya imageWithUrl:[options valueForKey:@"icon_url"]];
		if (img) {
			if (icon) {
				[icon setImage:img];
			} else {
				icon = [[[LittleArrowView alloc] initWithFrame:CGRectMake(442, 10, 38, 38) image:img round:10.0 alpha:0.83] autorelease];
				[self.view addSubview:icon];				
			}

		}
	}
	
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
