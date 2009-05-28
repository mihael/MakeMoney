//
//  iIconView.h
//  MakeMoney
//
@interface iIconView : UIButton {
	CGImageRef imageRef;
	CGFloat roundSize;
	CGFloat alpha;
}
- (id)initWithFrame:(CGRect)rect image:(UIImage*)image round:(CGFloat)r alpha:(CGFloat)a;
- (void)setImage:(UIImage*)image;
- (void)setRound:(CGFloat)r;
- (void)setAlpha:(CGFloat)a;

@end
