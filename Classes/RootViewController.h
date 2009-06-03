//
//  RootViewController.h
//  MakeMoney
//
#import "IINotControls.h"
#import "IIController.h"
#import "IITransenderViewController.h"

@class IINotControls;
@class IIController;
@class IITransenderViewController;

@interface RootViewController : UIViewController <IITransenderViewControllerDelegate> {
	IINotControls *notControls;
    IITransenderViewController *transenderViewController;
    IIController *flipsideViewController;
}
@property (nonatomic, retain) IINotControls *notControls;
@property (nonatomic, retain) IITransenderViewController *transenderViewController;

- (void)playBackgroundRadio;
- (void)bringUpTheWifiAppUnabler;
@end
