//
//  IITransenderController.m
//  MakeMoney
//
#import "IITransenderViewController.h"
#import "MakeMoneyAppDelegate.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AudioToolbox/AudioToolbox.h>
#import <QuartzCore/QuartzCore.h>

@implementation IITransenderViewController
@synthesize delegate, transender, transendController, feeling, notBehavior, notControls;

- (id)initWithTransenderProgram:(NSString*)program andStage:(NSDictionary*)aStage{
	if (self = [super init]) {
		stage = [aStage mutableCopy];
		transitions = [[NSArray arrayWithObjects:kCATransitionMoveIn, kCATransitionPush, kCATransitionReveal, kCATransitionFade, nil] retain];
		transitionIndex = kTransition;
		directions = [[NSArray arrayWithObjects:kCATransitionFromLeft, kCATransitionFromRight, kCATransitionFromTop, kCATransitionFromBottom, nil] retain];
		horizontal = [[stage valueForKey:@"horizontal"] boolValue];
		if ([[NSUserDefaults standardUserDefaults] valueForKey:@"horizontal"]) {
			horizontal = ([[[NSUserDefaults standardUserDefaults] valueForKey:@"horizontal"] isEqualToString:@"true"]);
		}
		animated = [[stage valueForKey:@"animated"] boolValue];		
		NSString* program_json = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:program ofType:@"json"] encoding:NSUTF8StringEncoding error:nil];
		transender = [[IITransender alloc] initWith:program_json];
		[transender setDelegate:self];
		DebugLog(@"#initWithTransenderProgram: %@ andStage: %@", program, stage);
		if ([stage valueForKey:@"goldcut"]) {
			int goldcut = [[stage valueForKey:@"goldcut"] intValue];
			if (goldcut>-2) { //-1 disables
				[transender goldcutAt:goldcut];
				DebugLog(@"#goldcutAt: %i", goldcut);
			}
		}
	}
	return self;
}

- (void)loadView {
	skrin = [[IITransenderView alloc] initWithFrame:[Kriya orientedFrame]];
	DebugLog(@"TRANSENDER VIEW FRAME %f %f", skrin.frame.size.width, skrin.frame.size.height);
	skrin.delegate = self;
	self.view = skrin;
//	[skrin setAutoresizesSubviews:NO];
//	[skrin setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
	
	transendEmitter1 = [[UIImageView alloc] initWithFrame:skrin.frame];
	//transendEmitter1.backgroundColor = [UIColor greenColor];
	[transendEmitter1 setImage:[transender imageNamed:@"vmain.jpg"]];
	[transendEmitter1 setContentMode:UIViewContentModeScaleAspectFit];
	transendEmitter2 = [[UIImageView alloc] initWithFrame:skrin.frame];
	[transendEmitter2 setImage:[transender imageNamed:@"main.jpg"]];
	[transendEmitter2 setContentMode:UIViewContentModeScaleAspectFit];
	useEmitter1 = YES;
	[self.view addSubview:transendEmitter1];
	avoidBehavior = NO;
	if ([[[[MakeMoneyAppDelegate app] stage] valueForKey:@"info"] boolValue])
		[self showInfoView];
}

- (void)layout:(CGRect)rect
{
	[skrin setFrame:rect];
	[transendEmitter1 setFrame:rect];
	[transendEmitter2 setFrame:rect];
	if (transendController)
		[transendController layout:rect];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
	[transender meditate];
	[notControls lightUp];
	[[iAlert instance] alert:@"Received Memory Warning in IITransenderViewController" withMessage:@"Good luck!"];
	DebugLog(@"Too many memories.");
}

- (void)dealloc {
	if (magicHide) {
		[magicHide invalidate];
		[magicHide release];
		magicHide = nil;
	}
	[transendController release];
	[transendEmitter2 release];
	[transendEmitter1 release];
	[skrin release];
	[transender release];
	[transitions release];
	[directions release];
    [super dealloc];
}

