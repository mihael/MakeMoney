#import "Kriya.h"
#import "MakeMoneyAppDelegate.h"
#import <CommonCrypto/CommonDigest.h>
#import "ASIHTTPRequest.h"
#import "CJSONDeserializer.h"

CGRect KriyaFrame() {
	CGRect frame = [UIScreen mainScreen].applicationFrame;
	return CGRectMake(0, 0, frame.size.width, frame.size.height);
}

#define pod_RectPortrait CGRectMake(0, 0, 320, 480)
#define pod_RectPortraitUpsideDown CGRectMake(0, 0, 320, 480)
#define pod_RectLandscapeLeft CGRectMake(0, 0, 480, 320)
#define pod_RectLandscapeRight CGRectMake(0, 0, 480, 320)

#define pad_RectPortrait CGRectMake(0, 0, 768, 1024)
#define pad_RectPortraitUpsideDown CGRectMake(0, 0, 768, 1024)
#define pad_RectLandscapeLeft CGRectMake(0, 0, 1024, 768)
#define pad_RectLandscapeRight CGRectMake(0, 0, 1024, 768)

@implementation Kriya

+ (CGRect)orientedFrame {
	UIInterfaceOrientation interfaceOrientation = [[UIDevice currentDevice] orientation];
	CGRect r = CGRectZero;
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 30200
	// iPad
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		//this is an iPad
		switch (interfaceOrientation) {
			case UIInterfaceOrientationPortrait:
				//todo is this iPad?
				r = pad_RectPortrait;
				break;
			case UIInterfaceOrientationPortraitUpsideDown:
				r = pad_RectPortraitUpsideDown;
				break;
			case UIInterfaceOrientationLandscapeLeft:
				r = pad_RectLandscapeLeft;
				break;
			case UIInterfaceOrientationLandscapeRight:
				r = pad_RectLandscapeRight;
				break;
			default:
				r = pad_RectPortrait;
				break;
		}
		
	} else {
		//this is iPhone or iPod touch
		switch (interfaceOrientation) {
			case UIInterfaceOrientationPortrait:
				//todo is this iPad?
				r = pod_RectPortrait;
				break;
			case UIInterfaceOrientationPortraitUpsideDown:
				r = pod_RectPortraitUpsideDown;
				break;
			case UIInterfaceOrientationLandscapeLeft:
				r = pod_RectLandscapeLeft;
				break;
			case UIInterfaceOrientationLandscapeRight:
				r = pod_RectLandscapeRight;
				break;
			default:
				r = pod_RectPortrait;
				break;
		}
	}
#else
	// iPhone
	switch (interfaceOrientation) {
		case UIInterfaceOrientationPortrait:
			//todo is this iPad?
			r = pod_RectPortrait;
			break;
		case UIInterfaceOrientationPortraitUpsideDown:
			r = pod_RectPortraitUpsideDown;
			break;
		case UIInterfaceOrientationLandscapeLeft:
			r = pod_RectLandscapeLeft;
			break;
		case UIInterfaceOrientationLandscapeRight:
			r = pod_RectLandscapeRight;
			break;
		default:
			r = pod_RectPortrait;
			break;
	}
#endif

	return r;
}

+ (BOOL)portrait {
	UIInterfaceOrientation interfaceOrientation = [[UIDevice currentDevice] orientation];
	switch (interfaceOrientation) {
		case UIInterfaceOrientationPortrait:
			return YES;
		case UIInterfaceOrientationPortraitUpsideDown:
			return NO;
		case UIInterfaceOrientationLandscapeLeft:
			return NO;
		case UIInterfaceOrientationLandscapeRight:
			return NO;
		default:
			return YES;
	}
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
	NSLog(@"%@ %@", MANTRA, PRAYER);
}

+ (NSString*)deviceId 
{
	return [[UIDevice currentDevice] uniqueIdentifier];
}

+ (NSString*)app_title
{
	return APP_TITLE;
}

+ (NSString*)app_id
{
	return APP_ID;
}

+ (NSString*)server_url
{
	return APP_SERVER_URL;
} 

+ (NSString*)apn_register_url
{
	return [NSString stringWithFormat:@"%@/apn_register/%@", APP_SERVER_URL, APP_TITLE];
}

