//
//  MessageViewController.m
//  MakeMoney
//
#import "MessageViewController.h"
#import "LittleArrowView.h"

@implementation MessageViewController
#pragma mark IIController overrides

+ (NSString*)transendFormat
{
	return @"{\"ii\":\"MessageView\", \"ions\":{\"message\":\"%@\", \"data\":%@, \"icon_url\":\"%@\", \"background_url\":\"%@\", \"noise_url\":\"%@\", \"yutub_url\":\"%@\"}, %@},";
}

- (void)functionalize {
	if (icon)
		[icon setHidden:YES];
}

- (void)stopFunctioning {
	DebugLog(@"MessageViewController#stopFunctioning");
	if ([[options valueForKey:@"yutub_url"] hasPrefix:@"http://"]) {
		DebugLog(@"REMOVING YUTUB %@", [options valueForKey:@"yutub_url"]);
		[notControls wwwClear];
	}
	if ([options valueForKey:@"icon_url"]) {
		[icon setHidden:YES];
	}
}

- (void)startFunctioning {
	if ([options valueForKey:@"icon_url"]) {
		UIImage *img = [Kriya imageWithUrl:[options valueForKey:@"icon_url"]];
		if (img) {
			if (icon) {
				[icon setImage:img];
			} else {
				icon = [[[LittleArrowView alloc] initWithFrame:CGRectMake(423, 10, 57, 57) image:img round:10.0 alpha:0.83] autorelease];
				[self.view addSubview:icon];				
			}
			[icon setHidden:NO];
		}
	} 
	
	if ([options valueForKey:@"background_url"]) {
		UIImage *img = [Kriya imageWithUrl:[options valueForKey:@"background_url"]];
		if (img) {
			[background setImage:img];
		}
	} else if ([options valueForKey:@"background"]) {
		[background setImage: [transender imageNamed:[options valueForKey:@"background"]]];
	}

	if ([[options valueForKey:@"noise_url"] hasPrefix:@"http://"]) {
		DebugLog(@"PLAYING NOISE %@", [options valueForKey:@"noise_url"]);
		[notControls playStop];
		[notControls playWithStreamUrl:[options valueForKey:@"noise_url"]];
	} else if ([[options valueForKey:@"yutub_url"] hasPrefix:@"http://"]) {
		DebugLog(@"PLAYING YUTUB %@", [options valueForKey:@"yutub_url"]);
		[notControls wwwWithYutubUrl:[options valueForKey:@"yutub_url"]];
	}
		
	NSString *msg = [options valueForKey:@"message"];
	if ([msg hasPrefix:@"hide"]) {
		//do not display message then
		[message setText:@""];
	} else {
		NSDictionary *data = [options valueForKey:@"data"];
		if (data) {
			[message setText:[data valueForKey:msg]];		
		} else {
			[message setText:msg];
		}
	}
	
	DebugLog(@"MessageViewController#startFunctioning");
}


@end
