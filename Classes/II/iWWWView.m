//
//  iWWWView.m
//  MakeMoney
//
#import "iWWWView.h"


static CGFloat kDefaultWidth = 380;
static CGFloat kDefaultHeight = 280;

static NSString* kEmbedHTML = @"\
<html>\
<head>\
<meta name=\"viewport\" content=\"initial-scale=1.0, user-scalable=no, width=%0.0f\"/>\
</head>\
<body style=\"background:#fff;margin-top:0px;margin-left:0px\">\
<div><object width=\"%0.0f\" height=\"%0.0f\">\
<param name=\"movie\" value=\"%@\"></param><param name=\"wmode\"\
value=\"transparent\"></param>\
<embed id=\"yt\" src=\"%@\" type=\"application/x-shockwave-flash\"\
wmode=\"transparent\" width=\"%0.0f\" height=\"%0.0f\"></embed>\
</object></div>\
</body>\
</html>";

static NSString* kClearHTML = @"\
<html>\
<head>\
<meta name=\"viewport\" content=\"initial-scale=1.0, user-scalable=no, width=%0.0f\"/>\
</head>\
<body style=\"background:#fff;margin-top:0px;margin-left:0px\">\
Cool!\
</body>\
</html>";

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation iWWWView

@synthesize url = _url;
- (id)initWithURL:(NSString*)url {
	
	if (self = [self initWithFrame:CGRectMake(0, 0, kDefaultWidth, kDefaultHeight)]) {
		self.url = url;
	}
	return self;
}

- (id)initWithFrame:(CGRect)frame {
	
	if (self = [super initWithFrame:frame]) {
		//self.backgroundColor = [UIColor clearColor];
		webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
//		[webView loadHTMLString:kClearHTML baseURL:nil];
		[webView setDelegate:self];
//		[webView setScalesPageToFit:YES];
		[self addSubview:webView];
		//[self clear];

		indica = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
		[indica setCenter:webView.center];
		[indica setHidesWhenStopped:YES];
		[self addSubview:indica];
	}
	return self;
}

- (void)dealloc {
	[webView release];
	[indica release];
	[_url release];
	[super dealloc];
}

- (void) startLoading {
	[indica startAnimating];
}

- (void) stopLoading {
	[indica stopAnimating];
}

- (NSMutableURLRequest*)makeRequest:(NSString*)url {
	NSString *encodedUrl = (NSString*)CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)url, NULL, NULL, kCFStringEncodingUTF8);
	NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] init] autorelease];
	[request setURL:[NSURL URLWithString:encodedUrl]];
	//[request setCachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData];
	//[request setTimeoutInterval:TIMEOUT_SEC];
	[request setHTTPShouldHandleCookies:FALSE];
	[encodedUrl release];
	return request;
}

- (void)setUrl:(NSString*)url {
	[_url release];
	_url = [url copy];
	
	if (_url) {
		[webView loadRequest:[self makeRequest:_url]];
	} else {
		[self setHidden:YES];
	}
}

- (void)setNSURL:(NSURL*)nsurl {
	[_url release];
	_url = [[nsurl absoluteString] copy];
	
	if (_url) {
		[webView loadRequest:[NSURLRequest requestWithURL:nsurl]];
	} else {
		[self setHidden:YES];
	}
}

- (void)setYutubUrl:(NSString*)yutub_url {
	[_url release];
	_url = [yutub_url copy];
	
	if (_url) {
		NSString* html = [NSString stringWithFormat:kEmbedHTML, self.frame.size.width, self.frame.size.width,
						  self.frame.size.height, _url, _url, self.frame.size.width, self.frame.size.height];
		[webView loadHTMLString:html baseURL:nil];
	} else {
		[self setHidden:YES];
	}
}

- (void)clear 
{
	[webView loadHTMLString:kClearHTML baseURL:nil];
}

- (NSString *)eval:(NSString *)javascript 
{
	return [webView stringByEvaluatingJavaScriptFromString:(NSString *)javascript];
}

- (void)webViewDidFinishLoad:(UIWebView *)_webView {
	DebugLog(@"iWWWView#webViewDidFinishLoad");
	[self stopLoading];
	int scrollY = [[NSUserDefaults standardUserDefaults] integerForKey:@"scrollY"];
	if (scrollY>0)
		[webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"window.scrollTo(0, %d);",scrollY]];
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
	DebugLog(@"iWWWView#webViewDidStartLoad");	
	[self startLoading];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
	DebugLog(@"iWWWView#didFailLoadWithError %@", [error localizedDescription]);	

	[self stopLoading];
	[self setHidden:YES];
	switch (error.code) {
		case NSURLErrorCannotFindHost:
			//[[ikooAlert instance] alert:@"Web" withMessage:@"Host not found."];
			break;
		case NSURLErrorTimedOut:
			//[[ikooAlert instance] alert:@"Web" withMessage:@"Timed out."];
			break;
		default:
			//NSLog(@"WebViewController#didFailWithError %@ code %i ", [error localizedDescription], error.code);			
			break;
	}//hide all other errors for now :) and be happy	
}

@end