+ (NSString*)startup_url 
{
	return [NSString stringWithFormat:@"%@/brickboxes/%@/%@", APP_SERVER_URL, APP_TITLE, [Kriya deviceId]];
}

+ (NSString*)support_url 
{
	return [NSString stringWithFormat:@"%@/brickboxes/%@", APP_SERVER_URL, APP_TITLE];
}

+ (NSString*)welcome_url 
{
	return [NSString stringWithFormat:@"%@/kiches/%@", APP_SERVER_URL, APP_WELCOME_KICH];
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
	NSError *err = nil;
	NSDictionary * data = [[CJSONDeserializer deserializer] deserialize:[NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"stage" ofType:@"json"]] error:&err];
	//DLog(@"Deserialized: %@", data);
	if (err) {
		DLog(@"Error while deserializing stage.");
		return nil;
	}
	return data;
}

+ (BOOL)xibExists:(NSString*)xibName 
{
	NSString * xib_path = [[NSBundle mainBundle] pathForResource:xibName ofType:@"xib"];
	NSString * nib_path = [[NSBundle mainBundle] pathForResource:xibName ofType:@"nib"];
	DLog(@"#xibExists %@ %@", xibName, xib_path);
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
	NSString *dir = [NSHomeDirectory() stringByAppendingString:@"/tmp"];
	[[NSFileManager defaultManager] createDirectoryAtPath:dir attributes:nil];			
	NSString *path = [NSString stringWithFormat:@"%@/%@", dir, [Kriya md5:url]];	
	[Kriya writeWithPath:path data:UIImageJPEGRepresentation(image, 1.0)];
	return [path copy];
} 


+ (NSString*)imageWithInMemoryImage:(UIImage*)image 
{
	NSString *generatedPath = [NSString stringWithFormat:@"%i", [[NSDate date] timeIntervalSince1970]*-1];
	NSString *dir = [NSHomeDirectory() stringByAppendingString:@"/tmp"];
	[[NSFileManager defaultManager] createDirectoryAtPath:dir attributes:nil];			
	NSString *path = [NSString stringWithFormat:@"%@/%@.jpg", dir, [Kriya md5:generatedPath]];	
	[Kriya writeWithPath:path data:UIImageJPEGRepresentation(image, 1.0)];
	return [path copy];
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
	NSString *dir = [NSHomeDirectory() stringByAppendingString:@"/tmp"];
	[[NSFileManager defaultManager] createDirectoryAtPath:dir attributes:nil];			
	NSString *path = [NSString stringWithFormat:@"%@/%@", dir, [Kriya md5:url]];	
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
	//DLog(@"envoke %@", request);
}


