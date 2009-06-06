//
//  PusherViewController.m
//  MakeMoney
//
#import "PusherViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "JSON.h"
#import "URLUtils.h"
#import <QuartzCore/QuartzCore.h>
#import "iIconView.h" 

@implementation PusherViewController

#pragma mark actions
- (IBAction)pusherButtonPushed:(id)sender 
{ 
	//if image, send to pikchur and get back url, then send position with url
	if (location) {
		if (imageSelected) {		
			//DebugLog(@"uploading image %@ %@", selectedImagePath, locationText);
			[self uploadSelectedImage];
		} else {
			[self pickButtonPushed:self];
			//just send position
			//TODO just text update koornk, twitter, kitschmaster...
			//[self pushWith:locationText];			
		}
	}
	
}

- (IBAction)pickButtonPushed:(id)sender 
{
	if ([options valueForKey:@"pikchur"]) {	
		if (![www isAuthenticatedWithPikchur]) {
			[notControls setProgress:@"Preparing uploads..." animated:YES];
			[www authenticateWithPikchur];
		} else {
			[notControls setPickDelegate:self];
			[notControls pickInView:background];
		}
	} else if ([options valueForKey:@"twitter"]) {
		[notControls setPickDelegate:self];
		[notControls pickInView:background];
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
		[background setImage:[Kriya imageWithUrl:selectedImagePath]];
		[background setHidden:NO];
		imageSelected = YES;
	}
}

#pragma mark uploading
- (void)uploadSelectedImage
{
	if ([options valueForKey:@"pikchur"]) {
		[notControls setProgress:@"Uploading ..." animated:YES];
		[www fechUploadWithPikchur:selectedImagePath withDescription:locationText andLocation:location andProgress:nil];
	} else if ([options valueForKey:@"twitter"]) {
		[notControls setProgress:@"Uploading ..." animated:YES];
		[www fechUploadWithTwitPic:selectedImagePath withDescription:locationText andLocation:location andProgress:nil];		
	} else {
		[notControls setProgress:@"Uploading to nowhere..." animated:YES];
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

- (void)pushWith:(NSString*)text
{
	[notControls setProgress:@"Updating ..." animated:YES];
	NSArray *keys = [NSArray arrayWithObjects:@"status", nil];
	NSArray *objects = [NSArray arrayWithObjects:text, nil];
	NSDictionary *params = [NSDictionary dictionaryWithObjects:objects forKeys:keys];	
	[www fechUpdateWithParams:params];
}

- (void)pushFinished 
{
	[notControls setProgress:@"Thanks" animated:YES];
	[background setImage:[self.transender imageNamed:@"main.jpg"]];
	[selectedImageView setHidden:YES];
	imageSelected = NO;
	[NSTimer scheduledTimerWithTimeInterval:0.3 target:self selector:@selector(hidePushFinished) userInfo:nil repeats:NO];
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
	if (location){
		[location release];
	}
	location = [newLocation retain];
	//locationText = [NSString stringWithFormat:@"lat:F% lon:%F %@", location.coordinate.latitude, location.coordinate.longitude, [self googleMapsUrlFor:location.coordinate]];
	[locationText release];
	NSString *shortUrl = [self googleMapsUrlFor:location.coordinate];
	if (shortUrl!=nil) {
		locationText = [[NSString stringWithFormat:@"lat:%F lon:%F %@", location.coordinate.latitude, location.coordinate.longitude, shortUrl] retain];	
	} else {
		locationText = [[NSString stringWithFormat:@"lat:%F lon:%F", location.coordinate.latitude, location.coordinate.longitude] retain];	
	}
	DebugLog(@"Location changed to Lat:%F Lon:%F", location.coordinate.latitude, location.coordinate.longitude);
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
			[self pickButtonPushed:self]; //repeat picking
		} 
		else if ([information valueForKey:@"post"]) 
		{
			//this comes from pikchur after uploading

			[self pushFinished];

			//push
			//[self pushWith:[NSString stringWithFormat:@"%@ %@", locationText, [[information valueForKey:@"post"] valueForKey:@"url"]]];
			//TODO notify about image upload koornk, twitter, kitschmaster...
		} 
		else if ([information valueForKey:@"list"]) 
		{
			//this comes from @
			DebugLog(@"feched list %@", [information valueForKey:@"list"]);
		} 
		else if ([information valueForKey:@"status"]) 
		{
			//this must be the returned status koornk
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

		NSMutableArray *urls = [IIFilter extractFrom:information withPrefix:@"<mediaurl>" andSuffix:@"</mediaurl>"];
		if ([urls count]==1)
			DebugLog(@"REKORDED %@", urls);
		[self pushFinished];
	}
}

#pragma mark Effects
- (void)hidePushFinished 
{
	CATransition *animation = [CATransition animation];
	[animation setType:kCATransitionFade];
	[animation setDuration:0.5];
	[animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
	[[notControls progressor].layer addAnimation:animation forKey:@"pushFinishedAnimation"];
	[notControls setProgress:nil animated:NO];
}



#pragma mark IIController overrides
- (void)functionalize {
	if (!www){
		www = [[IIWWW alloc] init];
		[www loadOptions:options];
		[www setDelegate:self];
	}
	if (![background image]&&[options valueForKey:@"background"])
		[background setImage:[self.transender imageNamed:[options valueForKey:@"background"]]];	
	if (!locationManager) { //create only if not here
		locationManager = [[CLLocationManager alloc] init];
		[locationManager setDelegate:self];
		[locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
		[locationManager setDistanceFilter:100.0]; //every hundred meters check if there are kopters near :D
	}
	if (!pusherbar) {
		pusherbar = [[[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 480, 44)] autorelease];
		[pusherbar setBarStyle:UIBarStyleBlackTranslucent];
		
		UIBarButtonItem *flexi = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease];		
		UIBarButtonItem *fixi = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil] autorelease];		
		[fixi setWidth:44.0];
		pusherButton = [[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"finger.png"] style:UIBarButtonItemStylePlain target:self action:@selector(pusherButtonPushed:)] autorelease];	
		pickButton = [[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"photo_icon.png"] style:UIBarButtonItemStylePlain target:self action:@selector(pickButtonPushed:)] autorelease];		
		[pusherbar setItems:[NSArray arrayWithObjects:fixi, flexi, pusherButton, flexi, pickButton, nil]];
		
		selectedImageView = [[iIconView alloc] initWithFrame:CGRectMake(436, 0, 44, 44) image:nil round:10 alpha:1.0];
		[selectedImageView addTarget:self action:@selector(pickButtonPushed:) forControlEvents:UIControlEventTouchUpInside];
		[self.view addSubview:selectedImageView];
		[self.view insertSubview:pusherbar belowSubview:selectedImageView];
		imageSelected = NO;
	}	
}

- (void)stopFunctioning {
	[self dislocatus];
	DebugLog(@"#stopFunctioning");
}
- (void)startFunctioning {
	DebugLog(@"#startFunctioning");
	if (!location) {
		location = [[CLLocation alloc] initWithLatitude:46.055 longitude:14.514];//ljubljana
	}		
	[self locatus];
}

- (void)dealloc {
	[selectedImagePath release];
	[selectedImageView release];
	[location release];
	[locationText release];
	[locationManager release];
	[www release];
    [super dealloc];
}
@end