- (void)setNotBehavior:(NSMutableDictionary*)newNotBehavior {
	if (notBehavior != newNotBehavior) {
			[notBehavior release];
			notBehavior = [newNotBehavior mutableCopy];
    }
}

#pragma mark Startup info view
- (void)showInfoView 
{
	CGRect r = [Kriya orientedFrame];
	infoView = [[[UIView alloc] initWithFrame:r] autorelease];
	[infoView setBackgroundColor:[UIColor clearColor]];
	UILabel *version = [[[UILabel alloc] initWithFrame:CGRectMake(0, 0, r.size.width, r.size.height/2)] autorelease];		
	UILabel *startups = [[[UILabel alloc] initWithFrame:CGRectMake(0, r.size.height/2, r.size.width, r.size.height/2)] autorelease];
	version.text = [NSString stringWithFormat:@"Version %@", [MakeMoneyAppDelegate version]];
	startups.text = [[NSUserDefaults standardUserDefaults] valueForKey:STARTUPS];
	version.backgroundColor = [UIColor clearColor];
	startups.backgroundColor = [UIColor clearColor];
	version.textColor = [UIColor whiteColor];
	startups.textColor = [UIColor whiteColor];
	version.font = [UIFont systemFontOfSize:38];
	startups.font = [UIFont systemFontOfSize:23];
	version.textAlignment = UITextAlignmentCenter;
	startups.textAlignment = UITextAlignmentCenter;
	startups.lineBreakMode = UILineBreakModeWordWrap;
	startups.numberOfLines = 2;
	[infoView addSubview:version];
	[infoView addSubview:startups];
	[self.view addSubview:infoView];
	magicHide = [[NSTimer scheduledTimerWithTimeInterval:kButtonSpeed*2
											 target:self 
										   selector:@selector(hideInfoView:)
										   userInfo:nil
											repeats:NO] retain];		
}

- (void)hideInfoView:(NSTimer*)timer
{
	if (magicHide) {
		[magicHide invalidate];
		[magicHide release];
		magicHide = nil;
	}
	if ([infoView superview]!=nil)
		[infoView removeFromSuperview];	
}

#pragma mark IITransenderDelegate
- (void)fechedTransend
{
	DebugLog(@"#fechedTransend");
	[notControls stillButton];		
}

- (void)fechingTransend 
{
	DebugLog(@"#fechingTransend");
	[notControls spinButtonWith:[transender direction]];	
	
}

- (void)transendedWithView:(IIController*)transend withIons:(NSDictionary*)ions withIor:(NSDictionary*)ior {
	DebugLog(@"#transendedWithView %@ ions %@ ior %@", transend, ions, ior);	
	[self setNotBehavior:ior];
	if (self.notControls && [transend respondsToSelector:@selector(setNotControls:)])
		[transend setNotControls:self.notControls];//give the current controller access to notControls

	if ([transendController respondsToSelector:@selector(stopFunctioning)]) {
		[transendController stopFunctioning]; //stop the previous controller 
	} 

	[self transit:transend.view]; //transit with the fresh view
	
	if (transendController!=transend) {//save controller if changed
		[self setTransendController:transend]; 
	} else {
		DebugLog(@"#transendedWithView again");
	}

	if (transendController) {
		[transendController layout:[Kriya orientedFrame]];
		if ([transendController respondsToSelector:@selector(startFunctioning)]) {
			[transendController startFunctioning]; //start the current view if can
		}
	}

	[self continueWithBehavior];
}

- (void)transendedWithImage:(UIImage*)transend withIons:(NSDictionary*)ions withIor:(NSDictionary*)ior  {
	DebugLog(@"#transendedWithImage %@ ions %@ ior %@", transend, ions, ior);
	[self setNotBehavior:ior];
	[self transitImage:transend];
	[self continueWithBehavior];
}