+ (void)clearImageWithUrl:(NSString*)url 
{
	NSString *dir = [NSHomeDirectory() stringByAppendingString:@"/tmp"];
	[[NSFileManager defaultManager] createDirectoryAtPath:dir attributes:nil];			
	NSString *path = [NSString stringWithFormat:@"%@/%@", dir, [Kriya md5:url]];	
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

#pragma mark Dates
+ (BOOL) date:(NSDate*)date isBetweenDate:(NSDate*)beginDate andDate:(NSDate*)endDate {
    return (([date compare:beginDate] != NSOrderedAscending) && ([date compare:endDate] != NSOrderedDescending));
}

#pragma mark simple states
+ (void)saveState:(NSString*)value forField:(NSString*)key {
	if (value&&key) {
		DLog(@"OM KRIYA SAVING STATE %@ for %@", value, key);
		[[NSUserDefaults standardUserDefaults] setObject:value forKey:key];
		[[NSUserDefaults standardUserDefaults] synchronize];
	}
}

+ (NSString*)stateForField:(NSString*)key {
	if (key) {
		return [[NSUserDefaults standardUserDefaults] valueForKey:key];
	} else {
		return @"";
	}
}

#pragma mark image scaling and rotating
+ (UIImage*)scaleAndRotateImage:(UIImage*)image {  
	int kMaxResolution = 1024; // Or whatever  
	
	CGImageRef imgRef = image.CGImage;  
	
	CGFloat width = CGImageGetWidth(imgRef);  
	CGFloat height = CGImageGetHeight(imgRef);  
	
    CGAffineTransform transform = CGAffineTransformIdentity;  
    CGRect bounds = CGRectMake(0, 0, width, height);  
    if (width > kMaxResolution || height > kMaxResolution) {  
		CGFloat ratio = width/height;  
		if (ratio > 1) {  
			bounds.size.width = kMaxResolution;  
            bounds.size.height = bounds.size.width / ratio;  
        }  
		else {  
			bounds.size.height = kMaxResolution;  
			bounds.size.width = bounds.size.height * ratio;  
		}  
	}  
	
	CGFloat scaleRatio = bounds.size.width / width;  
	CGSize imageSize = CGSizeMake(CGImageGetWidth(imgRef), CGImageGetHeight(imgRef));  
	CGFloat boundHeight;  
	UIImageOrientation orient = image.imageOrientation;  
	switch(orient) {  
			
		case UIImageOrientationUp: //EXIF = 1  
			transform = CGAffineTransformIdentity;  
			break;  
			
		case UIImageOrientationUpMirrored: //EXIF = 2  
			transform = CGAffineTransformMakeTranslation(imageSize.width, 0.0);  
			transform = CGAffineTransformScale(transform, -1.0, 1.0);  
			break;  
			
		case UIImageOrientationDown: //EXIF = 3  
			transform = CGAffineTransformMakeTranslation(imageSize.width, imageSize.height);  
			transform = CGAffineTransformRotate(transform, M_PI);  
			break;  
			
		case UIImageOrientationDownMirrored: //EXIF = 4  
			transform = CGAffineTransformMakeTranslation(0.0, imageSize.height);  
			transform = CGAffineTransformScale(transform, 1.0, -1.0);  
			break;  
			
		case UIImageOrientationLeftMirrored: //EXIF = 5  
			boundHeight = bounds.size.height;  
			bounds.size.height = bounds.size.width;  
			bounds.size.width = boundHeight;  
			transform = CGAffineTransformMakeTranslation(imageSize.height, imageSize.width);  
			transform = CGAffineTransformScale(transform, -1.0, 1.0);  
			transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);  
			break;  
			
		case UIImageOrientationLeft: //EXIF = 6  
			boundHeight = bounds.size.height;  
			bounds.size.height = bounds.size.width;  
			bounds.size.width = boundHeight;  
			transform = CGAffineTransformMakeTranslation(0.0, imageSize.width);  
			transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);  
			break;  
			
		case UIImageOrientationRightMirrored: //EXIF = 7  
			boundHeight = bounds.size.height;  
			bounds.size.height = bounds.size.width;  
			bounds.size.width = boundHeight;  
			transform = CGAffineTransformMakeScale(-1.0, 1.0);  
			transform = CGAffineTransformRotate(transform, M_PI / 2.0);  
			break;  
			
		case UIImageOrientationRight: //EXIF = 8  
			boundHeight = bounds.size.height;  
			bounds.size.height = bounds.size.width;  
			bounds.size.width = boundHeight;  
			transform = CGAffineTransformMakeTranslation(imageSize.height, 0.0);  
			transform = CGAffineTransformRotate(transform, M_PI / 2.0);  
			break;  
			
		default:  
			[NSException raise:NSInternalInconsistencyException format:@"Invalid image orientation"];  
			
	}  
	
	UIGraphicsBeginImageContext(bounds.size);  
	
	CGContextRef context = UIGraphicsGetCurrentContext();  
	
	if (orient == UIImageOrientationRight || orient == UIImageOrientationLeft) {  
		CGContextScaleCTM(context, -scaleRatio, scaleRatio);  
		CGContextTranslateCTM(context, -height, 0);  
	}  
	else {  
		CGContextScaleCTM(context, scaleRatio, -scaleRatio);  
		CGContextTranslateCTM(context, 0, -height);  
	}  
	
	CGContextConcatCTM(context, transform);  
	
	CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, width, height), imgRef);  
	UIImage *imageCopy = UIGraphicsGetImageFromCurrentImageContext();  
	UIGraphicsEndImageContext();  
	
	return imageCopy;  
}  

@end
