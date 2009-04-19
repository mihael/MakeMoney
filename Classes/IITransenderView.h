//
//  IITransenderView.h
//  MakeMoney
//
#import <UIKit/UIKit.h>

@class IITransenderView;

@protocol IITransenderViewDelegate <NSObject>
@optional
- (void)transitionStart:(IITransenderView *)view;
- (void)transitionFinish:(IITransenderView *)view;
- (void)transitionCancel:(IITransenderView *)view;
@end

@interface IITransenderView : UIView {
@private 
	BOOL transitioning, wasEnabled;
	id<IITransenderViewDelegate> delegate;
}
@property (assign) id<IITransenderViewDelegate> delegate;
@property (readonly, getter=isTransitioning) BOOL transitioning;

- (void)replaceSubview:(UIView *)oldView withSubview:(UIView *)newView transition:(NSString *)transition direction:(NSString *)direction duration:(NSTimeInterval)duration;
- (void)replaceSubview:(UIView *)oldView withSubview:(UIView *)newView;
- (void)cancelTransition;
@end
