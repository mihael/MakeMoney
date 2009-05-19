//
//  KopterViewController.h
//  MakeMoney
//
#import "IIController.h"
#import "IIWWW.h"
#import "LittleArrowView.h"
#import "iProgressView.h"
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#define kKopterRadius 3000 //3km 

@interface KopterPlaceMark : NSObject<MKAnnotation> {
	CLLocationCoordinate2D coordinate;
}
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
-(id)initWithCoordinate:(CLLocationCoordinate2D) coordinate;
- (NSString *)subtitle;
- (NSString *)title;
@end

@class IIWWW;
@class LittleArrowView;
@class iProgressView;

@interface KopterViewController : IIController <MKMapViewDelegate, MKReverseGeocoderDelegate, IIWWWDelegate, CLLocationManagerDelegate>
{
	IBOutlet UIImageView* background;
	IBOutlet UILabel* message;
	IBOutlet UIActivityIndicatorView* indica;
	iProgressView* progressView;

	UIToolbar* kopterbar;
	UIBarButtonItem *kopterButton;
	UIBarButtonItem *pickButton;
	UIView* overKopter;
	IBOutlet LittleArrowView* littleArrowView;
	BOOL imageSelected;
	NSString* selectedImagePath;
	NSString* locationText;

	IIWWW *www;
	CLLocation *location;
	CLLocation *pastLocation;
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

- (void)raddarkopterWith:(NSString*)text;

@end
