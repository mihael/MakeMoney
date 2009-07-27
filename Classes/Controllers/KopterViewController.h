//
//  KopterViewController.h
//  MakeMoney
//
#import "IIController.h"
#import "IIWWW.h"
#import "LittleArrowView.h"
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#define kKopterRadius 3000 //3km 
#define kFecherSpeed 10.0

@interface KopterPlaceMark : NSObject <MKAnnotation> {
	CLLocationCoordinate2D coordinate;
	NSString *title;
}
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (readwrite, retain) NSString *title;
-(id)initWithCoordinate:(CLLocationCoordinate2D)coordinate andTitle:(NSString*)t;
@end

@class IIWWW;
@class LittleArrowView;

@interface KopterViewController : IIController <MKMapViewDelegate, MKReverseGeocoderDelegate, IIWWWDelegate, CLLocationManagerDelegate>
{
	IBOutlet UIImageView* background;
	IBOutlet UILabel* message;
	IBOutlet UIActivityIndicatorView* indica;

	UIToolbar* kopterbar;
	UIBarButtonItem *kopterButton;
	UIBarButtonItem *pickButton;
	UIView* overKopter;
	LittleArrowView* littleArrowView;
	BOOL imageSelected;
	NSString* selectedImagePath;
	NSString* locationText;

	IIWWW *www;
	CLLocation *location;
	CLLocation *transendedLocation;
	CLLocationManager *locationManager;
	MKReverseGeocoder *geoCoder;
	IBOutlet MKMapView *worldView;
	NSMutableArray *kopters;
	NSTimer *tiktak; //when to check for kopters
	NSTimer *fecher; //when to fech fresh kopters
}
- (IBAction)kopterButtonPushed:(id)sender;
- (IBAction)pickButtonPushed:(id)sender;

- (void)feched:(id)information;
- (void)notFeched:(NSString*)err;

- (void)feched:(id)information;
- (void)notFeched:(NSString*)err;

- (void)startik;
- (void)taktik:(NSTimer*)t;

- (void)startfecher;
- (void)fech:(NSTimer*)t;

- (void)kopterHere;
- (void)kopterClear;

- (void)uploadSelectedImage;
- (void)raddarkopterWith:(NSString*)text;
- (NSString*)googleMapsUrlFor:(CLLocationCoordinate2D)coor;


@end
