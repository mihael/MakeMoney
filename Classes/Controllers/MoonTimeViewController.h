//
//  MoonTimeViewController.h
//  MakeMoney
//
#import <UIKit/UIKit.h>
#import "ASIHTTPRequest.h"
#import "ASINetworkQueue.h"
#import "IIController.h"

@class ASINetworkQueue;

@interface MoonTimeViewController : IIController {
	ASINetworkQueue *networkQueue;	
	IBOutlet UIImageView* moonView;
	IBOutlet UIActivityIndicatorView *indica;
	
}

@property (readonly) IBOutlet UIImageView* moonView;
@end
