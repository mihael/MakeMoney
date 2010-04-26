//
//  MainViewController+InAppStore.m
//  MakeMoney
//

#import "RootViewController+InAppStore.h"

#define kFichrId @"1"

@implementation RootViewController (InAppStore)

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex==1){
		SKPayment *payment = [SKPayment paymentWithProductIdentifier:kFichrId];
		[[SKPaymentQueue defaultQueue] addPayment:payment];
	}
}

- (void)showStore:(NSArray*)products
{
	SKProduct *p = [products objectAtIndex:0];
	UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:[p localizedTitle]
													 message:[p localizedDescription]
													delegate:self
										   cancelButtonTitle:NSLocalizedString(@"Not now", @"do not buy alert")
										   otherButtonTitles: nil] autorelease];
	[alert addButtonWithTitle:NSLocalizedString(@"Buy", @"buy alert")];
	[alert show];		
	
}

- (void)fichr1 {
	if ([[[NSUserDefaults standardUserDefaults] valueForKey:kFichrId] boolValue]) {
		[self fichrServe];
	} else {
		//should pay and use fichr
		[self requestProductData];
	}
}

//thi sshows the feature
- (void)fichrServe {
	//show your fichr from hir
}

- (void)requestProductData
{
	DLog(@"InAppStore#requestProductData");
	SKProductsRequest *request= [[SKProductsRequest alloc] initWithProductIdentifiers: [NSSet setWithObject: kFichrId]];
	request.delegate = self;
	[request start];
}

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
	DLog(@"InAppStore#productsRequest didReceiveResponse");
    NSArray *products = response.products;
    // populate UI
	[self showStore:products];
	DLog(@"%@", products);
    [request autorelease];
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    for (SKPaymentTransaction *transaction in transactions)
    {
        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchased:
                [self completeTransaction:transaction];
                break;
				
            case SKPaymentTransactionStateFailed:
                [self failedTransaction:transaction];
                break;
				
            case SKPaymentTransactionStateRestored:
                [self restoreTransaction:transaction];
				
            default:
                break;
				
        }
    }
}

- (void) completeTransaction: (SKPaymentTransaction *)transaction
{
	// Your application should implement these two methods.
    [self recordTransaction: transaction];
    [self provideContent: transaction.payment.productIdentifier];
	// Remove the transaction from the payment queue.
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}

- (void) restoreTransaction: (SKPaymentTransaction *)transaction
{
    [self recordTransaction: transaction];
    [self provideContent: transaction.originalTransaction.payment.productIdentifier];
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}

- (void) failedTransaction: (SKPaymentTransaction *)transaction
{
    if (transaction.error.code != SKErrorPaymentCancelled)
    {
        // Optionally, display an error here.
    }
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}

- (void)recordTransaction: (SKPaymentTransaction *)transaction 
{
	[[NSUserDefaults standardUserDefaults] setBool:YES forKey:kFichrId];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)provideContent: (NSString*)productIdentifier
{
	[self fichrServe];
}

@end
