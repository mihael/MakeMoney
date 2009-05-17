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

@implementation IIWWW
@synthesize delegate, server, url, params, filterName;

- (id)initWithOptions:(NSDictionary*)o
{
	if (self = [super init]) {
		options = o;
		filter = nil;
		filterName = [options valueForKey:@"filter"];
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

		server = [[[ASINetworkQueue alloc] init] retain];	
		[server setRequestDidFinishSelector:@selector(fechFinished:)];
		[server setRequestDidFailSelector:@selector(fechFailed:)];

		[server setDelegate:self];
	}
	return self;
}

- (void)dealloc {
	[filter release];
	[server release];
    [super dealloc];
}
//********************************************************************
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
	
		[server cancelAllOperations];
		[server addOperation:request];
		[server go];		
	}
}

- (void)fech 
{
	if ([options valueForKey:@"method"]) {
		if ([[options valueForKey:@"method"] isEqualToString:@"custom"]) {
			if ([filter respondsToSelector:@selector(requestWith:)])  //filter holds custom implementation for feching urls
				[self invokeRequest:[filter requestWith:options]];
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
}
- (void)formFech 
{
	ASIFormDataRequest *request = [[[ASIFormDataRequest alloc] initWithURL:self.url] autorelease];
	if (filter) { //add paging TODO if filter respoond to
		[request setPostValue:[NSString stringWithFormat:@"%i", page] forKey:[filter pageParamName]];
		[request setPostValue:[NSString stringWithFormat:@"%i", limit] forKey:[filter limitParamName]];
	}
	if (params) { //add params
		NSArray* list = [params componentsSeparatedByString:@"&"];
		NSUInteger i, count = [list count];
		for (i = 0; i < count; i++) {
			NSArray * tuple = [[list objectAtIndex:i] componentsSeparatedByString:@"="];
			[request setPostValue:[tuple objectAtIndex:1] forKey:[tuple objectAtIndex:0]];
		}
	}
	[server cancelAllOperations];
	[server addOperation:request];
	[server go];
}

//TODO rewrite this posting thing, so it becomes more inteligent about the params
- (void)postFech 
{
	NSURL *posturl = [NSURL URLWithString:[NSString stringWithFormat:@"%@?%@=%@&%@=%@&%@", [options valueForKey:@"url"], [filter pageParamName], [options valueForKey:@"page"], [filter limitParamName], [options valueForKey:@"limit"], [options valueForKey:@"params"]]];
	ASIHTTPRequest *request = [[[ASIHTTPRequest alloc] initWithURL:posturl] autorelease];
	[request setRequestMethod:@"POST"];
	[server cancelAllOperations];
	[server addOperation:request];
	[server go];		
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
		[parametrs appendFormat:@"%@=%@&%@=%@&", pageParamName, [options valueForKey:@"page"], limitParamName, [options valueForKey:@"limit"]];
	}

	if ([options valueForKey:@"params"]) {
		[parametrs appendFormat:@"%@", [options valueForKey:@"params"]];
	}
	NSURL *geturl = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", [options valueForKey:@"url"], ([parametrs length]==1)?@"":parametrs]];
	DebugLog(@"#getFech %@",geturl);
	ASIHTTPRequest *request = [[[ASIHTTPRequest alloc] initWithURL:geturl] autorelease];
	[request setRequestMethod:@"GET"];
	[self invokeRequest:request];
}

- (void)invokeRequest:(id)request
{
	if ([request respondsToSelector:@selector(start)]) {
		[server cancelAllOperations];
		[server addOperation:request];
		[server go];
		DebugLog(@"invokeRequest");
	}
}

- (void)setProgressDelegate:(id)d 
{
	if (server) {
		[server setDownloadProgressDelegate:d];
	}
}

#pragma mark ASINetworkQueue delegate methods
- (void)fechFailed:(ASIHTTPRequest *)request
{
	DebugLog(@"#fechFailed");
	if ([(id)self.delegate respondsToSelector:@selector(notFeched:)])
		[self.delegate notFeched:[request responseString]];		
}

- (void)fechFinished:(ASIHTTPRequest *)request
{
	DebugLog(@"#fechFinished");
	if ([(id)self.delegate respondsToSelector:@selector(feched:)]) {
		if (filter) { //use a filter 
			//SEL filterMethod = NSSelectorFromString([NSString stringWithFormat:@"%@:", filterMethod]);
			DebugLog(@"#fechFinished: filtering with %@",filterName);
			[self.delegate feched:[[filter performSelector:@selector(filter:withOptions:) withObject:[request responseString] withObject:options] JSONValue]];		
		} else { 
			if ([[request responseString] hasPrefix:@"["] || [[request responseString] hasPrefix:@"{"]) {
				[self.delegate feched:[[request responseString] JSONValue]];
			} else {
				[self.delegate feched:[request responseString]];				
			}
				 
		}
	}
}
	
#pragma mark image uploading supports pikchur
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

#pragma mark Pikchur API 

- (NSString*)uploadWithPikchur:(NSString*)imagePath withDescription:(NSString*)description andLocation:(CLLocation*)location {
	[self authenticateWithPikchur];
	NSString *username = [[[options valueForKey:@"pikchur"] componentsSeparatedByString:@"@"] objectAtIndex:0];
	NSString *password = [[[options valueForKey:@"pikchur"] componentsSeparatedByString:@"@"] objectAtIndex:1];;
	
	ASIFormDataRequest *request = [[[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:kPikchurUploadURL]] autorelease];

	NSString *stringBoundary = [NSString stringWithString:@"0xKhTmLbOuNdArY"];
	NSMutableData *postBody = [NSMutableData data];
	[postBody appendData:[[NSString stringWithFormat:@"--%@\r\n",stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
/*
	[postBody appendData:[[NSString stringWithString:@"Content-Disposition: form-data; name=\"data[api][auth_key]\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData:[[[NSUserDefaults standardUserDefaults] valueForKey:@"pikchur_auth_key"] dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData:[[NSString stringWithString:@"Content-Disposition: form-data; name=\"data[api][key]\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData:[kPikchurAPIKey dataUsingEncoding:NSUTF8StringEncoding]];
	
	[postBody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData:[[NSString stringWithString:@"Content-Disposition: form-data; name=\"data[api][username]\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData:[username dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData:[[NSString stringWithString:@"Content-Disposition: form-data; name=\"data[api][password]\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData:[password dataUsingEncoding:NSUTF8StringEncoding]];
	
	
	[postBody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData:[[NSString stringWithString:@"Content-Disposition: form-data; name=\"data[api][status]\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData:[description dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData:[[NSString stringWithString:@"Content-Disposition: form-data; name=\"data[api][origin]\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData:[@"MTI" dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
	
	if (location) {
		[postBody appendData:[[NSString stringWithString:@"Content-Disposition: form-data; name=\"data[api][geo][lat]\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
		[postBody appendData:[[NSString stringWithFormat:@"%F",[location coordinate].latitude] dataUsingEncoding:NSUTF8StringEncoding]];
		//[postBody appendData:[@"46.055" dataUsingEncoding:NSUTF8StringEncoding]];//LJUBLJANA
		[postBody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
		[postBody appendData:[[NSString stringWithString:@"Content-Disposition: form-data; name=\"data[api][geo][lon]\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
		[postBody appendData:[[NSString stringWithFormat:@"%F",[location coordinate].longitude] dataUsingEncoding:NSUTF8StringEncoding]];
		//[postBody appendData:[@"14.514" dataUsingEncoding:NSUTF8StringEncoding]];//LJUBLJANA		
		[postBody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
	}
	*/
	[postBody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData:[[NSString stringWithString:@"Content-Disposition: form-data; name=\"dataAPIimage\"; filename=\"upload.jpg\"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData:[[NSString stringWithString:@"Content-Type: image/jpeg\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
	
	
	[postBody appendData:UIImageJPEGRepresentation([self scaleAndRotateImage:[Kriya imageWithUrl:imagePath]], 0.9)];
	[postBody appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
	
	[request setPostBody:postBody];
	
	
	//**********************************
	
	[request setPostValue:username forKey:@"data[api][username]"];
	[request setPostValue:password forKey:@"data[api][password]"];
	//[request setPostValue:@"" forKey:@"data[api][origin]"];
	[request setPostValue:@"pikchur" forKey:@"data[api][service]"];
	[request setPostValue:@"plusOOts6YVcBSFGgT0jaA" forKey:@"data[api][key]"];
	[request setPostValue:[[NSUserDefaults standardUserDefaults] valueForKey:@"pikchur_auth_key"] forKey:@"data[api][auth_key]"];
	[request setPostValue:description forKey:@"data[api][status]"];
	[request setPostValue:[[NSString stringWithFormat:@"%F",[location coordinate].latitude] dataUsingEncoding:NSUTF8StringEncoding] forKey:@"data[api][geo][lat]"];
	[request setPostValue:[[NSString stringWithFormat:@"%F",[location coordinate].longitude] dataUsingEncoding:NSUTF8StringEncoding] forKey:@"data[api][geo][lon]"];	
	
	//[request setPostValue:UIImageJPEGRepresentation([Kriya imageWithUrl:imagePath], 0.9) forKey:@"dataAPIimage"];
	//[request setShouldStreamPostDataFromDisk:YES];
	//[request setFile:imagePath forKey:@"dataAPIimage"];
	//[request setPostBody:<#(NSMutableData *)#>]
	[request start];
	
	NSError *error = [request error];
	if (!error) {
		NSDictionary *messages = [[request responseString] JSONValue];
		DebugLog(@"PIKCHUR RESPONSE: %@", messages);
		if ( messages==NULL || [[messages valueForKey:@"type"] isEqual:@"ERROR"]){
			if (messages!=NULL) {
				DebugLog(@"Pikchur error: %@", [messages valueForKey:@"message"]);
				return nil;
			} else {
				DebugLog(@"Pikchur failed");
				return nil;
			}
		} else if ([messages valueForKey:@"auth_key"]!=NULL){
			DebugLog(@"#uploadWithPikchur auth_key: %@", [messages valueForKey:@"auth_key"]);		
			return nil;
		} else if ([messages valueForKey:@"post"]!=NULL) {
			return [[messages valueForKey:@"post"] valueForKey:@"url"];
		}
	}
	DebugLog(@"Error: %@", error);
	return nil;
}

- (void)authenticateWithPikchur {
	if (![[NSUserDefaults standardUserDefaults] valueForKey:@"pikchur_auth_key"]) {
		DebugLog(@"#authenticateWithPikchur");
		NSString *username = [[[options valueForKey:@"pikchur"] componentsSeparatedByString:@"@"] objectAtIndex:0];
		NSString *password = [[[options valueForKey:@"pikchur"] componentsSeparatedByString:@"@"] objectAtIndex:1];;
		
		ASIFormDataRequest *request = [[[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:kPikchurUploadURL]] autorelease];
		[request setPostValue:username forKey:@"data[api][username]"];
		[request setPostValue:password forKey:@"data[api][password]"];
		[request setPostValue:@"pikchur" forKey:@"data[api][service]"];
		[request setPostValue:@"plusOOts6YVcBSFGgT0jaA" forKey:@"data[api][key]"];

		[request start];
		NSError *error = [request error];
		if (!error) {
			NSDictionary *messages = [[request responseString] JSONValue];
			if ( messages==NULL || [[messages valueForKey:@"type"] isEqual:@"ERROR"]){
					if (messages!=NULL) {
						DebugLog(@"Pikchur error: %@", [messages valueForKey:@"message"]);
					} else {
						DebugLog(@"Pikchur failed");
					}
			} else if ([messages valueForKey:@"auth_key"]!=NULL){
				[[NSUserDefaults standardUserDefaults] setValue:[messages valueForKey:@"auth_key"] forKey:@"pikchur_auth_key"];
				DebugLog(@"#authenticateWithPikchur auth_key : %@", [messages valueForKey:@"auth_key"]);		
			}	
		}
	}
} 

@end
