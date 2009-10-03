//
//  MessageViewController.h
//  MakeMoney
//
#import <UIKit/UIKit.h>
#import "IIController.h"
#import "LittleArrowView.h"
#import "iContentView.h"

@class LittleArrowView;
@interface MessageViewController : IIController
{
	IBOutlet UIImageView* background;
	LittleArrowView* icon;	
	IBOutlet UILabel* message;
	iContentView* content;
}
@end
