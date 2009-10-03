//
//  iWWWView.h
//  MakeMoney
//
@interface iWWWView : UIView <UIWebViewDelegate>{
	NSString* _url;
	UIWebView *webView;
	UIActivityIndicatorView *indica;
	UIButton *closeButton;
	UIButton *actionButton;
}

@property(nonatomic,copy) NSString* url;
//- (id)initWithFrame:(CGRect)frame;
- (id)initWithURL:(NSString*)url;
- (id)initWithFrame:(CGRect)frame;

- (void)setUrl:(NSString*)url;
- (void)setYutubUrl:(NSString*)yutub_url;
- (void)clear;
@end
