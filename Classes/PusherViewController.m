//
//  PusherViewController.m
//  MakeMoney
//
#import "PusherViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "JSON.h"
#import "URLUtils.h"
#import <QuartzCore/QuartzCore.h>

@implementation PusherViewController

- (IBAction)pusherButtonPushed:(id)sender 
{ 
	/*
	if (geoCoder) {
		[geoCoder release];
		geoCoder = nil;
	}
	geoCoder=[[MKReverseGeocoder alloc] initWithCoordinate:location.coordinate];
	[geoCoder setDelegate:self];
	[geoCoder start];
	 */
	//[notControls setProgress:@"Locating ..." animated:YES];
}

- (IBAction)pickButtonPushed:(id)sender {
	if (![www isAuthenticatedWithPikchur]) {
		[notControls setProgress:@"Preparing uploads..." animated:YES];
		[www authenticateWithPikchur];
	} else {
		[notControls setPickDelegate:self];
		[notControls pickInView:worldView];
	}
}

#pragma mark notControls pick delegate
- (void)picked:(NSDictionary*)info
{
	if (info) {
		[selectedImagePath release];
		selectedImagePath = [[Kriya imageWithInMemoryImage:[info valueForKey:UIImagePickerControllerOriginalImage]] retain];
		[selectedImageView setImage:[Kriya imageWithUrl:selectedImagePath]];
		[selectedImageView setHidden:NO];
		imageSelected = YES;
	}
}

#pragma mark MKReverseGeocoderDelegate methods
- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFailWithError:(NSError *)error 
{
	//NSArray *keys = [NSArray arrayWithObjects:@"status", nil];
	//NSArray *objects = [NSArray arrayWithObjects:[NSString stringWithFormat:@"#raddarkopter lat:%F lon:%F .", location.coordinate.latitude, location.coordinate.longitude], nil];
	//NSDictionary *params = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
	[[iAlert instance] alert:@"Reverse Geocoder" withMessage:@"You are not located."];
}

- (void)uploadSelectedImage
{
	[notControls setProgress:@"Uploading ..." animated:YES];
	[www fechUploadWithPikchur:selectedImagePath withDescription:locationText andLocation:location andProgress:nil];
}

- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFindPlacemark:(MKPlacemark *)placemark
{
	NSString *shortUrl = [self googleMapsUrlFor:placemark.coordinate];
	if (shortUrl!=nil) {
		locationText = [[NSString stringWithFormat:@"#raddarkopter lat:%F lon:%F %@, %@ %@", placemark.coordinate.latitude, placemark.coordinate.longitude, [placemark locality], [placemark country], shortUrl] retain];	
	} else {
		locationText = [[NSString stringWithFormat:@"#raddarkopter lat:%F lon:%F %@, %@", placemark.coordinate.latitude, placemark.coordinate.longitude, [placemark locality], [placemark country]] retain];	
	}
	
	KopterPlaceMark *p=[[[KopterPlaceMark alloc] initWithCoordinate:placemark.coordinate andTitle:@"YOU"] autorelease];
	[worldView setCenterCoordinate:placemark.coordinate];
	[worldView addAnnotation:p];
	//if image, send to pikchur and get back url, then send position with url
	if (imageSelected) {		
		DebugLog(@"SENDING KOPTER POSITION with image %@", selectedImagePath);
		[self uploadSelectedImage];
	} else {
		//just send position
		DebugLog(@"SENDING KOPTER POSITION");
		[self raddarkopterWith:locationText];			
	}
}

//get short link for google maps 
- (NSString*)googleMapsUrlFor:(CLLocationCoordinate2D)coor
{
	NSString *mapsUrl = [NSString stringWithFormat:@"http://maps.google.com/maps/mm?ll=%F,%F",coor.latitude, coor.longitude];
	//NSString *mapsUrl = @"http://maps.google.com/maps/mm?ll=46.055,14.514"; //LJUBLJANA
	
	NSString *longUrl = [NSString stringWithFormat:@"http://is.gd/api.php?longurl=%@",[URLUtils encodeHTTP:mapsUrl]];
	NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString: longUrl] cachePolicy:NSURLCacheStorageNotAllowed timeoutInterval:30];
	NSURLResponse *response;
	NSError *error;
	NSData *returnData = [NSURLConnection sendSynchronousRequest:urlRequest
											   returningResponse:&response 
														   error:&error];
	NSString *shortUrl = [[[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding] autorelease];

	if (error) 
		return nil;
	return shortUrl;

}

