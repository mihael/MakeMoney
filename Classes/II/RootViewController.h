//
//  RootViewController.h
//  MakeMoney
//
#import "IIController.h"
#import "IITransenderViewController.h"

@class IIController;
@class IITransenderViewController;

@interface RootViewController : IIController <IITransenderViewControllerDelegate> {
    IITransenderViewController *transenderViewController;
    IIController *flipsideViewController;
}
@property (nonatomic, retain) IITransenderViewController *transenderViewController;

- (void)playBackgroundRadio;
- (void)bringUpTheWifiAppUnabler;
@end
