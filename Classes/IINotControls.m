//
//  IINotControls.m
//  MakeMoney
//
#import <QuartzCore/QuartzCore.h>
#import "IINotControls.h"
#import "MakeMoneyAppDelegate.h"

@implementation IINotControls
@synthesize notController, delegate, pickDelegate, canOpen, bigButton;

- (id)initWithFrame:(CGRect)frame withOptions:(NSDictionary*)options
{
    if (self = [super initWithFrame:frame]) {
		[self setBackgroundColor:[UIColor clearColor]];
		backLight = [[[UIImageView alloc] initWithFrame:frame] retain];
		[self addSubview:backLight];
		[self hideBackLight];
		canOpen = [[options valueForKey:@"button_opens_not_controls"]boolValue];
		bigButton = [[options valueForKey:@"big_button"]boolValue];
		notControlsFrame = frame;
		
		NSUInteger buttonSize = kButtonSize;
		if (bigButton)
			buttonSize = kBigButtonSize;
		
		notControlsOneButtonFrame = CGRectMake(0, 0, kPadding + buttonSize + kPadding, kPadding + buttonSize + kPadding);
		
		button = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
		NSUInteger x = frame.size.width - (2*kPadding+buttonSize);
		if ([[options valueForKey:@"button_on_left"] boolValue]) 
			x = kPadding;
		
		[button setFrame:CGRectMake(x, kPadding, buttonSize, kButtonSize)];
		if (bigButton) {
			[button setImage:[UIImage imageNamed:@"button.png"] forState:UIControlStateNormal];
			[button setImage:[UIImage imageNamed:@"highbutton.png"] forState:UIControlStateHighlighted];
		} else {
			[button setImage:[UIImage imageNamed:@"littlebutton.png"] forState:UIControlStateNormal];
			[button setImage:[UIImage imageNamed:@"littlehighbutton.png"] forState:UIControlStateHighlighted];		
		}
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

		messageView = [[[UITextView alloc] initWithFrame:CGRectMake(kLeftRightButtonSize+2*kPadding, notControlsFrame.size.height - (kLeftRightButtonSize+2*kPadding), notControlsFrame.size.width - 2*(kLeftRightButtonSize+2*kPadding), (kLeftRightButtonSize+2*kPadding))]retain];
		[messageView setBackgroundColor:[UIColor clearColor]];
		[messageView setTextAlignment:UITextAlignmentCenter];
		[messageView setTextColor:[UIColor whiteColor]];
		[messageView setFont:[UIFont fontWithName:kMessageFontName size:kMessageFontSize]];
		[messageView setText:@"OM OM OM"];
		
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

//spining button
- (void)spinButtonWith:(BOOL)direction
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
	if (direction) {
		animation.fromValue = [NSNumber numberWithFloat:2 * M_PI];
		animation.toValue = [NSNumber numberWithFloat:0.0];
	} else {
		animation.fromValue = [NSNumber numberWithFloat:0.0];
		animation.toValue = [NSNumber numberWithFloat:2 * M_PI];		
	}

	animation.timingFunction = [CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionLinear];
	//animation.delegate = self;
	[button.layer addAnimation:animation forKey:@"rotationAnimation"];
	
	[CATransaction commit];
}

- (void)stillButton
{
	[button.layer removeAllAnimations];
}

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

- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)finished
{
	if (finished)
	{
		[self spinButtonWith:YES];
	}
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


- (void)dealloc 
{
	[backLight release];
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
- (void)openNot 
{
	if (canOpen)
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
		[picker setAllowsImageEditing:NO];
		[[picker navigationBar] setHidden:YES];	
		[picker setModalTransitionStyle:UIModalTransitionStyleFlipHorizontal];
		
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
	DebugLog(@"Picked image for sending to pikchur: w=%f, h=%f", image.size.width, image.size.height);
	//NSLog(@"what else do we have %@", editingInfo);
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



@end
