//
//  IIWWW.m
//  MakeMoney
//
#import "IIWWW.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "ASINetworkQueue.h"
#import "JSON.h"
#import "Filter.h"

@implementation IIWWW
@synthesize delegate, url, server, filterName;

- (id)initWithUrl:(NSString*)lru andParams:(NSString*)p
{
	if (self = [super init]) {
		[self setUrl:[NSURL URLWithString:lru]];
		server = [[[ASINetworkQueue alloc] init] retain];	
		[server cancelAllOperations];
		[server setRequestDidFinishSelector:@selector(fechFinished:)];
		[server setRequestDidFailSelector:@selector(fechFailed:)];
		[server setDelegate:self];
		
		//ASIHTTPRequest *request = [[[ASIHTTPRequest alloc] initWithURL:self.url] autorelease];
		//[request setRequestMethod:@"GET"];

		ASIFormDataRequest *request = [[[ASIFormDataRequest alloc] initWithURL:self.url] autorelease];
		if (p) { //add params
			NSArray* list = [p componentsSeparatedByString:@"&"];
			NSUInteger i, count = [list count];
			for (i = 0; i < count; i++) {
				NSArray * tuple = [[list objectAtIndex:i] componentsSeparatedByString:@"="];
				[request setPostValue:[tuple objectAtIndex:1] forKey:[tuple objectAtIndex:0]];
			}
		}
			
		[server addOperation:request];
	}
	return self;
}

- (void)dealloc {
	[server release];
    [super dealloc];
}

- (void)fech 
{
	[server go];
}

- (void)fechPath:(NSString*)urlPath 
{
	ASIHTTPRequest *request = [[[ASIHTTPRequest alloc] initWithURL:[NSString stringWithFormat:@"%@/%@",self.url, urlPath]] autorelease];
	[request setRequestMethod:@"POST"];
	[server cancelAllOperations];
	[server addOperation:request];
	[server go];
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
	NSLog(@"IIWWW#fechFailed");

	if ([self.delegate respondsToSelector:@selector(notFeched:)])
		[self.delegate notFeched:[request responseString]];		
}

- (void)fechFinished:(ASIHTTPRequest *)request
{
	NSLog(@"IIWWW#fechFinished");
	if ([self.delegate respondsToSelector:@selector(feched:)]) {
		if (filterName) { //use a filter 
			SEL filter = NSSelectorFromString([NSString stringWithFormat:@"%@:", filterName]);
			NSLog(@"about to filter with %@",filterName);

			[self.delegate feched:[[Filter performSelector:filter withObject:[request responseString]] JSONValue]];		
		} else { 
			[self.delegate feched:[[request responseString] JSONValue]];		
		}
	}

}
	
@end
