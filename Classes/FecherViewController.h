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
	IIWWW *www;
	BOOL trimmedSelf;
}
@property (readonly) IBOutlet UIButton *button;
@property (readonly) IBOutlet UIImageView *background;

- (IBAction)buttonTouched:(id)sender;
- (void)feched:(id)information;
- (void)notFeched:(NSString*)err;
@end
