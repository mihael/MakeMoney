//
//  IINotControls.m
//  MakeMoney
//
#import <QuartzCore/QuartzCore.h>
#import "IINotControls.h"
#import "MakeMoneyAppDelegate.h"
#define kButtonAnimationKey @"buttonViewAnimation"
#define kBackLightAnimationKey @"backLightViewAnimation"

@implementation IINotControls
@synthesize delegate;

- (id)initWithFrame:(CGRect)frame 
{
    if (self = [super initWithFrame:frame]) {
		[self setBackgroundColor:[UIColor clearColor]];
		backLight = [[[UIImageView alloc] initWithFrame:frame] retain];
		[self addSubview:backLight];
		[self hideBackLight];
		
		notControlsFrame = frame;
		notControlsOneButtonFrame = CGRectMake(0, 0, kPadding + kButtonSize + kPadding, kPadding + kButtonSize + kPadding);

		button = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
		[button setFrame:CGRectMake(kPadding, kPadding, kButtonSize, kButtonSize)];
		[button setImage:[UIImage imageNamed:@"button.png"] forState:UIControlStateNormal];
		[button setImage:[UIImage imageNamed:@"highbutton.png"] forState:UIControlStateHighlighted];
		[button addTarget:self action:@selector(buttonTouched) forControlEvents:UIControlEventTouchUpInside];
		[button addTarget:self action:@selector(buttonTouching) forControlEvents:UIControlEventTouchDown];

		
		leftButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
		[leftButton setFrame:CGRectMake(kPadding, frame.size.height - kLeftRightButtonSize - kPadding, kLeftRightButtonSize, kLeftRightButtonSize)];
		[leftButton setImage:[UIImage imageNamed:@"littlebutton.png"] forState:UIControlStateNormal];
		[leftButton setImage:[UIImage imageNamed:@"littlehighbutton.png"] forState:UIControlStateHighlighted];
		[leftButton addTarget:self action:@selector(leftButtonTouch) forControlEvents:UIControlEventTouchUpInside];

		rightButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
		[rightButton setFrame:CGRectMake(frame.size.width - kLeftRightButtonSize - kPadding, frame.size.height - kLeftRightButtonSize - kPadding, kLeftRightButtonSize, kLeftRightButtonSize)];
		[rightButton setImage:[UIImage imageNamed:@"littlebutton.png"] forState:UIControlStateNormal];
		[rightButton setImage:[UIImage imageNamed:@"littlehighbutton.png"] forState:UIControlStateHighlighted];
		[rightButton addTarget:self action:@selector(rightButtonTouch) forControlEvents:UIControlEventTouchUpInside];

		[self addSubview:button];
		[self addSubview:leftButton];
		[self addSubview:rightButton];
		[self closeNot];
		buttonInTouching = NO;
		buttonNotLightUp = YES;
    }
    return self;
}

- (void)drawRect:(CGRect)rect 
{
	//magical time
}

