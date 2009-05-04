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
		animated = [[stage valueForKey:@"animated"] boolValue];
		NSString* program_json = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:program ofType:@"json"]];
		transender = [[IITransender alloc] initWith:program_json];
		[transender setDelegate:self];
		DebugLog(@"IITransenderViewController# init program: %@ stage: %@", program, stage);
	}
	return self;
}

- (void)loadView {
	skrin = [[IITransenderView alloc] initWithFrame:CGRectMake(0, 0, 480, 320)];
	skrin.delegate = self;
	self.view = skrin;
	
	transendEmitter1 = [[UIImageView alloc] initWithImage:[transender imageNamed:@"main.jpg"]];
	[transendEmitter1 setContentMode:UIViewContentModeScaleAspectFit];
	transendEmitter2 = [[UIImageView alloc] initWithImage:[transender imageNamed:@"main.jpg"]];
	[transendEmitter2 setContentMode:UIViewContentModeScaleAspectFit];

	useEmitter1 = YES;
	[self.view addSubview:transendEmitter1];
	
	avoidBehavior = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
	[transender meditate];
	[notControls lightUp];
	[[iAlert instance] alert:@"Received Memory Warning in IITransenderViewController" withMessage:@"Good luck!"];
	DebugLog(@"Too many memories.");
}

- (void)dealloc {
	if (transendController) {
		[transendController release];
	}
	[transendEmitter2 release];
	[transendEmitter1 release];
	[skrin release];
	[transender release];
	[transitions release];
	[directions release];
    [super dealloc];
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
	if (self.notControls && [transend respondsToSelector:@selector(setNotControls:)])
		[transend setNotControls:self.notControls];//give the current controller access to notControls
	[self setNotBehavior:ior];
	if (![ior valueForKey:@"non_stop_functioning"]) {  //do not stop functioning
		if ([transendController respondsToSelector:@selector(stopFunctioning)]) {
			[transendController stopFunctioning]; //stop the previous view if can
		} 
	}		
	[self transit:transend.view]; //transit with the fresh view
	[self setTransendController:transend];
	if ([transendController respondsToSelector:@selector(startFunctioning)]) {
		[transendController startFunctioning]; //start the current view if can
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
- (void)continueWithBehavior 
{
	[notControls showMessage:[NSString stringWithFormat:@"Spot:%i of %i Vibe:%1.2fHz", [transender currentSpot]+1, [transender memoriesCount], 1/[transender currentVibe] ]];

	if (avoidBehavior) { //just stop and do not much else
		[transender meditate];
		if (delegate) {
			if ([delegate respondsToSelector:@selector(meditating)]) {
				[delegate meditating];
			}
		}								
	} else { //continue transending if notbehavior allows
		if (notBehavior) {
			BOOL stop = [[notBehavior valueForKey:@"stop"] boolValue];
			if (stop) {
				if ([transender isTransending]) { //no need to meditate if already meditating
					[transender meditate];
					if (delegate) {
						if ([delegate respondsToSelector:@selector(meditating)]) {
							[delegate meditating];
						}
					}								
				}
			} else {
				if (![transender isTransending]) { //no need to transend if already transending
					[transender transend];
					if (delegate) {
						if ([delegate respondsToSelector:@selector(transending)])
							[delegate transending];
					}				
				}
			}
			NSNumber *revibe = [notBehavior valueForKey:@"revibe"];
			if (revibe) {
				[transender reVibe:[revibe floatValue]];
			}
		} else { //transend if no notbehavior 
			[transender transend];
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
    MPMoviePlayerController* movie=[[MPMoviePlayerController alloc] initWithContentURL:url]; 
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
    [movie release]; 
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

#pragma mark IINotControlsDelegate
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
	avoidBehavior = YES;
	[notControl lightUp];
	[notControl showBackLight];
	[transender meditate];
	[notControls showMessage:[NSString stringWithFormat:@"Spot:%i of %i Vibe:%1.2fHz", [transender currentSpot]+1, [transender memoriesCount], 1/[transender currentVibe] ]];
}

- (void)notControlsClosed:(id)notControl {
	avoidBehavior = NO;
	[notControl hideBackLight];
	if ([stage valueForKey:@"transendAfterNotControlsClosed"]) {
		//[notControl lightDown];
		//[transender transend];	
	}
	[notControl hideMessage];
}

- (void)leftTouch:(id)notControl {
	[transender changeDirectionTo:kIITransenderDirectionDown];
	[transender invokeTransend];
}

- (void)rightTouch:(id)notControl {
	[transender changeDirectionTo:kIITransenderDirectionUp];
	[transender invokeTransend];
}


@end
