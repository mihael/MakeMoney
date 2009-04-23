//
//  MessageViewController.h
//  MakeMoney
//
#import <UIKit/UIKit.h>
#import "IIController.h"

@interface MessageViewController : IIController
{
	IBOutlet UIImageView* background;
	IBOutlet UIActivityIndicatorView *indica;
}
@property (readonly) IBOutlet UIImageView* background;
@property (readonly) IBOutlet UIActivityIndicatorView *indica;

- (void)loadMessage;

@end