- (void)raddarkopterWith:(NSString*)text
{
	[notControls setProgress:@"Updating ..." animated:YES];
	//send raddarkopter position
	NSArray *keys = [NSArray arrayWithObjects:@"status", nil];
	NSArray *objects = [NSArray arrayWithObjects:text, nil];
	NSDictionary *params = [NSDictionary dictionaryWithObjects:objects forKeys:keys];	
	[www fechUpdateWithParams:params];
}

- (MKAnnotationView *) mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>) annotation{
	//iAnnotationView *annView=[[iAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"currentloc"];
	MKPinAnnotationView *annView=[[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"currentloc"];
	annView.animatesDrop=TRUE;
	if([annotation title]==@"kopter")
	{
		[annView setPinColor:MKPinAnnotationColorRed];
	} else {
		[annView setPinColor:MKPinAnnotationColorPurple];
		
	}
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
	[manager stopUpdatingLocation];
	DebugLog(@"Got location: %d, %d", newLocation.coordinate.latitude, newLocation.coordinate.longitude);
	
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
	if (!tiktak) //have loc, start checking for kopters
		[self startik];
}

- (void)locationManager:(CLLocationManager *)manager
	   didFailWithError:(NSError *)error {
	DebugLog(@"Failed updating location.");
}

#pragma mark IIWWWDelegate
- (void)notFeched:(NSString*)err
{
	[notControls setProgress:nil animated:NO];
	//[[iAlert instance] alert: withMessage:@"Please retry? Thanks."];
	DebugLog(@"#notFeched %@ : %@", [self.options valueForKey:@"url"], err);	
}

- (void)feched:(id)information
{
	if ([information isKindOfClass:[NSDictionary class]]) { //fresh list of locations, lets build it

		if ([information valueForKey:@"auth_key"]) 
		{
			//this comes from authenticating with pikchur for the first and last time
			[notControls setProgress:nil animated:YES];
		} 
		else if ([information valueForKey:@"post"]) 
		{
			//this comes from pikchur after uploading
			//send kopter position with pikchururl
			[self raddarkopterWith:[NSString stringWithFormat:@"%@ %@", locationText, [[information valueForKey:@"post"] valueForKey:@"url"]]];
		} 
		else if ([information valueForKey:@"list"]) 
		{
			//this comes from @raddarkopter
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
					[scanner scanUpToString:@" lon:" intoString:&lat_s];
					[scanner setScanLocation:[scanner scanLocation] + 5]; //move past lon:
					[scanner scanUpToString:@" " intoString:&lon_s]; //scan up to latlon end
					CLLocationDegrees lat = [lat_s doubleValue];
					CLLocationDegrees lon = [lon_s doubleValue];
					CLLocation *loc = [[CLLocation alloc] initWithLatitude:lat longitude:lon];
					[kopters addObject:loc];
					[loc release];
				}//if it is not a raddarkopter rekord, just drop it
			}
			DebugLog(@"feched %i kopters", [kopters count]);
		} 
		else if ([information valueForKey:@"status"]) 
		{
			//this must be the returned status
			DebugLog(@"REKORDED %@", information);		
			[notControls setProgress:nil animated:YES];
			imageSelected = NO;
			[selectedImageView setHidden:YES];
		} 
		else 
		{
				//unknown things
				DebugLog(@"UNKNOWN REKORDED %@", information);
				[notControls setProgress:nil animated:YES];

		}
	} else {
		//this shuld nut hupen
		DebugLog(@"THIS SHOULD NOT HAPPEN %@", information);
		[notControls setProgress:nil animated:YES];
	}
}
#pragma mark timed feching 
- (void)startfecher 
{
	if (fecher) {
		DebugLog(@"startik");
		[fecher invalidate];
		[fecher release];
		fecher = nil;
	}
	fecher = [[NSTimer scheduledTimerWithTimeInterval:kFecherSpeed
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
		tiktak = nil;
	}
	tiktak = [[NSTimer scheduledTimerWithTimeInterval:1.0
											   target:self 
											 selector:@selector(taktik:)
											 userInfo:nil
											  repeats:YES] retain];	
}

- (void)taktik:(NSTimer*)t {
	if (location&&kopters) {
		for(id kopter in kopters) {
		    CLLocationDistance kopterDistanceFromCurrentLocation = [location getDistanceFrom:(CLLocation*)kopter];
			//DebugLog(@"distance from %@ to %@", location, kopter);
			//DebugLog(@"distance = %f", distance);
			if (kopterDistanceFromCurrentLocation<=kKopterRadius) {
				BOOL rekognajzd = NO;
				for (id a in [worldView annotations]) {
					if ( [[a title] isEqualToString:@"KOPTER"] && //compare only with kopters, not YOU
						 [a coordinate].latitude==[kopter coordinate].latitude &&
						 [a coordinate].longitude==[kopter coordinate].longitude) {
						rekognajzd = YES;
						break;
					}
				}
				if (!rekognajzd) {//not yet projected unto the mind, just do it then
					DebugLog(@"KOPTER HERE!");
					[self kopterHere];
					//flashhhlajts
					KopterPlaceMark *p = [[[KopterPlaceMark alloc] initWithCoordinate:[(CLLocation*)kopter coordinate] andTitle:@"KOPTER"] autorelease];
					//add placemark
					[worldView addAnnotation:p];
					//break; //break if kopter added
				}
			}
		}
	}
}

//end all timers
- (void)endtiks {
	DebugLog(@"endtiks");
	if (tiktak) {
		[tiktak invalidate];
		[tiktak release];
		tiktak = nil;
		DebugLog(@"endtiks tiktak");
	}
	if (fecher) {
		[fecher invalidate];
		[fecher release];
		fecher = nil;
		DebugLog(@"endtiks fecher");
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
	if (!overKopter.superview) {
		[self.view addSubview:overKopter];
	}
	[self animateKopter];
}

- (void)kopterClear 
{
	if (overKopter.superview)
		[overKopter removeFromSuperview];
}

#pragma mark IIController overrides
- (void)functionalize {
	if (www)
		[www release];
	www = [[IIWWW alloc] initWithOptions:options];
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
		[kopterbar setBarStyle:UIBarStyleBlackTranslucent];
		
		UIBarButtonItem *flexi = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease];		
		UIBarButtonItem *fixi = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil] autorelease];		
		[fixi setWidth:44.0];
		kopterButton = [[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"finger.png"] style:UIBarButtonItemStylePlain target:self action:@selector(kopterButtonPushed:)] autorelease];	
		pickButton = [[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"photo_icon.png"] style:UIBarButtonItemStylePlain target:self action:@selector(pickButtonPushed:)] autorelease];		
		[kopterbar setItems:[NSArray arrayWithObjects:fixi, flexi, kopterButton, flexi, pickButton, nil]];
		
		selectedImageView = [[iIconView alloc] initWithFrame:CGRectMake(436, 0, 44, 44) image:nil round:10 alpha:1.0];
		[selectedImageView addTarget:self action:@selector(pickButtonPushed:) forControlEvents:UIControlEventTouchUpInside];
		[self.view addSubview:selectedImageView];
		[self.view insertSubview:kopterbar belowSubview:selectedImageView];
		imageSelected = NO;
	}	
}

- (void)stopFunctioning {
	[self endtiks];
	[self dislocatus];
	DebugLog(@"#stopFunctioning");
}
- (void)startFunctioning {
	DebugLog(@"#startFunctioning");
	//this is ljubljana, default loc
	if (!location) {
		location = [[CLLocation alloc] initWithLatitude:46.055 longitude:14.514];
	}		
//	CLLocation *location2 = [[CLLocation alloc] initWithLatitude:46.056 longitude:14.514];
//	DebugLog(@"distance between ljubljanas %F", [location getDistanceFrom:location2]);
	[self locatus];
	[self startfecher];
	[self kopterClear];
}

- (void)dealloc {
	[locationText release];
	[selectedImageView release];
	[location release];
	[locationManager release];
	[geoCoder release];
	[www release];
    [super dealloc];
}
@end
