//
//  MessageViewController.h
//  MakeMoney
//
#import <UIKit/UIKit.h>
#import "IIController.h"

@interface MessageViewController : IIController
{
	IBOutlet UIImageView* background;
	IBOutlet UIImageView* icon;	
	IBOutlet UILabel* message;
	IBOutlet UIActivityIndicatorView *indica;
}
@end
