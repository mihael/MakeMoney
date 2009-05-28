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

- (void)dealloc {
	[_url release];
	[super dealloc];
}

- (void)layoutSubviews {
	[self stringByEvaluatingJavaScriptFromString:
	 [NSString stringWithFormat:@"yt.width = %0.0f; yt.height = %0.0f", self.frame.size.width, self.frame.size.height]];
}

- (void)setUrl:(NSString*)url {
	[_url release];
	_url = [url copy];
	
	if (_url) {
		NSString* html = [NSString stringWithFormat:kEmbedHTML, self.frame.size.width, self.frame.size.width,
						  self.frame.size.height, _url, _url, self.frame.size.width, self.frame.size.height];
		[self loadHTMLString:html baseURL:nil];
	} else {
		[self loadHTMLString:@"&nbsp;" baseURL:nil];
	}
}

- (void)setYutubUrl:(NSString*)yutub_url {
	[_url release];
	_url = [yutub_url copy];
	
	if (_url) {
		NSString* html = [NSString stringWithFormat:kEmbedHTML, self.frame.size.width, self.frame.size.width,
						  self.frame.size.height, _url, _url, self.frame.size.width, self.frame.size.height];
		[self loadHTMLString:html baseURL:nil];
	} else {
		[self loadHTMLString:@"&nbsp;" baseURL:nil];
	}
}

- (void)clear 
{
	[self loadHTMLString:kClearHTML baseURL:nil];
}

@end
