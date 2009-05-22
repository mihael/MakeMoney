//
//  iProgressView.h
//  MakeMoney
//

@interface iProgressView : UIView {
	UIProgressView *progress;
	UIActivityIndicatorView *indica;
	UILabel *text;
}
- (id)initWithFrame:(CGRect)frame;
- (id)initWithFrame:(CGRect)frame text:(NSString*)t;
- (void)setProgress:(float)p;
- (void)setText:(NSString*)t;

@end
