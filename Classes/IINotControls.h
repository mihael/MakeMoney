//
//  IINotControls.h
//  MakeMoney
//
#import "iProgressView.h"
#import "iAccelerometerSensor.h"
#import "AudioStreamer.h"
#import "iWWWView.h"
#import "iIconView.h"

#define kProgressorAnimationKey @"progressorViewAnimation"
#define kButtonAnimated NO
#define kButtonAnimationKey @"buttonViewAnimation"
#define kBackLightAnimationKey @"backLightViewAnimation"
#define kMessageFontName @"Helvetica-Bold"
#define kMessageFontSize 18.0

#define kHorizontalSwipeDragMin  12
#define kVerticalSwipeDragMax 4

@protocol IINotControlsDelegate <NSObject>
- (void)shake:(id)notControl;//device was shaked

- (void)leftTouch:(id)notControl; //left underbutton touch
- (void)rightTouch:(id)notControl; //right underbutton touch
- (void)spaceTouch:(id)notControl touchPoint:(CGPoint)point; //empty space touch - can be while openNot && spaceUp
- (void)spaceDoubleTouch:(id)notControl touchPoint:(CGPoint)point; //empty space double touch - can be while openNot && spaceUp
- (void)spaceSwipeRight:(id)notControl; //empty space swipe - can be while openNot
- (void)spaceSwipeLeft:(id)notControl; //empty space swipe - can be while openNot
//- (void)spacePinch:(CGPoint)touchPoint; //empty space swipe - can be while openNot
//- (void)spaceSwipe:(CGPoint)touchPoint; //empty space swipe - can be while openNot

- (void)oneTap:(id)notControl; //button tapped once

- (void)notControlsOpened:(id)notControl;//called when controls go open
- (void)notControlsClosed:(id)notControl;//called when controls go close

- (void)picked:(NSDictionary*)info;//returnes selected image,images
@end

@class iProgressView;
@class AudioStreamer;
@class iWWWView;
@class iIconView;

//Imagine not control.
@interface IINotControls : UIView <iAccelerometerSensorDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>{
    id <IINotControlsDelegate> delegate;
	id notController;
    id pickDelegate;
	
    UIButton *button;
	UIButton *leftButton;
	UIButton *rightButton;
	UILabel *messageView;
	CGRect notControlsFrame;
	CGRect notControlsOneButtonFrame;
	UIImageView *backLight;
	NSTimer *wach;	
	UIView *underView;
	iProgressView *progressor;
	AudioStreamer *streamer;
	iWWWView *wwwView;
	
	CGPoint startTouchPosition;
	BOOL buttonInTouching;
	BOOL buttonNotLightUp;
	BOOL buttonOnLeft;
	BOOL notOpen;
	BOOL canOpen;
	BOOL bigButton;
	BOOL canSpaceTouch;
	
}
@property (nonatomic, assign) id <IINotControlsDelegate> delegate;
@property (nonatomic, assign) id notController;
@property (nonatomic, assign) id pickDelegate;
@property (readonly) BOOL notOpen;
@property (readwrite) BOOL canOpen;
@property (readwrite) BOOL bigButton;
@property (readwrite) BOOL canSpaceTouch;
@property (readonly) iProgressView *progressor;

- (id)initWithFrame:(CGRect)frame withOptions:(NSDictionary*)options;
- (void)layout:(CGRect)rect;

- (void)pickInView:(UIView*)inView; //open image picker and let select

//noise streamer
- (void)playWithStreamUrl:(NSString*)url; //play background noises
- (void)playStop; //stop playing

//www display
- (void)wwwWithYutubUrl:(NSString*)yutub_url;
- (void)wwwWithUrl:(NSString*)url;
- (void)wwwClear;

//the space without is the topmost view, the view where the button lies
- (void)spaceUp; //open the space without 
- (void)spaceDown;

//can use for simple messages with activity indica
//shows transparent panel with indica and text above, when set to nil, hides
//the progressor view always brings up the space without, so nobody can tap other buttons while displayed
- (void)setProgress:(NSString*)progress animated:(BOOL)animated;
- (void)animateProgressorIn;
- (void)animateProgressorOut;
- (void)animateProgressorChange;




- (void)openOrCloseNotControls:(NSTimer*)timer;
- (void)lightUp;
- (void)lightDown;
- (void)lightUpOrDown;

- (void)openNotControls; //open controls - show underbuttons
- (void)closeNotControls;

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

- (void)accelerometerDetected;

//touching overrides
//- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
//- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;
//- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event

@end
