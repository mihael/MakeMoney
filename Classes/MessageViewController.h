//
//  MessageViewController.h
//  MakeMoney
//
#import <UIKit/UIKit.h>
#import "IIController.h"

@interface MessageViewController : IIController
{
	IBOutlet UIImageView* background;
	IBOutlet UILabel* message;
	IBOutlet UIActivityIndicatorView *indica;
}
@end
