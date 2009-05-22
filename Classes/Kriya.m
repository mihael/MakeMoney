#import "Kriya.h"
#import "JSON.h"
#import "MakeMoneyAppDelegate.h"
#import <CommonCrypto/CommonDigest.h>

@implementation Kriya
+ (CGRect)appViewRect 
{
	CGRect screen = [[UIScreen mainScreen] applicationFrame];
	CGFloat c_w = screen.size.height;
	CGFloat c_h = screen.size.width;	
	if ([[[MakeMoneyAppDelegate app] rootViewController] interfaceOrientation] == UIInterfaceOrientationPortrait) {
		c_w = screen.size.width;
		c_h = screen.size.height; 
	}	
	return CGRectMake(0.0, 0.0, c_w, c_h);
}

+ (NSInteger)appRunCount 
{
	if (![[NSUserDefaults standardUserDefaults] objectForKey:RUNS]){
		NSLog(@"Om Om Om Kriya Babaji Namah Om Om Om");
		[[NSUserDefaults standardUserDefaults] setInteger:0 forKey:RUNS];
		[[NSUserDefaults standardUserDefaults] synchronize];
	}
	return [[NSUserDefaults standardUserDefaults] integerForKey:RUNS];	
}

+ (void)incrementAppRunCount 
{
	[[NSUserDefaults standardUserDefaults] setInteger:([Kriya appRunCount] + 1) forKey:RUNS];
	[[NSUserDefaults standardUserDefaults] synchronize];	
}

+ (void)prayInCode 
{
	NSLog(@"OM NAMAH SHIVAYA %@ OM KRIYA BABAJI NAMAH OM", PRAYER);
}

+ (NSString*)deviceId 
{
	return [[UIDevice currentDevice] uniqueIdentifier];
}

+ (NSString*)brickbox_url 
{
	return [NSString stringWithFormat:@"http://kitschmaster.com/brickboxes/%@/%@", APP_TITLE, [Kriya deviceId]];
}

+ (NSString*)support_url 
{
	return [NSString stringWithFormat:@"http://kitschmaster.com/brickboxes/%@", APP_SUPPORT_URL];
}

+ (NSString*)kitsch_url 
{
	return [NSString stringWithFormat:@"http://kitschmaster.com/kiches/%@", APP_URL];
}

+ (NSString*)howManyTimes:(int)i 
{
	if (i==0) {
		return @"zero times";
	} else if (i == 1) {
		return @"one time";
	} else {
		return [NSString stringWithFormat:@"%i times", i];
	}
}

+ (NSDictionary*)stage 
{
	return [[NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"stage" ofType:@"json"]] JSONValue];
}

+ (BOOL)xibExists:(NSString*)xibName 
{
	return ( [[NSBundle mainBundle] pathForResource:xibName ofType:@"xib"] == nil) ? NO : YES;
}

+ (void)writeWithPath:(NSString*)filepath data:(NSData*)data 
{
	[[NSFileManager defaultManager] createFileAtPath:filepath contents:data attributes:nil];
	//DebugLog(@"Kriya# wrote: %@", filepath);
}

+ (NSData*)loadWithPath:(NSString*)filepath 
{
	NSFileHandle *fh = [NSFileHandle fileHandleForReadingAtPath:filepath];
	NSData *ret = nil;
	if (fh) {
		ret = [fh readDataToEndOfFile];
		[fh closeFile];
	}
	//DebugLog(@"Kriya# loaded: %@", [ret description]);
	return ret;
}

+ (NSString*)imageWithInMemoryImage:(UIImage*)image 
{
	NSString *generatedPath = [NSString stringWithFormat:@"%i", [[NSDate date] timeIntervalSince1970]*-1];
	NSString *path = [NSHomeDirectory() stringByAppendingString:@"/tmp"];
	[[NSFileManager defaultManager] createDirectoryAtPath:path attributes:nil];			
	path = [NSString stringWithFormat:@"%@/%@", path, [Kriya md5:generatedPath]];	
	[Kriya writeWithPath:path data:UIImageJPEGRepresentation(image, 1.0)];
	return generatedPath;
} 

+ (UIImage*)imageWithUrl:(NSString*)url 
{
	NSString *path = [NSHomeDirectory() stringByAppendingString:@"/tmp"];
	[[NSFileManager defaultManager] createDirectoryAtPath:path attributes:nil];			
	path = [NSString stringWithFormat:@"%@/%@", path, [Kriya md5:url]];	
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

+ (void)clearImageWithUrl:(NSString*)url 
{
	NSString *path = [NSHomeDirectory() stringByAppendingString:@"/tmp"];
	[[NSFileManager defaultManager] createDirectoryAtPath:path attributes:nil];			
	path = [NSString stringWithFormat:@"%@/%@", path, [Kriya md5:url]];	
	[[NSFileManager defaultManager] removeItemAtPath:path error:nil];
}

+ (NSString*)md5:(NSString*)str 
{
	const char *cStr = [str UTF8String];
	unsigned char result[CC_MD5_DIGEST_LENGTH];
	CC_MD5( cStr, strlen(cStr), result );
	return [NSString stringWithFormat: 
			@"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
			result[0], result[1],
			result[2], result[3],
			result[4], result[5],
			result[6], result[7],
			result[8], result[9],
			result[10], result[11],
			result[12], result[13],
			result[14], result[15]];
}

@end
