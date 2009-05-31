//
//  PusherViewController.h
//  MakeMoney
//
#import "IIController.h"
#import "IIWWW.h"
#import "iIconView.h"
#import <CoreLocation/CoreLocation.h>

@class IIWWW;
@class iIconView;

@interface PusherViewController : IIController <IIWWWDelegate, CLLocationManagerDelegate>
{
	IBOutlet UIImageView* background;
	IBOutlet UILabel* message;

	UIToolbar* pusherbar;
	UIBarButtonItem *pusherButton;
	UIBarButtonItem *pickButton;

	iIconView* selectedImageView;
	BOOL imageSelected;
	NSString* selectedImagePath;
	NSString* locationText;

	IIWWW *www;
	CLLocation *location;
	CLLocation *transendedLocation;
	CLLocationManager *locationManager;
}

- (IBAction)pusherButtonPushed:(id)sender;
- (IBAction)pickButtonPushed:(id)sender;

- (void)feched:(id)information;
- (void)notFeched:(NSString*)err;

- (void)feched:(id)information;
- (void)notFeched:(NSString*)err;

- (void)uploadSelectedImage;
- (void)pushWith:(NSString*)text;
- (NSString*)googleMapsUrlFor:(CLLocationCoordinate2D)coor;


@end
