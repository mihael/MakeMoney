//
//  iProgressView.h
//  MakeMoney
//

@interface iProgressView : UIView {
	UIProgressView *progress;
	UIActivityIndicatorView *indica;
	UILabel *text;
	UIColor *fillColor;
	UIColor *strokeColor;
	UIColor *textColor;
}
- (id)initWithFrame:(CGRect)frame;
- (id)initWithFrame:(CGRect)frame text:(NSString*)t;
- (void)setProgress:(float)p;
- (void)setText:(NSString*)t;
- (void)setFill:(UIColor*)c;
- (void)setStroke:(UIColor*)c;
- (void)setTextColor:(UIColor*)c;

@end
