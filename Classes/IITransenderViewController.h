//
//  IITransenderController.h
//  MakeMoney
//
#import <UIKit/UIKit.h>
#import "IITransender.h"
#import "IIController.h"
#import "IIMusic.h"
#import "IITransenderView.h"
#import "IINotControls.h"
#define kTransendAnimated YES
#define kTransition 1

@protocol IITransenderViewControllerDelegate <NSObject>
- (void)transending;
- (void)meditating;
- (void)moviesStart;
- (void)moviesEnd;
@end

@class IITransender;
@class IIController;
@class IINotControls;
@class IIMusic;

@interface IITransenderViewController : UIViewController 
<IINotControlsDelegate, 
 IITransenderDelegate, 
 IIMusicDelegate, 
 IITransenderViewDelegate> 
{
    id <IITransenderViewControllerDelegate> delegate;
		IITransenderView *skrin;
    	IINotControls *notControls;
		IITransender *transender;

		IIController *transendController;
	
		IIMusic *music;
		NSTimer *magic;
		BOOL feeling;	
		UIImageView *transendEmitter1;
		UIImageView *transendEmitter2;		
		BOOL useEmitter1;

		NSMutableDictionary *notBehavior;
		BOOL avoidBehavior;
		
		BOOL animated; //should use animated transits beetween  transends
		BOOL horizontal; //how transits look like, either leftright move or updown

		NSMutableDictionary *stage; //how should we act, behave, look like... 
		
		NSArray* transitions;
		int transitionIndex;
		NSArray* directions;
}

@property (nonatomic, assign) id <IITransenderViewControllerDelegate> delegate;
@property (readonly, retain) IITransender *transender;
@property (readwrite, assign) IINotControls *notControls;
@property (readwrite, retain) UIViewController *transendController;
@property (readwrite) BOOL feeling;
@property (readwrite, retain) NSDictionary *notBehavior;

- (id)initWithTransenderProgram:(NSString*)program andStage:(NSDictionary*)aStageName;

//transender delegate
- (void)transendedAll:(id)sender;
- (void)fechingTransend;
- (void)fechedTransend;
- (void)continueWithBehavior;
- (void)transendedWithView:(IIController*)transend withIons:(NSDictionary*)ions withIor:(NSDictionary*)ior;
- (void)transendedWithImage:(UIImage*)transend withIons:(NSDictionary*)ions withIor:(NSDictionary*)ior;
- (void)transendedWithMovie:(NSString*)transend withIons:(NSDictionary*)ions withIor:(NSDictionary*)ior;
- (void)transendedWithMusic:(NSString*)transend withIons:(NSDictionary*)ions withIor:(NSDictionary*)ior;
//transender delegate


- (void)transitionViewDidStart:(IITransenderView *)view;
- (void)transitionViewDidFinish:(IITransenderView *)view;
- (void)transitionViewDidCancel:(IITransenderView *)view;

- (void)transit:(UIView*)wiev;

- (void)transitImage:(UIImage*)img;

-(void)hearMusicFile:(NSString*)thePath;
-(void)seeMovie:(NSURL*)url;

@end
