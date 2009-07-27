//
//  MessageViewController.h
//  MakeMoney
//
#import <UIKit/UIKit.h>
#import "IIController.h"
#import "LittleArrowView.h"
@class LittleArrowView;
@interface MessageViewController : IIController
{
	IBOutlet UIImageView* background;
	LittleArrowView* icon;	
	IBOutlet UILabel* message;
}
@end
