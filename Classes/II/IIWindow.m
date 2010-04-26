//
//  IIWindow.m
//  MakeMoney
//

#import "IIWindow.h"

/*
 This window subclass can be used to trap taps and events that are coming into a targeted view.
 You can for instance trap taps in an UIWebView, without messing up the UIWebView functioning.
 
 Just use this instead of the regular window you create in the app delegate.
 */

@implementation IIWindow

@synthesize observedView;
@synthesize observer;

- (id)initWithObserved:(UIView *)view andObserver:(id)delegate {
    if(self == [super init]) {
        self.observedView = view;
        self.observer = delegate;
    }
    return self;
}

- (void)dealloc {
    [observedView release];
    [super dealloc];
}

- (void)forwardTap:(id)touch {
    [observer didTapObservedView:touch];
}

//hack this if You need something other than 1 tap
- (void)sendEvent:(UIEvent *)event {
    [super sendEvent:event];
    if (observedView == nil || observer == nil)
        return;
    NSSet *touches = [event allTouches];
    if (touches.count != 1)
        return;
    UITouch *touch = touches.anyObject;
    if (touch.phase != UITouchPhaseEnded)
        return;
    if ([touch.view isDescendantOfView:observedView] == NO)
        return;
    CGPoint tapPoint = [touch locationInView:observedView];
  //  DLog(@"TapPoint = %f, %f", tapPoint.x, tapPoint.y);
    NSArray *pointArray = [NSArray arrayWithObjects:[NSString stringWithFormat:@"%f", tapPoint.x],
						   [NSString stringWithFormat:@"%f", tapPoint.y], nil];
    if (touch.tapCount == 1) {
        [self performSelector:@selector(forwardTap:) withObject:pointArray afterDelay:0.5];
	} else if (touch.tapCount > 1) {
		[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(forwardTap:) object:pointArray];
	}
}

@end
