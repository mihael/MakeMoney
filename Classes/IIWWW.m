//
//  IIWWW.m
//  MakeMoney
//
#import "IIFilter.h"
#import "IIWWW.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "ASINetworkQueue.h"
#import "JSON.h"
#import "URLUtils.h"
#import "Reachability.h"

@implementation IIWWW
@synthesize delegate, server, url, params, filterName, options;

- (id)initWithOptions:(NSDictionary*)o
{
	if (self = [super init]) {
		[self loadOptions:o];
	}
	return self;
}

- (void)loadOptions:(NSDictionary*)o
{	
	[self setOptions:o];
	//ensure EDGE network comes on
	[[Reachability sharedReachability] setHostName:[[NSURL URLWithString:[options valueForKey:@"url"]] host]];
	if (![self hasWWWAccess]) {
		[[iAlert instance] alert:@"Network unreachable" withMessage:@"Please connect device to internet. Thanks."];	
	}
	
	[filter release];
	filter = nil;
	[self setFilterName:[options valueForKey:@"filter"]];
	if (filterName) { //program says we want to filter information after receive
		NSString *filterClassName = [NSString stringWithFormat:@"Filter_%@", filterName];
		Class filterClass = NSClassFromString(filterClassName);
		if (filterClass) {
			filter = [[[filterClass alloc] init] retain];
		}
	}
	
	[self setUrl:[NSURL URLWithString:[options valueForKey:@"url"]]];
	page = 1;
	if ([options valueForKey:@"page"])
		page = [[options valueForKey:@"page"] intValue];
	limit = 38;
	if ([options valueForKey:@"limit"])
		limit = [[options valueForKey:@"limit"] intValue];
	if ([options valueForKey:@"params"])
		params = [options valueForKey:@"params"];
	[server release];
	server = nil;
	server = [[[ASINetworkQueue alloc] init] retain];	
	[server setRequestDidFinishSelector:@selector(fechFinished:)];
	[server setRequestDidFailSelector:@selector(fechFailed:)];	
	[server setDelegate:self];	

}

- (void)dealloc {
	[options release];
	options = nil;	
	[filter release];
	filter = nil;
	[server release];
	server = nil;
    [super dealloc];
}
//********************************************************************
- (BOOL)hasWWWAccess
{
	return ([[Reachability sharedReachability] internetConnectionStatus]!=NotReachable);
}

- (void)fechUpdateWithParams:(NSDictionary*)p
{
	//post to upload url
	if ([options valueForKey:@"update_url"]) {
		//NSURL *posturl = [NSURL URLWithString:[NSString stringWithFormat:@"%@?%@", [options valueForKey:@"update_url"], prams]];
		NSURL *posturl = [NSURL URLWithString:[options valueForKey:@"update_url"]];
//        NSURL *posturl = [NSURL URLWithString:@"http://koornk.com/api/update"];
//		DebugLog(@"fechUpdateWithParams posturl %@", posturl);
		ASIFormDataRequest *request = [[[ASIFormDataRequest alloc] initWithURL:posturl] autorelease];
		if (p) { //add params
			for (id parameter_name in p) {
				[request setPostValue:[p valueForKey:parameter_name] forKey:parameter_name];				
			}
		}
		[self invokeRequest:request];
	}
}

- (void)cancelFech  //cancel all operation
{
	cancel = YES;
}

//fech - this is all you need for various downloads
- (void)fech 
{
	if ([self hasWWWAccess]) {
		if ([options valueForKey:@"method"]) {
			if ([[options valueForKey:@"method"] isEqualToString:@"custom"]) {
				if ([filter respondsToSelector:@selector(prepareRequestFor:)])  //filter holds custom implementation for feching urls
					[self envokeRequest:[filter prepareRequestFor:options]];
				//TODO envokeRequests... prepareRequests
			} else if ([[options valueForKey:@"method"] isEqualToString:@"form"]) {
				[self formFech];
			} else if ([[options valueForKey:@"method"] isEqualToString:@"post"]) {
				[self postFech];
			} else { //all else gets
				[self getFech];
			}
		} else {
			[self getFech];
		}
	} else {
		[[iAlert instance] alert:@"Network unreachable" withMessage:@"Please connect device to internet. Thanks."];
		[self fechFailed:nil];
	}
}

- (void)formFech 
{
	ASIFormDataRequest *request = [[[ASIFormDataRequest alloc] initWithURL:self.url] autorelease];
	NSString *limitParamName = @"limit";
	NSString *pageParamName = @"page";	
	if (filter) {
		limitParamName = [filter limitParamName];
		pageParamName = [filter pageParamName];
	}

	[request setPostValue:[NSString stringWithFormat:@"%i", page] forKey:pageParamName];
	if ([options valueForKey:@"limit"]) 
		[request setPostValue:[NSString stringWithFormat:@"%i", limit] forKey:limitParamName];
	
	if (params) { //add params
		NSArray* list = [params componentsSeparatedByString:@"&"];
		NSUInteger i, count = [list count];
		for (i = 0; i < count; i++) {
			NSArray * tuple = [[list objectAtIndex:i] componentsSeparatedByString:@"="];
			[request setPostValue:[tuple objectAtIndex:1] forKey:[tuple objectAtIndex:0]];
		}
	}
	[self invokeRequest:request];
}

