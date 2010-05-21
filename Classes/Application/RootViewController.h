//
//  RootViewController.h
//  MakeMoney
//
#import "IIController.h"
#import "IITransenderViewController.h"
#import <StoreKit/StoreKit.h>

@class IIController;
@class IITransenderViewController;

@interface RootViewController : IIController <IITransenderViewControllerDelegate, SKPaymentTransactionObserver> {
    IITransenderViewController *transenderViewController;
    IIController *flipsideViewController;
}
@property (nonatomic, retain) IITransenderViewController *transenderViewController;

- (void)playBackgroundRadio;
- (void)bringUpTheWifiAppUnabler;
@end
