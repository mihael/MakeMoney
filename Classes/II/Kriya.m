#import "Kriya.h"
#import "JSON.h"
#import "MakeMoneyAppDelegate.h"
#import <CommonCrypto/CommonDigest.h>
#import "ASIHTTPRequest.h"

CGRect KriyaFrame() {
	CGRect frame = [UIScreen mainScreen].applicationFrame;
	return CGRectMake(0, 0, frame.size.width, frame.size.height);
}

@implementation Kriya

+ (CGRect)orientedFrame {
	UIInterfaceOrientation interfaceOrientation = [[UIDevice currentDevice] orientation];
	CGRect r = CGRectZero;
	switch (interfaceOrientation) {
		case UIInterfaceOrientationPortrait:
			r = CGRectMake(0, 0, 320, 480);
			break;
		case UIInterfaceOrientationPortraitUpsideDown:
			r = CGRectMake(0, 0, 320, 480);
			break;
		case UIInterfaceOrientationLandscapeLeft:
			r = CGRectMake(0, 0, 480, 320);
			break;
		case UIInterfaceOrientationLandscapeRight:
			r = CGRectMake(0, 0, 480, 320);
			break;
		default:
			r = CGRectMake(0, 0, 320, 480);
			break;
	}
	return r;
}

+ (NSInteger)appRunCount 
{
	if (![[NSUserDefaults standardUserDefaults] objectForKey:RUNS]){
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
	NSLog(@"%@", PRAYER);
}

+ (NSString*)deviceId 
{
	return [[UIDevice currentDevice] uniqueIdentifier];
}

+ (NSString*)server_url
{
	return APP_SERVER_URL;
} 

+ (NSString*)startup_url 
{
	return [NSString stringWithFormat:@"%@/brickboxes/%@/%@", APP_SERVER_URL, APP_TITLE, [Kriya deviceId]];
}

+ (NSString*)support_url 
{
	return [NSString stringWithFormat:@"%@/brickboxes/%@", APP_SERVER_URL, APP_TITLE];
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
	NSString * xib_path = [[NSBundle mainBundle] pathForResource:xibName ofType:@"xib"];
	NSString * nib_path = [[NSBundle mainBundle] pathForResource:xibName ofType:@"nib"];
	DebugLog(@"#xibExists %@ %@", xibName, xib_path);
	return (  xib_path == nil && nib_path == nil) ? NO : YES;
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

+ (NSString*)imageWithInMemoryImage:(UIImage*)image forUrl:(NSString*)url
{
	NSString *path = [NSHomeDirectory() stringByAppendingString:@"/tmp"];
	[[NSFileManager defaultManager] createDirectoryAtPath:path attributes:nil];			
	path = [NSString stringWithFormat:@"%@/%@", path, [Kriya md5:url]];	
	[Kriya writeWithPath:path data:UIImageJPEGRepresentation(image, 1.0)];
	return path;
} 


+ (NSString*)imageWithInMemoryImage:(UIImage*)image 
{
	NSString *generatedPath = [NSString stringWithFormat:@"%i", [[NSDate date] timeIntervalSince1970]*-1];
	NSString *path = [NSHomeDirectory() stringByAppendingString:@"/tmp"];
	[[NSFileManager defaultManager] createDirectoryAtPath:path attributes:nil];			
	path = [NSString stringWithFormat:@"%@/%@", path, [Kriya md5:generatedPath]];	
	[Kriya writeWithPath:path data:UIImageJPEGRepresentation(image, 1.0)];
	return path;
} 

+ (UIImage*)imageWithPath:(NSString*)path 
{
	return [UIImage imageWithContentsOfFile:path];
}

//if feches is YES will fech image from web, is blocking and does not look for errors
//usefull for retrieving small images, that load very very fast
//or for retrieving already downloaded images
+ (UIImage*)imageWithUrl:(NSString*)url feches:(BOOL)fechFromWeb
{
	NSString *path = [NSHomeDirectory() stringByAppendingString:@"/tmp"];
	[[NSFileManager defaultManager] createDirectoryAtPath:path attributes:nil];			
	path = [NSString stringWithFormat:@"%@/%@", path, [Kriya md5:url]];	
	NSData* imgData = [Kriya loadWithPath:path];
	if (!imgData&&fechFromWeb) {
		NSURL *nsurl = [NSURL URLWithString:url];
		imgData = [NSData dataWithContentsOfURL:nsurl options:0 error:nil];
		[Kriya writeWithPath:path data:imgData];
	} 
	if (imgData)
		return [[[UIImage alloc] initWithData:imgData] autorelease];
	return nil;
}

//could be used to fech any GET request,.. 
+ (void)imageWithUrl:(NSString*)url delegate:(id)delegate finished:(SEL)finishSelector failed:(SEL)failSelector
{
	ASIHTTPRequest *request = [[[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:url]] autorelease];
	[request setRequestMethod:@"GET"];
	[request setDelegate:delegate];
	[request setDidFailSelector:failSelector];
	[request setDidFinishSelector:finishSelector];
	[Kriya envoke:request];
}

//
+ (void)envoke:(id)request
{
	NSOperationQueue *queue = [[[NSOperationQueue alloc] init] autorelease];
	[queue addOperation:request];
	DebugLog(@"envoke %@", request);
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