//TODO rewrite this posting thing, so it becomes more inteligent about the params
- (void)postFech 
{
	
	NSURL *posturl = [NSURL URLWithString:[NSString stringWithFormat:@"%@?%@=%@&%@=%@&%@", [options valueForKey:@"url"], [filter pageParamName], [options valueForKey:@"page"], [filter limitParamName], [options valueForKey:@"limit"], [options valueForKey:@"params"]]];
	ASIHTTPRequest *request = [[[ASIHTTPRequest alloc] initWithURL:posturl] autorelease];
	[request setRequestMethod:@"POST"];
	[self invokeRequest:request];
}

- (void)getFech 
{
	NSString *limitParamName = @"limit";
	NSString *pageParamName = @"page";	
	if (filter) {
		limitParamName = [filter limitParamName];
		pageParamName = [filter pageParamName];
	}
	NSMutableString *parametrs = [NSMutableString stringWithString:@"?"];
	if ([options valueForKey:@"page"]) { //program wants paging
		if ([options valueForKey:@"limit"]) {
			[parametrs appendFormat:@"%@=%@&%@=%@&", pageParamName, [options valueForKey:@"page"], limitParamName, [options valueForKey:@"limit"]];
		} else {
			[parametrs appendFormat:@"%@=%@&", pageParamName, [options valueForKey:@"page"]];		
		}
	}

	if ([options valueForKey:@"params"]) {
		[parametrs appendFormat:@"%@", [options valueForKey:@"params"]];
	}
	NSURL *geturl = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", [options valueForKey:@"url"], ([parametrs length]==1)?@"":parametrs]];
	DebugLog(@"#getFech %@",geturl);
	ASIHTTPRequest *request = [[[ASIHTTPRequest alloc] initWithURL:geturl] autorelease];
	[request setRequestMethod:@"GET"];
	[request setDelegate:self];
	[request setDidFailSelector:@selector(fechFailed:)];
	[request setDidFinishSelector:@selector(fechFinished:)];
	[self envokeRequest:request];
}

#pragma mark invoke a request with server
- (void)invokeRequest:(id)request
{
	cancel = NO;
	if ([request respondsToSelector:@selector(start)]) {
		//[server cancelAllOperations];
		[server addOperation:request];
		[server go];
		DebugLog(@"invokeRequest");
	}
}

#pragma mark invoke a request async 
- (void)envokeRequest:(id)request
{
	cancel = NO;
	NSOperationQueue *queue = [[[NSOperationQueue alloc] init] autorelease];
	[queue addOperation:request];
	DebugLog(@"envokeRequest");
}

#pragma mark progressing
- (void)setProgressDelegate:(id)d 
{
	if (server) {
		[server setDownloadProgressDelegate:d];
	}
}

#pragma mark ASIHTTPRequest delegate
- (void)imageUploadFailed:(ASIHTTPRequest *)request 
{
	if ([(id)self.delegate respondsToSelector:@selector(notFeched:)])
		[self.delegate notFeched:@"Upload failed."];		
}

- (void)imageUploadFinished:(ASIHTTPRequest *)request 
{
	if ([(id)self.delegate respondsToSelector:@selector(feched:)]) {
		NSError *error = [request error];
		if (!error) {
			NSDictionary *messages = [[request responseString] JSONValue];
			DebugLog(@"PIKCHUR RESPONSE: %@", messages);
			if ( messages==NULL || [[messages valueForKey:@"type"] isEqual:@"ERROR"]){
				if (messages!=NULL) {
					DebugLog(@"Pikchur error: %@", [messages valueForKey:@"message"]);
					[self.delegate notFeched:[request responseString]];		
				} else {
					DebugLog(@"Pikchur failed");
					[self.delegate notFeched:@"Pikchur failed"];		
				}
			} else if ([messages valueForKey:@"auth_key"]!=NULL){
				DebugLog(@"Pikchur auth_key: %@ user_id", [messages valueForKey:@"auth_key"], [messages valueForKey:@"auth_key"]);		
				[[NSUserDefaults standardUserDefaults] setValue:[messages valueForKey:@"auth_key"] forKey:@"pikchur_auth_key"];
				[[NSUserDefaults standardUserDefaults] setValue:[messages valueForKey:@"auth_key"] forKey:@"pikchur_user_id"];
				[[NSUserDefaults standardUserDefaults] synchronize];
				[self.delegate feched:messages];
			} else if ([messages valueForKey:@"post"]!=NULL) {
				[self.delegate feched:messages];
			}
		}
	}	
}

#pragma mark ASINetworkQueue delegate methods
- (void)fechFailed:(ASIHTTPRequest *)request
{
	DebugLog(@"#fechFailed");
	if (!cancel) {
		if ([(id)self.delegate respondsToSelector:@selector(notFeched:)]) {
			if (request) {
				[self.delegate notFeched:[request responseString]];		
			} else {
				[self.delegate notFeched:nil];
			}
		}
	}
}

