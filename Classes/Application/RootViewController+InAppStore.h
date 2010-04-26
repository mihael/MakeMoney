//
//  MainViewController+InAppStore.h
//  MakeMoney
//

#import "RootViewController.h"
#import <StoreKit/StoreKit.h>

@interface RootViewController (InAppStore) <SKProductsRequestDelegate, UIAlertViewDelegate, SKPaymentTransactionObserver>

- (void)fichr1;
- (void)fichrServe;
- (void)requestProductData;
- (void)productsRequest:(SKProductsRequest*)request didReceiveResponse:(SKProductsResponse*)response;
- (void)completeTransaction: (SKPaymentTransaction *)transaction;
- (void)restoreTransaction: (SKPaymentTransaction *)transaction;
- (void) failedTransaction: (SKPaymentTransaction *)transaction;
- (void)recordTransaction: (SKPaymentTransaction *)transaction;
- (void)provideContent: (NSString*)productIdentifier;

@end