- (void)transendedWithMovie:(NSString*)transend withIons:(NSDictionary*)ions withIor:(NSDictionary*)ior  {
	DebugLog(@"#transendedWithMovie %@ ions %@ ior %@", transend, ions, ior);
	[self setNotBehavior:ior];
	if ([[ior valueForKey:@"background"] boolValue]) 
	{
		[self transitImage:[transender imageNamed:@"movie.png"]];
	}
	//stop transending
	[transender meditate];
	if (delegate) { //notify delegate about this meditation
		if ([delegate respondsToSelector:@selector(meditating)])
			[delegate meditating];
	}								
	//see movie 
	[self seeMovie:[NSURL fileURLWithPath:transend]];
}

- (void)transendedWithMusic:(NSString*)transend withIons:(NSDictionary*)ions withIor:(NSDictionary*)ior {
	DebugLog(@"#transendedWithMusic %@ ions %@ ior %@", transend, ions, ior);
	[self setNotBehavior:ior];
	//stop transending
	[transender meditate];
	
	if ([[ior valueForKey:@"background"] boolValue]) 
	{
		[self transitImage:[UIImage imageNamed:@"music.png"]];
	}
	
	if (delegate) { //notify delegate about this meditation
		if ([delegate respondsToSelector:@selector(meditating)])
			[delegate meditating];
	}									
	//hear music 
	[self hearMusicFile:transend];
}

- (void)transendedAll:(id)sender {
	DebugLog(@"#transendedAll");
}

#pragma mark Behavior
- (void)setNotMessage 
{
	[notControls showVibeSelection:[NSString stringWithFormat:@"%i/%i %1.2fHz", [transender currentSpot]+1, [transender memoriesCount], 1/[transender currentVibe] ]];
	//[notControls showMessage:[NSString stringWithFormat:@"%i/%i %1.2fHz", [transender currentSpot]+1, [transender memoriesCount], 1/[transender currentVibe] ]];

	//set message if any
	NSString *m = [notBehavior valueForKey:@"m"];
	if (m) {
		NSUInteger max = [m length];
		if (max > 0) {
			if (max>20) {
				max = 20;
			}
			//[notControls showMessage:[NSString stringWithFormat:@"%@ %i/%i %1.2fHz", [m substringToIndex:max], [transender currentSpot]+1, [transender memoriesCount], 1/[transender currentVibe] ]];
			[notControls showMessage:[NSString stringWithFormat:@"%@", [m substringToIndex:max]]];
		}
	}
}
- (void)continueWithBehavior 
{
	DLog(@"continueWithBehavior: %@", notBehavior);
	[self setNotMessage];
	
	if (avoidBehavior) { //just stop and do not much else, since the notControls are open
		DLog(@"continueWithBehavior: avoiding behavior");
		[transender meditate];
		[notControls lightUp];
		if (delegate) {
			if ([delegate respondsToSelector:@selector(meditating)]) {
				[delegate meditating];
			}
		}								
	} else { //continue transending if notbehavior allows
		if (notBehavior) {
			BOOL stop = [[notBehavior valueForKey:@"stop"] boolValue];
			if (stop) {
				[notControls lightUp];
				if ([transender isTransending]) { //no need to meditate if already meditating
					[transender meditate];
					if (delegate) {
						if ([delegate respondsToSelector:@selector(meditating)]) {
							[delegate meditating];
						}
					}								
				}
			} else {
				[notControls lightDown];
				if (![transender isTransending]) { //no need to transend if already transending
					[transender transend];
					if (delegate) {
						if ([delegate respondsToSelector:@selector(transending)])
							[delegate transending];
					}				
				}
			}
			
			//Change background noise if requested
			NSString *noise_url = [notBehavior valueForKey:@"noise_url"];
			if (noise_url) {
				[notControls playStop];
				[notControls playWithStreamUrl:noise_url];
			}
			
			//Change speed of transending if requested
			NSNumber *revibe = [notBehavior valueForKey:@"revibe"];
			if (revibe) {
				[transender reVibe:[revibe floatValue]];
			}

			//Does the whole available space act like a button?
			NSString *space= [notBehavior valueForKey:@"space"];
			if ([space isEqualToString:@"up"]||[space isEqualToString:@"true"])
				[notControls spaceUp];
			if ([space isEqualToString:@"down"]||[space isEqualToString:@"false"])
				[notControls spaceDown];
		} else { //transend if no notbehavior 
			[transender transend];
			[notControls lightDown];
			if (delegate) {
				if ([delegate respondsToSelector:@selector(transending:)])
					[delegate transending];
			}				
		}
	}
}