- (void)fechFinished:(ASIHTTPRequest *)request
{
	DebugLog(@"#fechFinished");
	if (!cancel) {
		if (filter) { //use a filter 
			//SEL filterMethod = NSSelectorFromString([NSString stringWithFormat:@"%@:", filterMethod]);
			DebugLog(@"#filtering with %@", filterName);
			NSString *filtered_information = [filter performSelector:@selector(filter:withOptions:) withObject:[request responseString] withObject:options];
			DebugLog(@"#filtered with %@", filterName);
			if (filtered_information) {
				[self.delegate feched:[filtered_information JSONValue]];		
			} else {
				[self.delegate feched:nil];
			}
		} else { 
			if ([[request responseString] hasPrefix:@"["] || [[request responseString] hasPrefix:@"{"]) {
				[self.delegate feched:[[request responseString] JSONValue]];
			} else {
				[self.delegate feched:[request responseString]];				
			}
				 
		}
	}
}
	

#pragma mark Pikchur API 
- (void)fechUploadWithPikchur:(NSString*)imagePath withDescription:(NSString*)description andLocation:(CLLocation*)location andProgress:(id)progressDelegate
{
	NSString *username = [[[options valueForKey:@"pikchur"] componentsSeparatedByString:@"@"] objectAtIndex:0];
	NSString *password = [[[options valueForKey:@"pikchur"] componentsSeparatedByString:@"@"] objectAtIndex:1];;
	
	ASIFormDataRequest *request = [[[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:kPikchurUploadURL]] autorelease];
	if (progressDelegate)
		[request setDownloadProgressDelegate:progressDelegate];
	
	NSString *stringBoundary = [NSString stringWithString:@"0xKhTmLbOuNdArY"];
	NSMutableData *postBody = [NSMutableData data];
	[postBody appendData:[[NSString stringWithFormat:@"--%@\r\n",stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData:[[NSString stringWithString:@"Content-Disposition: form-data; name=\"dataAPIimage\"; filename=\"upload.jpg\"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData:[[NSString stringWithString:@"Content-Type: image/jpeg\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];		
	[postBody appendData:UIImageJPEGRepresentation([self scaleAndRotateImage:[Kriya imageWithUrl:imagePath]], 0.9)];
	[postBody appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
	[request setPostBody:postBody];
	[request setPostValue:username forKey:@"data[api][username]"];
	[request setPostValue:password forKey:@"data[api][password]"];
	//[request setPostValue:@"" forKey:@"data[api][origin]"];
	[request setPostValue:@"pikchur" forKey:@"data[api][service]"];
	[request setPostValue:kPikchurAPIKey forKey:@"data[api][key]"];
	[request setPostValue:[[NSUserDefaults standardUserDefaults] valueForKey:@"pikchur_auth_key"] forKey:@"data[api][auth_key]"];
	[request setPostValue:description forKey:@"data[api][status]"];
	[request setPostValue:[[NSString stringWithFormat:@"%F",[location coordinate].latitude] dataUsingEncoding:NSUTF8StringEncoding] forKey:@"data[api][geo][lat]"];
	[request setPostValue:[[NSString stringWithFormat:@"%F",[location coordinate].longitude] dataUsingEncoding:NSUTF8StringEncoding] forKey:@"data[api][geo][lon]"];	
	
	//doit
	[request setDelegate:self];
	[request setDidFailSelector:@selector(imageUploadFailed:)];
	[request setDidFinishSelector:@selector(imageUploadFinished:)];
	[self envokeRequest:request];
	DebugLog(@"REQUESTING UPLOAD");
}

- (void)authenticateWithPikchur {
	if (![[NSUserDefaults standardUserDefaults] valueForKey:@"pikchur_auth_key"]) {
		DebugLog(@"#authenticateWithPikchur");
		NSString *username = [[[options valueForKey:@"pikchur"] componentsSeparatedByString:@"@"] objectAtIndex:0];
		NSString *password = [[[options valueForKey:@"pikchur"] componentsSeparatedByString:@"@"] objectAtIndex:1];;
		
		ASIFormDataRequest *request = [[[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:kPikchurAuthURL]] autorelease];
		[request setPostValue:username forKey:@"data[api][username]"];
		[request setPostValue:password forKey:@"data[api][password]"];
		[request setPostValue:@"pikchur" forKey:@"data[api][service]"];
		[request setPostValue:kPikchurAPIKey forKey:@"data[api][key]"];

		[request setDelegate:self];
		[request setDidFailSelector:@selector(imageUploadFailed:)];
		[request setDidFinishSelector:@selector(imageUploadFinished:)];
		[request start];
	}
} 

- (BOOL)isAuthenticatedWithPikchur 
{
	if ([[NSUserDefaults standardUserDefaults] valueForKey:@"pikchur_auth_key"])
		return YES;
	return NO;
}

#pragma mark image scaling and rotating
- (UIImage*)scaleAndRotateImage:(UIImage*)image {  
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
