//
//  KopterViewController.m
//  MakeMoney
//
#import "KopterViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "JSON.h"
#import "URLUtils.h"
#import "iAnnotationView.h"
#import <MapKit/MapKit.h>
#import <QuartzCore/QuartzCore.h>

@implementation KopterPlaceMark
@synthesize coordinate;

- (NSString *)subtitle
{
	return @"Put some text here";
}

- (NSString *)title
{
	return @"kopter";
}

-(id)initWithCoordinate:(CLLocationCoordinate2D)c
{
	coordinate=c;
	return self;
}
@end

@implementation KopterViewController

- (IBAction)kopterButtonPushed:(id)sender 
{ 
	if (location) {
		if (!geoCoder) {
			geoCoder=[[MKReverseGeocoder alloc] initWithCoordinate:location.coordinate];
			geoCoder.delegate=self;
		}
		[geoCoder setCoordinate:location.coordinate];
		[geoCoder start];
	}
}

- (IBAction)pickButtonPushed:(id)sender {
	[notControls setPickDelegate:self];
	[notControls pickInView:worldView];
}

#pragma mark notControls pick delegate
- (void)picked:(NSDictionary*)info
{
	DebugLog(@"uploading...");
	if (info) {
		NSString *image_path = [Kriya imageWithInMemoryImage:[info valueForKey:UIImagePickerControllerOriginalImage]];
		[littleArrowView setImage:[Kriya imageWithUrl:image_path]];
		/*		[indica setHidden:NO];
		[indica startAnimating];
		NSString* success = [www uploadWithPikchur:image_path withDescription:@"raddarkopter" andLocation:location];
		DebugLog(@"uploaded : %@", success);
		[indica stopAnimating];*/
	}
}

#pragma mark MKReverseGeocoderDelegate methods
- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFailWithError:(NSError *)error 
{
	NSArray *keys = [NSArray arrayWithObjects:@"status", nil];
	NSArray *objects = [NSArray arrayWithObjects:[NSString stringWithFormat:@"#raddarkopter lat:%F lon:%F .", location.coordinate.latitude, location.coordinate.longitude], nil];
	NSDictionary *params = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
	[www fechUpdateWithParams:params];
}

- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFindPlacemark:(MKPlacemark *)placemark
{
	
	[worldView setCenterCoordinate:placemark.coordinate];
	KopterPlaceMark *p=[[[KopterPlaceMark alloc] initWithCoordinate:placemark.coordinate]autorelease];
	[worldView addAnnotation:p];
	
	NSArray *keys = [NSArray arrayWithObjects:@"status", nil];
	NSArray *objects = [NSArray arrayWithObjects:[NSString stringWithFormat:@"#raddarkopter lat:%F lon:%F . %@, %@", placemark.coordinate.latitude, placemark.coordinate.longitude, [placemark locality], [placemark country]], nil];
	NSDictionary *params = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
	[www fechUpdateWithParams:params];
}

