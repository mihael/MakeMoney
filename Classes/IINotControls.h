//
//  IINotControls.h
//  MakeMoney
//
#define kButtonAnimated NO
#define kButtonAnimationKey @"buttonViewAnimation"
#define kBackLightAnimationKey @"backLightViewAnimation"
#define kMessageFontName @"Helvetica-Bold"
#define kMessageFontSize 18.0

@protocol IINotControlsDelegate <NSObject>

- (void)leftTouch:(id)notControl; //left underbutton touch
- (void)rightTouch:(id)notControl; //right underbutton touch
//TODO- (void)spaceTouch; //empty space touch - can be while openNot
//TODO- (void)spaceSwipe; //empty space swipe - can be while openNot

- (void)oneTap:(id)notControl; //button tapped once

- (void)notControlsOpened:(id)notControl;//called when controls go open
- (void)notControlsClosed:(id)notControl;//called when controls go close

- (void)picked:(NSDictionary*)info;//returnes selected image,images
@end

//Imagine not control.
@interface IINotControls : UIView <UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>{
    id <IINotControlsDelegate> delegate;
	id notController;
    id pickDelegate;
	
    UIButton *button;
	UIButton *leftButton;
	UIButton *rightButton;
	UITextView *messageView;
	BOOL notOpen;
	CGRect notControlsFrame;
	CGRect notControlsOneButtonFrame;
	
	NSTimer *wach;
	BOOL buttonInTouching;
	BOOL buttonNotLightUp;
	UIImageView *backLight;
	BOOL canOpen;
	BOOL bigButton;
	UIView *underView;
}
@property (nonatomic, assign) id <IINotControlsDelegate> delegate;
@property (nonatomic, assign) id notController;
@property (nonatomic, assign) id pickDelegate;
@property (readwrite) BOOL canOpen;
@property (readwrite) BOOL bigButton;

- (id)initWithFrame:(CGRect)frame withOptions:(NSDictionary*)options;

- (void)pickInView:(UIView*)inView; //open image picker and let select

- (void)spaceUp; //open the space without 
- (void)spaceDown;

- (void)openOrCloseNotControls:(NSTimer*)timer;
- (void)lightUp;
- (void)lightDown;
- (void)lightUpOrDown;

- (void)openNot; //open controls - show underbuttons
- (void)closeNot;

- (void)spinButtonWith:(BOOL)direction;
- (void)stillButton;

//remove self from underView
- (void)unable;
//add self back to underView
- (void)able;


- (void)setBackLight:(UIImage*)image withAlpha:(CGFloat)a;
- (void)hideBackLight;
- (void)showBackLight;

- (void)showMessage:(NSString*)message;
- (void)hideMessage;

- (int)chooseOneFrom:(NSString*)jsonMemories; 

@end
