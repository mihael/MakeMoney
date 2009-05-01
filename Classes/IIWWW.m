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

@implementation IIWWW
@synthesize delegate, server, url, params, filterName;

- (id)initWithOptions:(NSDictionary*)o
{
	if (self = [super init]) {
		options = o;
		filter = nil;
		filterName = [options valueForKey:@"filter"];
		if (filterName) {
			NSString *filterClassName = [NSString stringWithFormat:@"Filter_%@", filterName];
			Class filterClass = NSClassFromString(filterClassName);
			if (filterClass) {
				filter = [[[filterClass alloc] init] retain];
			}
		}
		
		[self setUrl:[NSURL URLWithString:[options valueForKey:@"url"]]];
		page = [[options valueForKey:@"page"] intValue];
		limit = [[options valueForKey:@"limit"] intValue];
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
	NSURL *geturl = [NSURL URLWithString:[NSString stringWithFormat:@"%@?%@=%@&%@=%@&%@", [options valueForKey:@"url"], [filter pageParamName], [options valueForKey:@"page"], [filter limitParamName], [options valueForKey:@"limit"], [options valueForKey:@"params"]]];
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
	DebugLog(@"IIWWW#fechFailed");
	if ([(id)self.delegate respondsToSelector:@selector(notFeched:)])
		[self.delegate notFeched:[request responseString]];		
}

- (void)fechFinished:(ASIHTTPRequest *)request
{
	DebugLog(@"IIWWW#fechFinished");
	if ([(id)self.delegate respondsToSelector:@selector(feched:)]) {
		if (filter) { //use a filter 
			//SEL filterMethod = NSSelectorFromString([NSString stringWithFormat:@"%@:", filterMethod]);
			DebugLog(@"IIWWW#fechFinished: filtering with %@",filterName);
			[self.delegate feched:[[filter performSelector:@selector(filter:) withObject:[request responseString]] JSONValue]];		
		} else { 
			[self.delegate feched:[[request responseString] JSONValue]];		
		}
	}

}
	
@end
