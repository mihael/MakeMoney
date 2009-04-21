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
		NSString* listingName;
		BOOL useEmitter1;

		NSDictionary *notBehavior;
		BOOL avoidBehavior;
		
		BOOL animated; //should use animated transits beetween  transends
		BOOL horizontal; //how transits look like, either leftright move or updown

		NSDictionary *stage; //how should we act, behave, look like... 
		
		NSArray* transitions;
		NSArray* directions;
}

@property (nonatomic, assign) id <IITransenderViewControllerDelegate> delegate;
@property (readonly, retain) IITransender *transender;
@property (readwrite, assign) IINotControls *notControls;
@property (readwrite, retain) UIViewController *transendController;
@property (readwrite) BOOL feeling;
@property (readwrite, retain) NSString* listingName;
@property (readwrite, retain) NSDictionary *notBehavior;

- (id)initWithTransendsListing:(NSString*)aListingName andStage:(NSDictionary*)aStageName;

- (void)transendedWithView:(IIController*)transend andBehavior:(NSDictionary*)behavior;
- (void)transendedWithMovie:(NSString*)transend andBehavior:(NSDictionary*)behavior;
- (void)transendedWithMusic:(NSString*)transend andBehavior:(NSDictionary*)behavior;
- (void)transendedWithImage:(UIImage*)transend andBehavior:(NSDictionary*)behavior;
- (void)transendedAll:(id)sender;
- (void)continueWithBehavior;

- (void)transitionViewDidStart:(IITransenderView *)view;
- (void)transitionViewDidFinish:(IITransenderView *)view;
- (void)transitionViewDidCancel:(IITransenderView *)view;

- (void)transit:(UIView*)wiev;

- (void)transitImage:(UIImage*)img;

-(void)hearMusicFile:(NSString*)thePath;
-(void)seeMovie:(NSURL*)url;

@end
