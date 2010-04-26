//
//  iIconView.h
//  MakeMoney
//
@interface iIconView : UIButton {
	CGImageRef imageRef;
	CGFloat roundSize;
	CGFloat alpha;
	NSString *imageUrl;
	BOOL observing;
}
//if you have the image ready use this
- (id)initWithFrame:(CGRect)rect image:(UIImage*)image round:(CGFloat)r alpha:(CGFloat)a;

//can be used to display after it was downloaded
//it listens for notification with name: iconWithUrlFinished
//if the url from notification is the same as imageUrl then display
- (id)initWithFrame:(CGRect)rect imageUrl:(NSString*)url round:(CGFloat)r alpha:(CGFloat)a;
- (void)imageUrlAvailable:(NSNotification *)notification;

- (void)fetchImage;
- (void)fetchImageFinished:(id)response;
- (void)fetchImageFailed:(id)response;
- (void)setImage:(UIImage*)image;
- (void)setImageUrl:(NSString*)image_url;
- (void)setRound:(CGFloat)r;
- (void)setAlpha:(CGFloat)a;

@end
