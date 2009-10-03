//
//  MessageViewController.m
//  MakeMoney
//
#import "MessageViewController.h"
#import "LittleArrowView.h"
#import "iContentView.h"

@implementation MessageViewController
#pragma mark IIController overrides

+ (NSString*)transendFormat
{
	return @"{\"ii\":\"MessageView\", \"ions\":{\"message\":\"%@\", \"data\":%@, \"clickable\":\"true\", \"icon_url\":\"%@\", \"background_url\":\"%@\", \"noise_url\":\"%@\", \"yutub_url\":\"%@\"}, %@},";
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:iContentViewURLNotification object:nil];
	[content release];
	[super dealloc];
}

- (void)functionalize {
	if (icon)
		[icon setHidden:YES];
	CGRect rect = KriyaFrame();
	if (!content) {
		content = [[iContentView alloc] initWithFrame:CGRectMake(kPadding, kPadding, rect.size.width-2*kPadding, rect.size.height-2*kPadding)] ;
		[content setFont:[UIFont systemFontOfSize:25]];
		[content setBackgroundColor:[UIColor clearColor]];
		[content setTextColor:[UIColor whiteColor]];
		[content setNumberOfLines:0];
		[content setLinksEnabled:YES];		
		[self.view addSubview:content];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleClickNotification:) name:iContentViewURLNotification object:nil];

	}
}

- (void)stopFunctioning {
	if ([[options valueForKey:@"yutub_url"] hasPrefix:@"http://"]) {
		DebugLog(@"REMOVING YUTUB %@", [options valueForKey:@"yutub_url"]);
		[notControls wwwClear];
	}
	if ([options valueForKey:@"icon_url"]) {
		[icon setHidden:YES];
	}
	DebugLog(@"#stopFunctioning");
}

- (void)startFunctioning {
	if ([options valueForKey:@"icon_url"]) {
		UIImage *img = [Kriya imageWithUrl:[options valueForKey:@"icon_url"] feches:YES];
		if (img) {
			if (icon) {
				[icon setImage:img];
			} else {
				icon = [[[LittleArrowView alloc] initWithFrame:CGRectMake([Kriya orientedFrame].size.width - 57, 10, 57, 57) image:img round:10.0 alpha:0.83] autorelease];
				[self.view addSubview:icon];				
			}
			[icon setHidden:NO];
		}
	} 
	
	if ([options valueForKey:@"background_url"]) {
		UIImage *img = [Kriya imageWithUrl:[options valueForKey:@"background_url"] feches:YES];
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
		if ([options valueForKey:@"clickable"]) {
			[message setHidden:YES];
			[content setHidden:NO];
			if (data) {
				[content setText:[data valueForKey:msg]];		
			} else {
				DebugLog(@"SETTING CONTENT to %@", msg);
				[content setText:msg];
			}
		} else {
			[message setHidden:NO];
			[content setHidden:YES];
			if (data) {
				[message setText:[data valueForKey:msg]];		
			} else {
				[message setText:msg];
			}
		}
	}
	[self layout:[Kriya orientedFrame]];
	DebugLog(@"#startFunctioning");
}

- (void)layout:(CGRect)rect
{
	[self.view setFrame:rect];
	[background setFrame:rect];
	[icon setFrame:CGRectMake(rect.size.width - 57, 10, 57, 57)];
	[message setFrame:CGRectMake(kPadding, kPadding, rect.size.width-2*kPadding, rect.size.height-2*kPadding)];
	[content setFrame:CGRectMake(kPadding, kPadding, rect.size.width-2*kPadding, rect.size.height-2*kPadding)];
	
}

- (void)handleClickNotification:(NSNotification*)notification
{
	DebugLog(@"Clicked on %@", [notification object]);
	NSString *url = [notification object];
	
	if ([url hasPrefix:@"http://"]) {
		//[notControls wwwWithUrl:url];
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
	}
}
@end
