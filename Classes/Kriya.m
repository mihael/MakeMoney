#import "Kriya.h"
#import "JSON.h"
#import "MakeMoneyAppDelegate.h"

@implementation Kriya
+ (CGRect)appViewRect {
	CGRect screen = [[UIScreen mainScreen] applicationFrame];
	CGFloat c_w = screen.size.height;
	CGFloat c_h = screen.size.width;	
	if ([[[MakeMoneyAppDelegate app] rootViewController] interfaceOrientation] == UIInterfaceOrientationPortrait) {
		c_w = screen.size.width;
		c_h = screen.size.height; 
	}	
	return CGRectMake(0.0, 0.0, c_w, c_h);
}

+ (NSInteger)appRunCount {
	if (![[NSUserDefaults standardUserDefaults] objectForKey:RUNS]){
		NSLog(@"Om Om Om Kriya Babaji Namah Om Om Om");
		[[NSUserDefaults standardUserDefaults] setInteger:0 forKey:RUNS];
		[[NSUserDefaults standardUserDefaults] synchronize];
	}
	return [[NSUserDefaults standardUserDefaults] integerForKey:RUNS];	
}

+ (void)incrementAppRunCount {
	[[NSUserDefaults standardUserDefaults] setInteger:([Kriya appRunCount] + 1) forKey:RUNS];
	[[NSUserDefaults standardUserDefaults] synchronize];	
}

+ (void)prayInCode {
	NSLog(@"OM NAMAH SHIVAYA %@ OM KRIYA BABAJI NAMAH OM", PRAYER);
}

+ (NSString*)deviceId {
	return [[UIDevice currentDevice] uniqueIdentifier];
}

+ (NSString*)brickbox_url {
	return [NSString stringWithFormat:@"http://kitschmaster.com/brickboxes/%@/%@", APP_TITLE, [Kriya deviceId]];
}

+ (NSString*)support_url {
	return [NSString stringWithFormat:@"http://kitschmaster.com/brickboxes/%@", APP_SUPPORT_URL];
}

+ (NSString*)kitsch_url {
	return [NSString stringWithFormat:@"http://kitschmaster.com/kiches/%@", APP_URL];
}

+ (NSString*)howManyTimes:(int)i {
	if (i==0) {
		return @"zero times";
	} else if (i == 1) {
		return @"one time";
	} else {
		return [NSString stringWithFormat:@"%i times", i];
	}
}

+ (NSDictionary*)stage {
	return [[NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"stage" ofType:@"json"]] JSONValue];
}

+ (BOOL)xibExists:(NSString*)xibName {
	return ( [[NSBundle mainBundle] pathForResource:xibName ofType:@"xib"] == nil) ? NO : YES;
}

+ (void)writeWithPath:(NSString*)filepath data:(NSData*)data {
	[[NSFileManager defaultManager] createFileAtPath:filepath contents:data attributes:nil];
	//DebugLog(@"Kriya# wrote: %@", filepath);
}

+ (NSData*)loadWithPath:(NSString*)filepath {
	NSFileHandle *fh = [NSFileHandle fileHandleForReadingAtPath:filepath];
	NSData *ret = nil;
	if (fh) {
		ret = [fh readDataToEndOfFile];
		[fh closeFile];
	}
	//DebugLog(@"Kriya# loaded: %@", [ret description]);
	return ret;
}

+ (UIImage*)imageWithUrl:(NSString*)url 
{
	NSString *path = [NSHomeDirectory() stringByAppendingString:@"/tmp"];
	[[NSFileManager defaultManager] createDirectoryAtPath:path attributes:nil];			
	path = [NSString stringWithFormat:@"%@/%@", path, [url lastPathComponent]];	
	NSData* imgData = [Kriya loadWithPath:path];
	if (!imgData) {
		NSURL *nsurl = [NSURL URLWithString:url];
		imgData = [NSData dataWithContentsOfURL:nsurl options:0 error:nil];
		[Kriya writeWithPath:path data:imgData];
	} 
	if (imgData)
		return [[[UIImage alloc] initWithData:imgData] autorelease];
	return nil;
}

@end
