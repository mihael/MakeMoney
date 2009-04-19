//
//  IITransenderController.h
//  MakeMoney
//
#import <UIKit/UIKit.h>
#import "IITransender.h"
#import "IIMusic.h"
#import "IITransenderView.h"
#import "IINotControls.h"
#import "IIWWW.h"
#define kTransendAnimated YES
#define kTransendAnimationSpeed 0.79 //not used

@protocol IITransenderViewControllerDelegate <NSObject>
- (void)transending;
- (void)meditating;
- (void)moviesStart;
- (void)moviesEnd;
@end

@class IITransender;

@interface IITransenderViewController : UIViewController 
<IINotControlsDelegate, 
 IITransenderDelegate, 
 IIWWWDelegate,
 IIMusicDelegate, 
 IITransenderViewDelegate> 
{
    id <IITransenderViewControllerDelegate> delegate;
		IITransenderView *skrin;
		IITransender *transender;
		IIMusic *music;
		NSTimer *magic;
		BOOL feeling;	
		UIViewController *transendController;
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
@property (readwrite, retain) UIViewController *transendController;
@property (readwrite) BOOL feeling;
@property (readwrite, retain) NSString* listingName;
@property (readwrite, retain) NSDictionary *notBehavior;

- (id)initWithTransendsListing:(NSString*)aListingName andStage:(NSDictionary*)aStageName;

- (void)transendedWithView:(UIViewController*)transend andBehavior:(NSDictionary*)behavior;
- (void)transendedWithMovie:(NSString*)transend andBehavior:(NSDictionary*)behavior;
- (void)transendedWithMusic:(NSString*)transend andBehavior:(NSDictionary*)behavior;
- (void)transendedWithImage:(UIImage*)transend andBehavior:(NSDictionary*)behavior;
- (void)transendedAll:(id)sender;

- (void)transitionViewDidStart:(IITransenderView *)view;
- (void)transitionViewDidFinish:(IITransenderView *)view;
- (void)transitionViewDidCancel:(IITransenderView *)view;

- (void)transit:(UIView*)wiev;
@end
