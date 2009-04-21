//
//  IINotControls.h
//  MakeMoney
//

@protocol IINotControlsDelegate <NSObject>

- (void)leftTouch:(id)notControl; //left underbutton touch
- (void)rightTouch:(id)notControl; //right underbutton touch
//TODO- (void)spaceTouch; //empty space touch - can be while openNot
//TODO- (void)spaceSwipe; //empty space swipe - can be while openNot

- (void)oneTap:(id)notControl; //button tapped once

- (void)notControlsOpened:(id)notControl;//called when controls go open
- (void)notControlsClosed:(id)notControl;//called when controls go close

@end

//Imagine not control.
@interface IINotControls : UIView {
    id <IINotControlsDelegate> delegate;
    UIButton *button;
	UIButton *leftButton;
	UIButton *rightButton;
	BOOL notOpen;
	CGRect notControlsFrame;
	CGRect notControlsOneButtonFrame;
	NSTimer *wach;
	BOOL buttonInTouching;
	BOOL buttonNotLightUp;
	UIImageView *backLight;
}
@property (nonatomic, assign) id <IINotControlsDelegate> delegate;

//TODO- (void)spaceUp; open the space without underbuttons and let user change direction and speed of transending
//TODO- (void)spaceDown;

- (void)openOrCloseNotControls:(NSTimer*)timer;
- (void)lightUp;
- (void)lightDown;
- (void)lightUpOrDown;

- (void)openNot; //open controls - show underbuttons
- (void)closeNot;

- (void)setBackLight:(UIImage*)image withAlpha:(CGFloat)a;
- (void)hideBackLight;
- (void)showBackLight;

- (int)chooseOneFrom:(NSString*)jsonMemories; 

@end
