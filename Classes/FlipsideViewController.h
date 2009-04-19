//
//  FlipsideViewController.h
//  MakeMoney
//
#import <UIKit/UIKit.h>
#import "ASIHTTPRequest.h"
#import "ASINetworkQueue.h"
#import "IIController.h"

@class ASINetworkQueue;

@interface FlipsideViewController : IIController <UIWebViewDelegate>{
	ASINetworkQueue *networkQueue;	
	IBOutlet UIProgressView *progressIndicator;	 
	IBOutlet UILabel *version;
	IBOutlet UILabel *startups;
	IBOutlet UILabel *moneymade;
	IBOutlet UILabel *app_runs;
	IBOutlet UIWebView *web;
	IBOutlet UIActivityIndicatorView *indica;
}

- (void)showStartupCount:(ASIHTTPRequest *)request;
@end