#pragma mark Hear Music
-(void)hearMusicFile:(NSString*)thePath 
{
	music = [[[IIMusic alloc] initWithFile:thePath] retain];
	music.delegate = self;
	[music listen];
}


-(void)heardMusic:(id)sender
{
	if (music) {
		[music release];		
	}
	[self continueWithBehavior];
}

#pragma mark See Movie
-(void)seeMovie:(NSURL*)url 
{
    MPMoviePlayerController* movie= [[[MPMoviePlayerController alloc] initWithContentURL:url] autorelease]; 
    movie.scalingMode=MPMovieScalingModeAspectFill;
	//movie.movieControlMode=MPMovieControlModeVolumeOnly;
		
    [[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(seenMovie:) 
												 name:MPMoviePlayerPlaybackDidFinishNotification 
											   object:movie]; 
	
    // Movie playback is asynchronous, so this method returns immediately. 
    [movie play]; 
    
	if (delegate) { //notify delegate about this movie
		if ([delegate respondsToSelector:@selector(moviesStart)])
			[delegate moviesStart];
	}								
	
} 

// When the movie is done,release the controller. 
-(void)seenMovie:(NSNotification*)notification 
{
    MPMoviePlayerController* movie=[notification object]; 
    [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                    name:MPMoviePlayerPlaybackDidFinishNotification 
                                                  object:movie]; 
    //[movie release]; 
	if (delegate) { //notify delegate about the end
		if ([delegate respondsToSelector:@selector(moviesEnd)])
			[delegate moviesEnd];
	}								
	
	[self continueWithBehavior];
}

#pragma mark TransitionViewDelegate
- (void)transitionViewDidStart:(IITransenderView *)view {
}
- (void)transitionViewDidFinish:(IITransenderView *)view {
}
- (void)transitionViewDidCancel:(IITransenderView *)view {
}

#pragma mark View Transitioning
- (void)transitImage:(UIImage*)img 
{
	if ([notBehavior valueForKey:@"content_mode"]) { //set content mode if requested
		if ([[notBehavior valueForKey:@"content_mode"] isEqualToString:@"fill"]) {
			transendEmitter1.contentMode = UIViewContentModeScaleAspectFill;
			transendEmitter2.contentMode = UIViewContentModeScaleAspectFill;
		}
		if ([[notBehavior valueForKey:@"content_mode"] isEqualToString:@"fit"]) {
			transendEmitter1.contentMode = UIViewContentModeScaleAspectFit;
			transendEmitter2.contentMode = UIViewContentModeScaleAspectFit;
		}
		if ([[notBehavior valueForKey:@"content_mode"] isEqualToString:@"scale"]) {
			transendEmitter1.contentMode = UIViewContentModeScaleToFill;
			transendEmitter2.contentMode = UIViewContentModeScaleToFill;
		}
		if ([[notBehavior valueForKey:@"content_mode"] isEqualToString:@"center"]) {
			transendEmitter1.contentMode = UIViewContentModeCenter;
			transendEmitter2.contentMode = UIViewContentModeCenter;
		}
	}
	if (useEmitter1) { 
		[transendEmitter2 setImage:img];
		[self transit:transendEmitter2];
		useEmitter1 = NO;
	} else {
		[transendEmitter1 setImage:img];
		[self transit:transendEmitter1];
		useEmitter1 = YES;
	}	
}

- (void)transit:(UIView*)wiev {
	if ([skrin subviews].count > 0) {
		UIView *replaceMe = [[skrin subviews] objectAtIndex:0];
		//wiev.frame = KriyaFrame();
		//DebugLog(@"transit WIEV %f %f", wiev.frame.size.width, wiev.frame.size.height);
		
		if (animated) {
			//chose transition type and direction at random from the arrays of supported transitions and directions
			if ([notBehavior valueForKey:@"effect"]) {
				transitionIndex = [[notBehavior valueForKey:@"effect"] intValue];
				if (transitionIndex>=[transitions count]) 
					transitionIndex = random() % [transitions count];
			} else {
				transitionIndex = kTransition; //default is push
			}
			NSString *transition = [transitions objectAtIndex:transitionIndex];
			//NSUInteger directionsIndex = random() % [directions count];
			NSString *dir = nil; //[directions objectAtIndex:directionsIndex];
			
			if ([transender direction]) {
				if (horizontal) {
					dir = [directions objectAtIndex:0];
				} else {
					dir = [directions objectAtIndex:2];				
				}
			} else {
				if (horizontal) {
					dir = [directions objectAtIndex:1];			
				} else {
					dir = [directions objectAtIndex:3];			
				}
			}
			
			//be twice as fast as the transender vibe
			NSTimeInterval duration = [transender currentVibe]/3;//kTransendAnimationSpeed;					
			if (replaceMe) {
				[skrin replaceSubview:replaceMe withSubview:wiev transition:transition direction:dir duration:duration];
			}
		} else { //transit without animating
			[skrin replaceSubview:replaceMe withSubview:wiev];
		}

	} else {
		DebugLog(@"#transit skrin has no views.");
	}
}

- (BOOL)isTransendedWithImage {
	return ([[[skrin subviews] objectAtIndex:0] class]==[UIImageView class]);
}

#pragma mark IINotControlsDelegate
- (void)shake:(id)notControl { //device is shaked
	[transender meditate];
	[transender meditateWith:0];
}

- (void)oneTap:(id)notControl { //button was just tapped
	if ([transender isTransending]) {
		[notControl lightUp];
		[transender meditate];
	} else {
		[notControl lightDown];
		[transender transend];
	}		
}

- (void)notControlsOpened:(id)notControl {
	[transender meditate];
	avoidBehavior = YES;
	[notControl lightUp];
	if ([@"true" isEqualToString:[stage valueForKey:@"not_controls_use_backlight"]]) { 
		[notControl showBackLight];
	}
	//[notControls showMessage:[NSString stringWithFormat:@"[Spot:%i/%i Vibe:%1.2fHz]", [transender currentSpot]+1, [transender memoriesCount], 1/[transender currentVibe] ]];
	[self setNotMessage];
}

- (void)notControlsClosed:(id)notControl {
	avoidBehavior = NO;
	if ([@"true" isEqualToString:[stage valueForKey:@"not_controls_use_backlight"]]) { 
		[notControl hideBackLight];
	}
	[notControl hideMessage];
	[self continueWithBehavior];
}

- (void)leftTouch:(id)notControl {
	if (![transender isTransending]) {
		[transender changeDirectionTo:kIITransenderDirectionDown];
		[transender invokeTransend];
		if ([stage valueForKey:@"direction_changes"]) { //disable direction changes
			BOOL changes = [[stage valueForKey:@"direction_changes"] boolValue];
			if (!changes)
				[transender changeDirectionTo:kIITransenderDirectionUp];
		}
	}
	
}

- (void)rightTouch:(id)notControl {
	if (![transender isTransending]) {
		[transender changeDirectionTo:kIITransenderDirectionUp];
		[transender invokeTransend];
	} //do not do anything if the transender is already transending
}

- (void)vibeSelectionChange:(id)slider {
	CGFloat value = [(UISlider*)slider value];
	[transender reVibe:value];
	[self setNotMessage];
}

- (void)actionTouch:(id)notControl {
	if ([self isTransendedWithImage]) { //this is an image transend
		DLog(@"SHould SHOW POP UP IF IPAD ...");
		if ([@"always" isEqualToString:[Kriya stateForField:@"saveImage"]]) {
			//just save
			[self saveCurrentImageToLibrary];
		} else {
			//ask before saving
			UIActionSheet *as = [[[UIActionSheet alloc] initWithFrame:skrin.frame] autorelease];
			[as setTitle:@"Image Export"];
			[as setActionSheetStyle:UIActionSheetStyleBlackTranslucent];
			[as addButtonWithTitle:@"Save to library?"];//0
			[as addButtonWithTitle:@"Always save!"];//1
			if (![Kriya isPad]) {
				[as addButtonWithTitle:@"Cancel"];//2
				[as setCancelButtonIndex:2];
			}
			[as setDelegate:self];
			[as showInView:skrin];
		}
	} else {
		//pass it on to the current transendController
		DLog(@"actionTouch");
	}
}

- (void)spaceTouch:(id)notControl touchPoint:(CGPoint)point { //space was just tapped
	DLog(@"spaceTouch");
	if ([notControl notOpen]) { //use only when not open notControls
		if ([transender isTransending]) {
			DLog(@"lightingUp meditate");
			//[transender cancelFech];
			[notControl lightUp];
			[transender meditate];
		} else {
			DLog(@"lightingDown transend");
			[notControl lightDown];
			[transender transend];
		}		
	}
}

- (void)spaceDoubleTouch:(id)notControl touchPoint:(CGPoint)point { //space was just tapped
	if ([notControl notOpen]) { //use only when not open notControls
		[notControl lightUp];
		[transender meditate];
		[transender meditateWith:0];
	}
}

- (void)spaceSwipeRight:(id)notControl { //empty space swipe - can be while openNot
	DLog(@"Space SWIPE RIGHT");
	if (![notControl notOpen]&&![transender isTransending]) {
		[transender changeDirectionTo:kIITransenderDirectionUp];
		[transender invokeTransend];
	}
}

- (void)spaceSwipeLeft:(id)notControl { //empty space swipe - can be while openNot
	DLog(@"Space SWIPE LEFT");
	if (![notControl notOpen]&&![transender isTransending]) {
		[transender changeDirectionTo:kIITransenderDirectionDown];
		[transender invokeTransend];
	}
}

- (void)picked:(NSDictionary*)info {
}

#pragma mark UIActionSheetDelegate
- (void)saveCurrentImageToLibrary {
	UIImageWriteToSavedPhotosAlbum([[[skrin subviews] objectAtIndex:0] image], self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
}
- (void) image:(UIImage*)image didFinishSavingWithError:(NSError*)error contextInfo:(void*)contextInfo {
	if (error) {
		[[iAlert instance] alert:@"Image Export" withMessage:[NSString stringWithFormat:@"Error saving image! %@",[error localizedDescription]]];
	} else {
		//if ([@"always" isEqualToString:[Kriya stateForField:@"saveImage"]])
		[[iAlert instance] alert:@"Image Export" withMessage:@"Saved!"];
	}
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	switch (buttonIndex) {
		case 0:
			DLog(@"action 0 saving image");//save image
			[self saveCurrentImageToLibrary];
			break;
		case 1:
			DLog(@"action 0 always saving image");//save image
			[Kriya saveState:@"always" forField:@"saveImage"];
			[self saveCurrentImageToLibrary];
			break;
		case 2:
			DLog(@"action 2"); //cancel
			break;
		default:		//cancel
			DLog(@"default action");
			break;
	}	
}

#pragma mark State
- (void)saveState {
	DLog(@"SAVING transendController state...");
	if ([transendController respondsToSelector:@selector(saveState)]) {
		[transendController saveState]; 
	} 
}
@end
