//
//  FecherViewController.h
//  MakeMoney
//
#import "IIController.h"
#import "IIWWW.h"

@class IIWWW;

@interface FecherViewController : IIController <IIWWWDelegate> {
	IBOutlet UIImageView *background;
	IBOutlet UIButton *button;
	IBOutlet UIActivityIndicatorView *indica;
	IIWWW *www;
}
- (IBAction)buttonTouched:(id)sender;
@end
