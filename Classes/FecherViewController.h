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
	BOOL informationFeched;
}
@property (readonly) IBOutlet UIButton *button;
@property (readonly) IBOutlet UIImageView *background;

- (IBAction)buttonTouched:(id)sender;
- (void)feched:(id)information;
- (void)notFeched:(NSString*)err;

- (void)cacheFeched:(NSArray*)list;
- (void)saveFecherList:(NSArray*)list;

@end
