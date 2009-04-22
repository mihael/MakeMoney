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
@synthesize delegate, transender, transendController, feeling, listingName, notBehavior, notControls;

- (id)initWithTransendsListing:(NSString*)aListingName andStage:(NSDictionary*)aStage{
	if (self = [super init]) {
		[self setListingName:aListingName];
		stage = aStage;
		transitions = [[NSArray arrayWithObjects:kCATransitionMoveIn, kCATransitionPush, kCATransitionReveal, kCATransitionFade, nil] retain];
		directions = [[NSArray arrayWithObjects:kCATransitionFromLeft, kCATransitionFromRight, kCATransitionFromTop, kCATransitionFromBottom, nil] retain];
		horizontal = [[stage valueForKey:@"horizontal"] boolValue];
		animated = [[stage valueForKey:@"animated"] boolValue];
	}
	return self;
}

- (void)loadView {
	transender = [[[IITransender alloc] initWith:[NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:listingName ofType:@"json"]]] retain];
	[transender setDelegate:self];

	skrin = [[IITransenderView alloc] initWithFrame:CGRectMake(0, 0, 480, 320)];
	skrin.delegate = self;
	self.view = skrin;
	
	transendEmitter1 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"main.png"]];
	transendEmitter2 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"main.png"]];
	useEmitter1 = YES;
	[self.view addSubview:transendEmitter1];
	
	avoidBehavior = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
	[transender meditate];
	[notControls lightUp];
	[[iAlert instance] alert:@"Received Memory Warning in TransenderViewController" withMessage:@"Good luck!"];
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
- (void)fechingTransend 
{
	DebugLog(@"IITransenderViewController#fechingTransend");
	//TODO open progress view in notControls
	//[notControls showIndica];
	[notControls lightUp];
	
	
}


- (void)transendedWithView:(IIController*)transend andBehavior:(NSDictionary*)behavior {
	DebugLog(@"IITransenderViewController#transendedWithView %@ andBehavior %@", transend, behavior);
	if (self.notControls && [transend respondsToSelector:@selector(setNotControls:)])
		[transend setNotControls:self.notControls];//give the current controller access to notControls
	[self setNotBehavior:behavior];
	if (transendController) {  
		if ([transendController respondsToSelector:@selector(stopFunctioning)]) {
			[transendController stopFunctioning]; //stop the previous view if can
		} 
	}		
	[self transit:transend.view]; //transit with the fresh view
	[transendController release]; //release any previously transended views
	transendController = nil;
	[self setTransendController:transend];
	if ([transendController respondsToSelector:@selector(startFunctioning)]) {
		[transendController startFunctioning]; //start the current view if can
	}
	[self continueWithBehavior];
}

- (void)transendedWithImage:(UIImage*)transend andBehavior:(NSDictionary*)behavior {
	DebugLog(@"IITransenderViewController#transendedWithImage %@ andBehavior %@", transend, behavior);
	[self setNotBehavior:behavior];
	[self transitImage:transend];
	[self continueWithBehavior];
}

- (void)transendedWithMovie:(NSString*)transend andBehavior:(NSDictionary*)behavior {
	DebugLog(@"IITransenderViewController#transendedWithMovie %@ andBehavior %@", transend, behavior);
	[self setNotBehavior:behavior];
	if ([[behavior valueForKey:@"background"] boolValue]) 
	{
		[self transitImage:[UIImage imageNamed:@"movie.png"]];
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

- (void)transendedWithMusic:(NSString*)transend andBehavior:(NSDictionary*)behavior {
	DebugLog(@"IITransenderViewController#transendedWithMusic %@ andBehavior %@", transend, behavior);
	[self setNotBehavior:behavior];
	//stop transending
	[transender meditate];
	
	if ([[behavior valueForKey:@"background"] boolValue]) 
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
	DebugLog(@"IITransenderViewController#transendedAll");
}

#pragma mark Behavior
- (void)continueWithBehavior 
{
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
			//NSUInteger transitionsIndex = random() % [transitions count];
			//TODO - let choose transition from listing
			NSString *transition = [transitions objectAtIndex:1];//[transitions objectAtIndex:transitionsIndex];						
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
			NSTimeInterval duration = [transender currentVibe]/2;//kTransendAnimationSpeed;					
			if (replaceMe) {
				[skrin replaceSubview:replaceMe withSubview:wiev transition:transition direction:dir duration:duration];
			}
		} else { //transit without animating
			[skrin replaceSubview:replaceMe withSubview:wiev];
		}
		
	} else {
		DebugLog(@"IITransenderViewController# No transit. Skrin has no views.");
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
}

- (void)notControlsClosed:(id)notControl {
	avoidBehavior = NO;
	[notControl lightDown];
	[notControl hideBackLight];
	[transender transend];
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
