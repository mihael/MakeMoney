//
//  KopterViewController.h
//  MakeMoney
//
#import "IIController.h"
#import "IIWWW.h"
#import <CoreLocation/CoreLocation.h>

@class IIWWW;

@interface KopterViewController : IIController <IIWWWDelegate, CLLocationManagerDelegate>
{
	IBOutlet UIImageView* background;
	IBOutlet UILabel* message;
	IBOutlet UIButton* kopterButton;
	IBOutlet UIActivityIndicatorView* indica;
	IIWWW *www;
	CLLocation *location;
	CLLocationManager *locationManager;
	NSMutableArray *kopters;
	NSTimer *tiktak;
}
- (IBAction)kopterButtonPushed:(id)sender;
- (void)feched:(id)information;
- (void)notFeched:(NSString*)err;

- (void)feched:(id)information;
- (void)notFeched:(NSString*)err;

@end
