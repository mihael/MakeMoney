//
//  iContentView.h
//  MakeMoney

extern NSString *iContentViewURLNotification;

// UILabel methods are supported through forward invocation.

@interface iContentView : UIView 
{
	UIColor *normalColor;
	UIColor *highlightColor;

	UIImage *normalImage;
	UIImage *highlightImage;

	UILabel *label;
	
	BOOL linksEnabled;
}

@property (nonatomic, retain) UIColor *normalColor;
@property (nonatomic, retain) UIColor *highlightColor;

@property (nonatomic, retain) UIImage *normalImage;
@property (nonatomic, retain) UIImage *highlightImage;

@property (nonatomic, retain) UILabel *label;

@property (assign) BOOL linksEnabled;

- (void)setBackgroundColor:(UIColor *)backgroundColor;
- (void)setFrame:(CGRect)frame;
- (void)setFont:(UIFont*)_font;
- (void)setText:(NSString*)_text;
- (void)setNumberOfLines:(NSInteger)_numberOfLines;
- (void)setTextColor:(UIColor*)_textColor;
@end