- (MKAnnotationView *) mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>) annotation{
	iAnnotationView *annView=[[iAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"currentloc"];
/*	MKPinAnnotationView *annView=[[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"currentloc"];
	annView.animatesDrop=TRUE;
	if([annotation title]==@"kopter")
	{
		[annView setPinColor:MKPinAnnotationColorGreen];
	}
	else
	{
		[annView setPinColor:MKPinAnnotationColorRed];
	}*/
	return annView;
}

#pragma mark CLLocationManagerDelegate methods
- (void)locatus {
	if (locationManager) {
		DebugLog(@"Updating position on Earth every 100m...");
		[locationManager startUpdatingLocation];
	}
}
- (void)dislocatus {
	if (locationManager) {
		DebugLog(@"Stopped updating position on Earth");
		[locationManager stopUpdatingLocation];		
	}	
}

- (void)locationManager:(CLLocationManager *)manager
	didUpdateToLocation:(CLLocation *)newLocation
		   fromLocation:(CLLocation *)oldLocation {
	DebugLog(@"Got location: %d, %d", newLocation.coordinate.latitude, newLocation.coordinate.longitude);
	[manager stopUpdatingLocation];
	
	if (location){
		[location release];
	}
	location = [newLocation retain];

	MKCoordinateRegion region;
	region.center=location.coordinate;
	//Set Zoom level using Span
	MKCoordinateSpan span;
	span.latitudeDelta=.005;
	span.longitudeDelta=.005;
	region.span=span;
	
	[worldView setRegion:region animated:TRUE];
	DebugLog(@"Location changed to Lat:%F Lon:%F", location.coordinate.latitude, location.coordinate.longitude);
	if (!tiktak)
		[self startik];
}

- (void)locationManager:(CLLocationManager *)manager
	   didFailWithError:(NSError *)error {
	DebugLog(@"Failed updating location.");
}

#pragma mark IIWWWDelegate
- (void)notFeched:(NSString*)err
{
	DebugLog(@"#notFeched %@ : %@", [self.options valueForKey:@"url"], err);
	//[indica stopAnimating];	
	
}

- (void)feched:(id)information
{
	if ([information isKindOfClass:[NSDictionary class]]) { //fresh list of locations, lets build it
		if ([information valueForKey:@"list"]) {
			if (kopters) {
				[kopters release];//replace previous kopters with fresh kopter locations
				kopters = nil;
			}
			kopters = [[NSMutableArray alloc] initWithCapacity:50];
			NSArray* kokodajsi = [information objectForKey:@"list"];
			for (id koo in kokodajsi) {
				NSString *kopter = [koo valueForKey:@"status"];
				if ([kopter hasPrefix:@"#raddarkopter lat:"]) {
					NSScanner *scanner = [NSScanner scannerWithString:kopter];
					NSString *lat_s;
					NSString *lon_s;
					[scanner scanUpToString:@"lat:" intoString:nil]; //move to next occurence of pre
					[scanner setScanLocation:[scanner scanLocation] + 4]; //move past :
					[scanner scanUpToString:@" " intoString:&lat_s];
					[scanner setScanLocation:[scanner scanLocation] + 5]; //move past lon:
					[scanner scanUpToString:@" ." intoString:&lon_s]; //scan up to latlon end
					CLLocationDegrees lat = [lat_s doubleValue];
					CLLocationDegrees lon = [lon_s doubleValue];
					//DebugLog(@"LONGITUDE VALUE [%@] [%@]", lat_s, lon_s);
					//DebugLog(@"LONGITUDE VALUE %F %F", lat, lon);

					CLLocation *loc = [[CLLocation alloc] initWithLatitude:lat longitude:lon];
					[kopters addObject:loc];
					//DebugLog(@"added kopter %@", loc);
					[loc release];
				} else {
					//DebugLog(@"not a kopter");
				} //if it is not a raddarkopter rekord, just drop it
			}
			DebugLog(@"feched %i kopters", [kopters count]);

		} else if ([information valueForKey:@"status"]) {
				//this must be the returned status
				DebugLog(@"REKORDED %@", information);			
		} else {
				//unknown things
				DebugLog(@"REKORDED %@", information);
		}
	} else {
		//this shuld nut hupen
		DebugLog(@"THIS SHOULD NOT HAPPEN %@", information);
	}
}
#pragma mark NSTimer
- (void)startfecher 
{
	//DebugLog(@"startik");
	if (fecher) {
		DebugLog(@"IS IT HERE?");
		if ([fecher respondsToSelector:@selector(invalidate)])
			[fecher invalidate];
		[fecher release];
	}
	fecher = [[NSTimer scheduledTimerWithTimeInterval:10.0
											   target:self 
											 selector:@selector(fech:)
											 userInfo:nil
											  repeats:YES] retain];	
	
}

- (void)fech:(NSTimer*)t 
{
	[www fech];
}

- (void)startik 
{
	//DebugLog(@"startik");
	if (tiktak) {
		[tiktak invalidate];
		[tiktak release];
	}
	tiktak = [[NSTimer scheduledTimerWithTimeInterval:1.0
											   target:self 
											 selector:@selector(taktik:)
											 userInfo:nil
											  repeats:YES] retain];	
}

- (void)taktik:(NSTimer*)t {
	//check how far we moved from last known location
	//if far enough, check if any kopters are in radius of current location
	//DebugLog(@"taktik");
	if (location&&kopters) {
		for(id kopter in kopters) {
		    CLLocationDistance distance = [location getDistanceFrom:(CLLocation*)kopter];
			//DebugLog(@"distance from %@ to %@", location, kopter);
			//DebugLog(@"distance = %f", distance);
			if (distance<=kKopterRadius) {
				//notifiy
				//DebugLog(@"KOPTER!");
				[self kopterHere];
				//flashhhlajts
				MKPlacemark *p = [[[MKPlacemark alloc] initWithCoordinate:[(CLLocation*)kopter coordinate] addressDictionary:nil] autorelease];
				//add placemark
				[worldView addAnnotation:p];

				break;
			}
		}
	}
}

//end all timers
- (void)endtiks {
	if (tiktak) {
		[tiktak invalidate];
		[tiktak release];
	}
	if (fecher) {
		[fecher invalidate];
		[fecher release];
	}
}

#pragma mark Effects
- (void)animateKopter 
{
	CATransition *animation = [CATransition animation];
	[animation setType:kCATransitionFade];
	[animation setDuration:0.83];
	[animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
	//[animation setSubtype:kCATransitionFromBottom];
	[[overKopter layer] addAnimation:animation forKey:@"kopterAnimation"];
}

- (void)kopterHere
{
	if (!overKopter) {
		//overKopter = [[UIView alloc] initWithFrame:CGRectMake(63, 2, 100, 40)];
		overKopter = [[UIView alloc] initWithFrame:CGRectMake(0, 44, 480, 276)];
		[overKopter setBackgroundColor:[UIColor blueColor]];
		[overKopter setAlpha:0.38];
		UILabel *msg = [[UILabel alloc] initWithFrame:CGRectMake(40, 116, 400, 44)];
		msg.text = @"RADDARKOPTER";
		msg.backgroundColor = [UIColor clearColor];
		msg.textColor = [UIColor redColor];
		msg.font = [UIFont boldSystemFontOfSize:38.0];
		msg.textAlignment = UITextAlignmentCenter;
		msg.shadowColor = [UIColor whiteColor];
		msg.shadowOffset = CGSizeMake(1,1);
		
		[overKopter addSubview:msg];
	}
	[self animateKopter];
	[self.view addSubview:overKopter];
}

- (void)kopterClear 
{
	[overKopter removeFromSuperview];
}

#pragma mark IIController overrides
- (void)functionalize {
	if (www)
		[www release];
	www = [[IIWWW alloc] initWithOptions:options];
	//[www setProgressDelegate:progress];
	[www setDelegate:self];
	if ([options valueForKey:@"background"])
		[background setImage:[self.transender imageNamed:[options valueForKey:@"background"]]];	
	if (!locationManager) { //create only if not here
		locationManager = [[CLLocationManager alloc] init];
		[locationManager setDelegate:self];
		[locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
		[locationManager setDistanceFilter:100.0]; //every hundred meters check if there are kopters near :D
	}
	/*Region and Zoom*/
	MKCoordinateRegion region;
	MKCoordinateSpan span;
	span.latitudeDelta=0.2;
	span.longitudeDelta=0.2;
	
	CLLocationCoordinate2D loc=worldView.userLocation.coordinate;
	
	loc.latitude=46.055;//40.814849;
	loc.longitude=14.514;//-73.622732;
	region.span=span;
	region.center=loc;
	
	[worldView setRegion:region animated:TRUE];
	[worldView regionThatFits:region];

	if (!kopterbar) {
		kopterbar = [[[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 480, 44)] autorelease];
		[kopterbar setBarStyle:UIBarStyleBlackOpaque];
		
		UIBarButtonItem *flexi = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease];		
		UIBarButtonItem *fixi = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil] autorelease];		
		[fixi setWidth:44.0];
		kopterButton = [[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"finger.png"] style:UIBarButtonItemStylePlain target:self action:@selector(kopterButtonPushed:)] autorelease];	
		[kopterButton setWidth:44.0];
		pickButton = [[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"photo_icon.png"] style:UIBarButtonItemStylePlain target:self action:@selector(pickButtonPushed:)] autorelease];		
		[pickButton setWidth:44.0];
		[kopterbar setItems:[NSArray arrayWithObjects:flexi, kopterButton, pickButton, fixi, nil]];
		
		littleArrowView = [[LittleArrowView alloc] initWithFrame:CGRectMake(442, 2, 38, 38) image:nil round:10 alpha:1.0];
		[littleArrowView addTarget:self action:@selector(pickButtonPushed:) forControlEvents:UIControlEventTouchUpInside];
		[self.view addSubview:littleArrowView];
		[self.view insertSubview:kopterbar belowSubview:littleArrowView];

	}	
}

- (void)stopFunctioning {
	//[self endtiks];
	DebugLog(@"KopteriewController#stopFunctioning");
	//[self dislocatus];
}
- (void)startFunctioning {
	DebugLog(@"KopterViewController#startFunctioning");
	//this is ljubljana, default loc
	location = [[CLLocation alloc] initWithLatitude:46.055 longitude:14.514];
//	CLLocation *location2 = [[CLLocation alloc] initWithLatitude:46.056 longitude:14.514];
//	DebugLog(@"distance between ljubljanas %F", [location getDistanceFrom:location2]);
	[self locatus];
	[self startfecher];
	[self kopterClear];
}

- (void)dealloc {
	[littleArrowView dealloc];
	[tiktak invalidate];
	[fecher invalidate];
	[tiktak release];
	[fecher release];
	[overKopter release];
	[location release];
	[locationManager release];
	[geoCoder release];
	[www release];
    [super dealloc];
}
@end
