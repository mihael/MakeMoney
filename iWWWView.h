//
//  iWWWView.h
//  MakeMoney
//
@interface iWWWView : UIWebView {
	NSString* _url;
}

@property(nonatomic,copy) NSString* url;
//- (id)initWithFrame:(CGRect)frame;
- (id)initWithURL:(NSString*)url;
- (void)setUrl:(NSString*)url;
- (void)setYutubUrl:(NSString*)yutub_url;

@end