#pragma mark BackLight animations
- (void)animateBackLightIn 
{
	CATransition *animation = [CATransition animation];
	[animation setType:kCATransitionMoveIn];
	[animation setDuration:0.5];
	[animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
	[[backLight layer] addAnimation:animation forKey:kBackLightAnimationKey];
	[animation setSubtype:kCATransitionFromTop];
	[[backLight layer] addAnimation:animation forKey:kBackLightAnimationKey];
}

- (void)animateBackLightOut 
{
	CATransition *animation = [CATransition animation];
	[animation setType:kCATransitionPush];
	[animation setDuration:0.5];
	[animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
	[animation setSubtype:kCATransitionFromRight];
	[[backLight layer] addAnimation:animation forKey:kBackLightAnimationKey];
	[animation setSubtype:kCATransitionFromBottom];
	[[backLight layer] addAnimation:animation forKey:kBackLightAnimationKey];
}

#pragma mark BackLight
- (void)setBackLight:(UIImage*)image withAlpha:(CGFloat)a {
	if (image) {
		[backLight setImage:image];
		[backLight setAlpha:a];
	}
}

- (void)hideBackLight 
{
	[backLight setHidden:YES];
	[self animateBackLightOut];
}

- (void)showBackLight 
{
	[backLight setHidden:NO];
	[self animateBackLightIn];
}


- (void)dealloc 
{
	[backLight release];
	if (wach) 
		[wach release];
	[button release];
	[leftButton release];
	[rightButton release];
    [super dealloc];
}

#pragma mark button animations
- (void)animateButtonsIn 
{
	CATransition *animation = [CATransition animation];
	[animation setType:kCATransitionMoveIn];
	[animation setDuration:0.5];
	[animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
	[[leftButton layer] addAnimation:animation forKey:kButtonAnimationKey];
	[animation setSubtype:kCATransitionFromRight];
	[[rightButton layer] addAnimation:animation forKey:kButtonAnimationKey];
}

- (void)animateButtonsOut 
{
	CATransition *animation = [CATransition animation];
	[animation setType:kCATransitionPush];
	[animation setDuration:0.5];
	[animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
	[animation setSubtype:kCATransitionFromRight];
	[[leftButton layer] addAnimation:animation forKey:kButtonAnimationKey];
	[animation setSubtype:kCATransitionFromLeft];
	[[rightButton layer] addAnimation:animation forKey:kButtonAnimationKey];
}

#pragma mark opening and closing
- (void)openNot 
{
	leftButton.hidden = NO;
	rightButton.hidden = NO;
	notOpen = NO;
	[self animateButtonsIn];
	[self setFrame:notControlsFrame];
	if (delegate) {
		if ([delegate respondsToSelector:@selector(notControlsOpened:)]) {
			[delegate notControlsOpened:self];
		}
	}
}

- (void)closeNot 
{
	leftButton.hidden = YES;
	rightButton.hidden = YES;
	notOpen = YES;
	[self animateButtonsOut];
	[self setFrame:notControlsOneButtonFrame];
	if (delegate) {
		if ([delegate respondsToSelector:@selector(notControlsClosed:)]) {
			[delegate notControlsClosed:self];
		}
	}
}

#pragma mark button light 
- (void)animateLightUp 
{
	CATransition *animation = [CATransition animation];
	[animation setType:kCATransitionFade];
	[animation setDuration:kLightSpeed];
	[animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
	[[button layer] addAnimation:animation forKey:kButtonAnimationKey];
}

- (void)lightDown 
{
	[button setBackgroundImage:[UIImage imageNamed:@"button.png"] forState:UIControlStateNormal];
	buttonNotLightUp = YES;
}

- (void)lightUp 
{
	[button setBackgroundImage:[UIImage imageNamed:@"highbutton.png"] forState:UIControlStateNormal];
	buttonNotLightUp = NO;
	[self animateLightUp];
}

- (void)lightUpOrDown 
{
	if (buttonNotLightUp) {
		[button setBackgroundImage:[UIImage imageNamed:@"highbutton.png"] forState:UIControlStateNormal];
		buttonNotLightUp = NO;
	} else {
		[button setBackgroundImage:[UIImage imageNamed:@"button.png"] forState:UIControlStateNormal];
		buttonNotLightUp = YES;
	}
}

#pragma mark opening closing notControls
- (void)openOrClose 
{
	if (notOpen) {
		//[button setBackgroundImage:[UIImage imageNamed:@"highbutton.png"] forState:UIControlStateNormal];
		[self openNot];
	} else {
		//[button setBackgroundImage:[UIImage imageNamed:@"button.png"] forState:UIControlStateNormal];
		[self closeNot];
	}	
}

- (void)openOrCloseNotControls:(NSTimer*)timer 
{
	if (wach) {
		[wach invalidate];
		[wach release];
		wach = nil;
	}
	[self openOrClose];
}

#pragma mark touching button
- (void)buttonTouched 
{
	//this is called when touches up
	if (notOpen) { //the controls do not show their underbuttons
		if (buttonInTouching) { //if touched up inside before 1.0sec, means we just tapped once
			//call delegate and tell him about this simple tap
			if (delegate) {
				if ([delegate respondsToSelector:@selector(oneTap:)]) {
					[delegate oneTap:self];
				}
			}
			//invalidate timer, we do not want to open notcontrols
			[wach invalidate];
			[wach release];
			wach = nil;
		}
	} else { //the controls are open and showing their underbuttons		
		if (buttonInTouching) {
			buttonInTouching = NO;//just stop touching if we were just opened 
		} else {
			[self openOrClose]; //one tap closes not controls if is open
		}
	}
}

- (void)buttonTouching 
{
	if (notOpen) { //start timer only if controls do not show buttons
		buttonInTouching = YES;
		wach = [[NSTimer scheduledTimerWithTimeInterval:kButtonSpeed
												 target:self 
											   selector:@selector(openOrCloseNotControls:)
											   userInfo:nil
												repeats:NO] retain];	
	}
}

#pragma mark underbuttons
- (void)leftButtonTouch 
{
	if (delegate) {
		if ([delegate respondsToSelector:@selector(leftTouch:)]) {
			[delegate leftTouch:self];
		}
	}
}

- (void)rightButtonTouch 
{
	if (delegate) {
		if ([delegate respondsToSelector:@selector(rightTouch:)]) {
			[delegate rightTouch:self];
		}
	}
}

#pragma mark choices
- (int)chooseOneFrom:(NSString*)jsonMemories
{
	//TODO
	return 1;
}



@end
