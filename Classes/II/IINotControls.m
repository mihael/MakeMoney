//
//  IINotControls.m
//  MakeMoney
//
#import <QuartzCore/QuartzCore.h>
#import "IINotControls.h"
#import "MakeMoneyAppDelegate.h"
#import "iProgressView.h"
#import "iAccelerometerSensor.h"
#import "AudioStreamer.h"
#import "Reachability.h"

@implementation IINotControls
@synthesize notController, delegate, pickDelegate, notOpen, canOpen, bigButton, progressor, canSpaceTouch;
- (id)initWithFrame:(CGRect)frame withOptions:(NSDictionary*)options
{
    if (self = [super initWithFrame:frame]) {
		[self setBackgroundColor:[UIColor clearColor]];
		backLight = [[UIImageView alloc] initWithFrame:frame];
		[self addSubview:backLight];
		[self makeBackLight];
		[self hideBackLight];
		notOpen = YES;
		noButton = [[options valueForKey:@"no_button"] boolValue]; 
		canOpen = [[options valueForKey:@"button_opens_not_controls"] boolValue];
		bigButton = [[options valueForKey:@"big_button"] boolValue];
		buttonOnLeft = [[options valueForKey:@"button_on_left"] boolValue];		
		notControlsFrame = frame;
		
		NSUInteger buttonSize = kButtonSize;
		if (bigButton)
			buttonSize = kBigButtonSize;

		button = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
		NSUInteger x = frame.size.width - (2*kPadding+buttonSize);
		if (buttonOnLeft) {
			x = kPadding;
			notControlsOneButtonFrame = CGRectMake(0, 0, 2*kPadding+buttonSize, 2*kPadding+buttonSize);
		} else {
			//TODO this does not work anymore... button shows up only when self.frame is full screen
			notControlsOneButtonFrame = CGRectMake(x, 0, 2*kPadding+buttonSize, 2*kPadding+buttonSize);			
		}
		
		[button setFrame:CGRectMake(x, kPadding, buttonSize, buttonSize)];
		if (bigButton) {
			[button setImage:[UIImage imageNamed:@"bigbutton.png"] forState:UIControlStateNormal];
			[button setImage:[UIImage imageNamed:@"highbigbutton.png"] forState:UIControlStateHighlighted];
		} else {
			[button setImage:[UIImage imageNamed:@"button.png"] forState:UIControlStateNormal];
			[button setImage:[UIImage imageNamed:@"highbutton.png"] forState:UIControlStateHighlighted];		
		}
		[button addTarget:self action:@selector(buttonTouched) forControlEvents:UIControlEventTouchUpInside];
		[button addTarget:self action:@selector(buttonTouching) forControlEvents:UIControlEventTouchDown];

		
		leftButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
		[leftButton setFrame:CGRectMake(kPadding, frame.size.height - kLeftRightButtonSize - kPadding, kLeftRightButtonSize, kLeftRightButtonSize)];
		[leftButton setImage:[UIImage imageNamed:@"littlebutton.png"] forState:UIControlStateNormal];
		[leftButton setImage:[UIImage imageNamed:@"littlehighbutton.png"] forState:UIControlStateHighlighted];
		[leftButton addTarget:self action:@selector(leftButtonTouch) forControlEvents:UIControlEventTouchUpInside];

			
		actionButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
		[actionButton setFrame:CGRectMake((kLeftRightButtonSize + kPadding), frame.size.height - kLeftRightButtonSize - kPadding, kLeftRightButtonSize, kLeftRightButtonSize)];
		[actionButton setImage:[UIImage imageNamed:@"littlebutton.png"] forState:UIControlStateNormal];
		[actionButton setImage:[UIImage imageNamed:@"littlehighbutton.png"] forState:UIControlStateHighlighted];
		[actionButton addTarget:self action:@selector(actionButtonTouch) forControlEvents:UIControlEventTouchUpInside];
		
		rightButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
		[rightButton setFrame:CGRectMake(frame.size.width - kLeftRightButtonSize - kPadding, frame.size.height - kLeftRightButtonSize - kPadding, kLeftRightButtonSize, kLeftRightButtonSize)];
		[rightButton setImage:[UIImage imageNamed:@"littlebutton.png"] forState:UIControlStateNormal];
		[rightButton setImage:[UIImage imageNamed:@"littlehighbutton.png"] forState:UIControlStateHighlighted];
		[rightButton addTarget:self action:@selector(rightButtonTouch) forControlEvents:UIControlEventTouchUpInside];

		messageView = [[[UILabel alloc] initWithFrame:CGRectMake(2*kLeftRightButtonSize+2*kPadding, notControlsFrame.size.height - (kLeftRightButtonSize+2*kPadding), notControlsFrame.size.width - 2*(kLeftRightButtonSize+2*kPadding) - (kLeftRightButtonSize+kPadding), (kLeftRightButtonSize+2*kPadding))]retain];
		[messageView setBackgroundColor:[UIColor clearColor]];
		[messageView setTextAlignment:UITextAlignmentCenter];
		[messageView setTextColor:[UIColor whiteColor]];
		[messageView setFont:[UIFont fontWithName:kMessageFontName size:kMessageFontSize]];
		[messageView setText:@"OM OM OM"];
			
		progressor = [[iProgressView alloc] initWithFrame:self.frame text:nil];
		[progressor setHidden:YES];
		
		wwwView = [[iWWWView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
		[wwwView setHidden:YES];
		
		if (!noButton)
			[self addSubview:button];
		[self addSubview:leftButton];
		[self addSubview:actionButton];
		[self addSubview:rightButton];
		[self addSubview:wwwView];
		[self addSubview:progressor];
		[self closeNotControls]; //start closed
		
		canSpaceTouch = YES; //always send touches to delegate
		buttonInTouching = NO;
		buttonNotLightUp = YES;
		buttonInSpinning = NO;
		buttonSpinDirection = YES;

		[iAccelerometerSensor instance].delegate=self;
    }
    return self;
}

- (void)makeBackLight 
{
	NSString *currentLight = @"backlight.png";
	if ([Kriya isPad]) {
		if ([Kriya portrait]) {
			currentLight = @"vbacklight-pad.png";
		} else {
			currentLight = @"backlight-pad.png";
		}
	} else {
		if ([Kriya portrait]) {
			currentLight = @"vbacklight.png";
		} else {
			currentLight = @"backlight.png";
		}
	}
	[backLight setImage:[UIImage imageNamed:currentLight]];
}

- (void)layout:(CGRect)rect
{
	self.frame = rect;
	[backLight setFrame:rect];
	[self makeBackLight];
	notControlsFrame = rect;
	NSUInteger buttonSize = kButtonSize;
	if (bigButton)
		buttonSize = kBigButtonSize;
	
	NSUInteger x = rect.size.width - (2*kPadding+buttonSize);
	if (buttonOnLeft) {
		x = kPadding;
	}
	
	[button setFrame:CGRectMake(x, kPadding, buttonSize, buttonSize)];

	[leftButton setFrame:CGRectMake(kPadding, rect.size.height - kLeftRightButtonSize - kPadding, kLeftRightButtonSize, kLeftRightButtonSize)];

	[actionButton setFrame:CGRectMake((kLeftRightButtonSize + kPadding), rect.size.height - kLeftRightButtonSize - kPadding, kLeftRightButtonSize, kLeftRightButtonSize)];

	[rightButton setFrame:CGRectMake(rect.size.width - kLeftRightButtonSize - kPadding, rect.size.height - kLeftRightButtonSize - kPadding, kLeftRightButtonSize, kLeftRightButtonSize)];
	
	[messageView setFrame:CGRectMake(2*kLeftRightButtonSize+2*kPadding, notControlsFrame.size.height - (kLeftRightButtonSize+2*kPadding), notControlsFrame.size.width - 2*(kLeftRightButtonSize+2*kPadding) - (kLeftRightButtonSize+kPadding), (kLeftRightButtonSize+2*kPadding))];
	
	[progressor layout:rect];
	
	[wwwView setFrame:CGRectInset(rect, 57, 57)];
	
}

- (void)drawRect:(CGRect)rect 
{
	//magical time
}

- (void)dealloc 
{
	[backLight release];
	[wach release];
	[button release];
	[leftButton release];
	[rightButton release];
	[actionButton release];
    [super dealloc];
}

#pragma mark spinning
//spining button
- (void)spinButtonWith:(BOOL)direction
{
	buttonSpinDirection = direction;
	buttonInSpinning = YES;
	[self spinButton];
}

- (void)spinButton
{
	
	[CATransaction begin];
	[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
	CGRect frame = [button frame];
	button.layer.anchorPoint = CGPointMake(0.5, 0.5);
	button.layer.position = CGPointMake(frame.origin.x + 0.5 * frame.size.width, frame.origin.y + 0.5 * frame.size.height);
	[CATransaction commit];
	
	[CATransaction begin];
	[CATransaction setValue:(id)kCFBooleanFalse forKey:kCATransactionDisableActions];
	[CATransaction setValue:[NSNumber numberWithFloat:2.0] forKey:kCATransactionAnimationDuration];
	
	CABasicAnimation *animation;
	animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
	if (buttonSpinDirection) {
		animation.fromValue = [NSNumber numberWithFloat:2 * M_PI];
		animation.toValue = [NSNumber numberWithFloat:0.0];
	} else {
		animation.fromValue = [NSNumber numberWithFloat:0.0];
		animation.toValue = [NSNumber numberWithFloat:2 * M_PI];		
	}
	
	animation.timingFunction = [CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionEaseInEaseOut];
	animation.delegate = self;
	[button.layer addAnimation:animation forKey:@"rotationAnimation"];
	
	[CATransaction commit];
	
}

- (void)animationDidStart:(CAAnimation *)theAnimation
{
	DebugLog(@"button START");
}

- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)finished
{
	DebugLog(@"button STOP");
	if (finished&&buttonInSpinning)
	{
		DebugLog(@"button RESPIN");
		[self spinButton];
	}
}

- (void)stillButton
{
	buttonInSpinning = NO;
	[button.layer removeAllAnimations];
}


#pragma mark from superview remover
- (void)unable
{
	//remove self from superview, but save superview
	if ([self superview]) {
		underView = [self superview];
		[self removeFromSuperview];
	}

}

- (void)able
{
	//if superview is saved exists add self to it
	if (underView)
		[underView addSubview:self];
		
}

#pragma mark BackLight animations
- (void)animateBackLightIn 
{
	CATransition *animation = [CATransition animation];
	[animation setType:kCATransitionMoveIn];
	[animation setDuration:0.5];
	[animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
	[animation setSubtype:kCATransitionFromTop];
	[[backLight layer] addAnimation:animation forKey:kBackLightAnimationKey];
}

- (void)animateBackLightOut 
{
	CATransition *animation = [CATransition animation];
	[animation setType:kCATransitionPush];
	[animation setDuration:0.5];
	[animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
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

#pragma mark button animations
- (void)animateButtonsIn 
{
	CATransition *animation = [CATransition animation];
	[animation setType:kCATransitionMoveIn];
	[animation setDuration:0.5];
	[animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
	[[leftButton layer] addAnimation:animation forKey:kButtonAnimationKey];
	[[actionButton layer] addAnimation:animation forKey:kButtonAnimationKey];
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
	[[actionButton layer] addAnimation:animation forKey:kButtonAnimationKey];
	[animation setSubtype:kCATransitionFromLeft];
	[[rightButton layer] addAnimation:animation forKey:kButtonAnimationKey];
}
#pragma mark empty space
- (void)spaceUp  //open the space without 
{
	[self setFrame:notControlsFrame];
}

- (void)spaceDown
{
	[self setFrame:notControlsOneButtonFrame];
}


#pragma mark opening and closing
- (void)openNotControls 
{
	if (canOpen)
	{
		leftButton.hidden = NO;
		actionButton.hidden = NO;
		rightButton.hidden = NO;
		notOpen = NO;
		[self animateButtonsIn];
		[self spaceUp];
		if (delegate) {
			if ([delegate respondsToSelector:@selector(notControlsOpened:)]) {
				[delegate notControlsOpened:self];
			}
		}
	}
}

- (void)closeNotControls
{
	leftButton.hidden = YES;
	actionButton.hidden = YES;
	rightButton.hidden = YES;
	notOpen = YES;
	[self animateButtonsOut];
	[self spaceDown];
	if (delegate) {
		if ([delegate respondsToSelector:@selector(notControlsClosed:)]) {
			[delegate notControlsClosed:self];
		}
	}
}

#pragma mark button light 
- (void)animateLightUp 
{
	if (kButtonAnimated) {
		CATransition *animation = [CATransition animation];
		[animation setType:kCATransitionFade];
		[animation setDuration:kLightSpeed];
		[animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
		[[button layer] addAnimation:animation forKey:kButtonAnimationKey];
	}
}

- (void)lightDown 
{
	if (bigButton) {
		[button setBackgroundImage:[UIImage imageNamed:@"bigbutton.png"] forState:UIControlStateNormal];
	} else {
		[button setBackgroundImage:[UIImage imageNamed:@"button.png"] forState:UIControlStateNormal];
	}

	buttonNotLightUp = YES;
}

- (void)lightUp 
{
	if (bigButton) {
		[button setBackgroundImage:[UIImage imageNamed:@"highbigbutton.png"] forState:UIControlStateNormal];
	} else {
		[button setBackgroundImage:[UIImage imageNamed:@"highbutton.png"] forState:UIControlStateNormal];
	}
//	[button setBackgroundImage:[UIImage imageNamed:@"highbutton.png"] forState:UIControlStateNormal];
	buttonNotLightUp = NO;
	[self animateLightUp];
}

- (void)lightUpOrDown 
{
	if (buttonNotLightUp) { //light it up then
		if (bigButton) {
			[button setBackgroundImage:[UIImage imageNamed:@"highbigbutton.png"] forState:UIControlStateNormal];
		} else {
			[button setBackgroundImage:[UIImage imageNamed:@"highbutton.png"] forState:UIControlStateNormal];
		}
		buttonNotLightUp = NO;
	} else {
		if (bigButton) {
			[button setBackgroundImage:[UIImage imageNamed:@"bigbutton.png"] forState:UIControlStateNormal];
		} else {
			[button setBackgroundImage:[UIImage imageNamed:@"button.png"] forState:UIControlStateNormal];
		}
		buttonNotLightUp = YES;
	}
}

#pragma mark opening closing notControls
- (void)openOrClose 
{
	if (notOpen) {
		//[button setBackgroundImage:[UIImage imageNamed:@"highbutton.png"] forState:UIControlStateNormal];
		[self openNotControls];
	} else {
		//[button setBackgroundImage:[UIImage imageNamed:@"button.png"] forState:UIControlStateNormal];
		[self closeNotControls];
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
			//hide www if open
			if (![wwwView isHidden])
				[self wwwClear];
			
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
- (void)actionButtonTouch {
	if (delegate) {
		if ([delegate respondsToSelector:@selector(actionTouch:)]) {
			[delegate actionTouch:self];
		}
	}
}

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

#pragma mark progressor 
- (void)setProgress:(NSString*)progress animated:(BOOL)animated 
{
	if ([progressor isHidden])
	{
		if (progress!=nil) { //show and set text
			[self setCanSpaceTouch:NO];
			[self spaceUp];
			[progressor setHidden:NO];
			[progressor setText:progress];
			if (animated)
				[self animateProgressorIn];			
		}
	} else { //not hidden
		if (progress==nil) { //remove progressor if nil progress sent
			[progressor setHidden:YES];
			if (animated)
				[self animateProgressorOut];
			[self spaceDown];
			[self setCanSpaceTouch:YES];			
		} else { //change text 
			[progressor setText:progress];
			if (animated)
				[self animateProgressorChange];
		}
	}
}

- (void)animateProgressorChange
{
	[CATransaction begin];
	[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
	CGRect frame = [progressor frame];
	progressor.layer.anchorPoint = CGPointMake(0.5, 0.5);
	progressor.layer.position = CGPointMake(frame.origin.x + 0.5 * frame.size.width, frame.origin.y + 0.5 * frame.size.height);
	[CATransaction commit];
	
	[CATransaction begin];
	[CATransaction setValue:(id)kCFBooleanFalse forKey:kCATransactionDisableActions];
	[CATransaction setValue:[NSNumber numberWithFloat:2.0] forKey:kCATransactionAnimationDuration];
	
	CABasicAnimation *animation;
	animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
	int r = arc4random() % 33;

	if (r%2 == 0) {
		animation.fromValue = [NSNumber numberWithFloat:2 * M_PI];
		animation.toValue = [NSNumber numberWithFloat:0.0];
	} else {
		DebugLog(@"RIGHT");
		animation.fromValue = [NSNumber numberWithFloat:0.0];
		animation.toValue = [NSNumber numberWithFloat:2 * M_PI];		
	}
	
	animation.timingFunction = [CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionLinear];
	//animation.delegate = self;
	[progressor.layer addAnimation:animation forKey:@"progressorChangeAnimation"];
	
	[CATransaction commit];
}

- (void)animateProgressorIn 
{
	CATransition *animation = [CATransition animation];
	[animation setType:kCATransitionMoveIn];
	[animation setSubtype:kCATransitionFromTop];
	[animation setDuration:0.38];
	[animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
	[[progressor layer] addAnimation:animation forKey:kProgressorAnimationKey];
}

- (void)animateProgressorOut 
{
	CATransition *animation = [CATransition animation];
	[animation setType:kCATransitionMoveIn];
	[animation setSubtype:kCATransitionFromBottom];
	[animation setDuration:0.38];
	[animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
	[animation setSubtype:kCATransitionFromRight];
	[[progressor layer] addAnimation:animation forKey:kProgressorAnimationKey];
}
#pragma mark messages
- (void)animateMessageIn 
{
	CATransition *animation = [CATransition animation];
	[animation setType:kCATransitionMoveIn];
	[animation setDuration:0.5];
	[animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
	[[messageView layer] addAnimation:animation forKey:kBackLightAnimationKey];
	[animation setSubtype:kCATransitionFromTop];
	[[messageView layer] addAnimation:animation forKey:kBackLightAnimationKey];
}

- (void)animateMessageOut 
{
	CATransition *animation = [CATransition animation];
	[animation setType:kCATransitionPush];
	[animation setDuration:0.5];
	[animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
	[animation setSubtype:kCATransitionFromRight];
	[[messageView layer] addAnimation:animation forKey:kBackLightAnimationKey];
	[animation setSubtype:kCATransitionFromBottom];
	[[messageView layer] addAnimation:animation forKey:kBackLightAnimationKey];
}

- (void)showMessage:(NSString*)message 
{
	if (!notOpen) {
		[messageView setText:message];
		if (![messageView superview]) {
			[self addSubview:messageView];
			[self animateMessageIn];
		}
	}
}

- (void)hideMessage 
{
	if (notOpen) {	
		if ([messageView superview]) {
			[messageView removeFromSuperview];
			[self animateMessageOut];			
		}
	}
}

#pragma mark picking images
- (void)pickInView:(UIView*)inView 
{
	UIActionSheet *as = [[[UIActionSheet alloc] initWithFrame:inView.frame] autorelease];
	[as setActionSheetStyle:UIActionSheetStyleBlackTranslucent];
	int cancelButtonIndex = 1;
	
	[as addButtonWithTitle:@"Select photo from library"];//0
	if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
		[as addButtonWithTitle:@"Take photo with camera"];//1
		cancelButtonIndex = 2;
	}
	[as addButtonWithTitle:@"Cancel"];//2
	
	[as setCancelButtonIndex:cancelButtonIndex];
	
	[as setDelegate:self];
	[as showInView:inView];
	
}

#pragma mark UIActionSheetDelegate methods
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (notController) {
		UIImagePickerController *picker = [[[UIImagePickerController alloc] init] autorelease];
		[picker setDelegate:self];
		[picker setAllowsEditing:NO];
		//[[picker navigationBar] setHidden:NO];	
		//[picker setModalTransitionStyle:UIModalTransitionStyleFlipHorizontal];
		
		switch (buttonIndex) {
			case 1:
				if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
					[picker setSourceType:UIImagePickerControllerSourceTypeCamera];			
					[notController presentModalViewController:picker animated:YES];
				}
				break;
			case 0:
				[picker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];			
				[notController presentModalViewController:picker animated:YES];
				break;
			default:		
				break;
		}	
	}
}

#pragma mark UIImagePickerControllerDelegate methods
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info 
{
	[picker dismissModalViewControllerAnimated:YES];
	UIImage* image = [info objectForKey:UIImagePickerControllerOriginalImage];
	DebugLog(@"Picked image: w=%f, h=%f", image.size.width, image.size.height);
	if (image) {
		if (pickDelegate)
			[pickDelegate picked:info];
	}
}

/*
 - (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo {
 [picker dismissModalViewControllerAnimated:YES];
 DebugLog(@"Picked image for sending to pikchur: w=%f, h=%f", image.size.width, image.size.height);
 //NSLog(@"what else do we have %@", editingInfo);
 if (image) {
 [www uploadWithPikchur:image withDescription:@"raddarkopter" andLocation:location];
 }
 }*/

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
	[picker dismissModalViewControllerAnimated:YES];
	if (pickDelegate)
		[pickDelegate picked:nil];
}

#pragma mark iAccelerometerSensorDelegate
- (void)accelerometerDetected 
{
	if (delegate) {
		if ([delegate respondsToSelector:@selector(shake:)]) {
			[delegate shake:self];
		}
	}
}

#pragma mark touches
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event 
{
    UITouch *touch = [touches anyObject];
	if([touch tapCount] >= 2) {
        // Process a double-tap gesture
		if (delegate) {
			if (canSpaceTouch&&[delegate respondsToSelector:@selector(spaceTouch:)]) {
				[delegate spaceDoubleTouch:self touchPoint:[touch locationInView:self]];
			}
		}
    } else {
		if (delegate) {
			if (canSpaceTouch&&[delegate respondsToSelector:@selector(spaceTouch:touchPoint:)]) {
				DebugLog(@"TOUCH");				
				[delegate spaceTouch:self touchPoint:[touch locationInView:self]];
			}
		}
	}
	
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    startTouchPosition = [touch locationInView:self];
	moveCount = 0;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	if (delegate) {
		UITouch *touch = [touches anyObject];
		CGPoint currentTouchPosition = [touch locationInView:self];
		// If the swipe tracks correctly.
		if (fabsf(startTouchPosition.x - currentTouchPosition.x) >= kHorizontalSwipeDragMin &&
			fabsf(startTouchPosition.y - currentTouchPosition.y) <= kVerticalSwipeDragMax)
		{
			moveCount++;
			// It appears to be a swipe.
			if (moveCount==1) { //only send swipe once
				if (startTouchPosition.x < currentTouchPosition.x) {
					if ([delegate respondsToSelector:@selector(spaceTouch:touchPoint:)]) {
						[delegate spaceSwipeLeft:self];
					}
				} else {
					if ([delegate respondsToSelector:@selector(spaceTouch:touchPoint:)]) {
						[delegate spaceSwipeRight:self];
					}
				}
			}
		} else {
			// Process a non-swipe event.
		}
	}
}

#pragma mark Streamer
- (void)playStop { //stop playing
	if (streamer)
		[streamer stop];
}

- (void)playWithStreamUrl:(NSString*)url
{
	if (!streamer)
	{
		if ([[Reachability sharedReachability] internetConnectionStatus]!=NotReachable) {
			NSString *escapedValue =
			[(NSString *)CFURLCreateStringByAddingPercentEscapes(
																 nil,
																 (CFStringRef)url,
																 NULL,
																 NULL,
																 kCFStringEncodingUTF8)
			 autorelease];
			
			NSURL *stream_url = [NSURL URLWithString:escapedValue];
			streamer = [[AudioStreamer alloc] initWithURL:stream_url];
			[streamer
			 addObserver:self
			 forKeyPath:@"isPlaying"
			 options:0
			 context:nil];
			[streamer start];
		}
	} else	{
		[streamer stop];
	}
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
						change:(NSDictionary *)change context:(void *)context
{
	if ([keyPath isEqual:@"isPlaying"])
	{
		NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
		
		if ([(AudioStreamer *)object isPlaying]) {
			//do nothing while playing stream
		} else	{ //release otherways?
			[streamer removeObserver:self forKeyPath:@"isPlaying"];
			[streamer release];
			streamer = nil;
		}
		
		[pool release];
		return;
	}
	
	[super observeValueForKeyPath:keyPath ofObject:object change:change
						  context:context];
}

#pragma mark WWW
- (void)wwwWithNSURL:(NSURL*)nsurl
{
	[wwwView setHidden:NO];
	[wwwView setNSURL:nsurl];
}

- (void)wwwWithUrl:(NSString*)url 
{
	[wwwView setHidden:NO];
	[wwwView setUrl:url];
}

- (void)wwwWithYutubUrl:(NSString*)yutub_url 
{
	[wwwView setHidden:NO];
	[wwwView setYutubUrl:yutub_url];
}

- (NSString*)wwwEval:(NSString *)javascript
{
	return [wwwView eval:javascript];
}

- (void)wwwClear 
{
	[wwwView setHidden:YES];
}

@end
