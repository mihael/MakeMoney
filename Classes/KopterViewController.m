//
//  KopterViewController.m
//  MakeMoney
//
#import "KopterViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "JSON.h"

@implementation KopterViewController

- (IBAction)kopterButtonPushed:(id)sender 
{ 
	NSArray *keys = [NSArray arrayWithObjects:@"status", @"origin", nil];
	NSArray *objects = [NSArray arrayWithObjects:[NSString stringWithFormat:@"#raddarkopter lat=%@ lon=%@", [location coordinate].latitude, [location coordinate].longitude], @"raddarkopter", nil];
	NSDictionary *params = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
 	[www fechUpdateWithParams:params];
}

#pragma mark CLLocationManagerDelegate methods
- (void)locatus {
	DebugLog(@"Locating position on Earth");
	if (locationManager) {
		[locationManager startUpdatingLocation];
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
	//[locator setText:[NSString stringWithFormat:@"Lat:%F Lon:%F", newLocation.coordinate.latitude, newLocation.coordinate.longitude ]];

	//on each update check if this location is in feched locations
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
	if ([information hasPrefix:@"{"]) { //fresh list of locations, lets build it
		if (kopters)
			[kopters release];
		kopters = [NSMutableArray arrayWithCapacity:1];
		NSArray* kokodajsi = [[information JSONValue] objectForKey:@"list"];
		for (id koo in kokodajsi) {
			NSScanner *scanner = [NSScanner scannerWithString:[koo valueForKey:@"status"]];
			NSString *lat_s;
			NSString *lon_s;
			[scanner scanUpToString:@"lat:" intoString:nil]; //move to next occurence of pre
			[scanner setScanLocation:[scanner scanLocation] + 4]; //move past :
			[scanner scanUpToString:@" " intoString:&lat_s];
			[scanner scanUpToString:@"lon:" intoString:nil]; //move to next occurence of pre
			[scanner setScanLocation:[scanner scanLocation] + 4]; //move past :
			[scanner scanUpToString:@" " intoString:&lon_s];
			CLLocationDegrees lat = [lat_s floatValue];
			CLLocationDegrees lon = [lon_s floatValue];
			CLLocation *loc = [[CLLocation alloc] initWithLatitude:lat longitude:lon];
			[kopters addObject:loc];
			[loc release];
		}
	}
}
#pragma mark NSTimer
- (void)startik {
	if (tiktak) {
		[tiktak invalidate];
		[tiktak release];
	}
	tiktak = [[NSTimer scheduledTimerWithTimeInterval:1
											   target:self 
											 selector:@selector(taktik:)
											 userInfo:nil
											  repeats:YES] retain];	
}

- (void)endtik {
	if (tiktak) {
		[tiktak invalidate];
		[tiktak release];
	}
}

- (void)taktik:(NSTimer*)t {
	//check how far we moved from last known location
	//if far enough, check if any kopters are in radius of current location

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
}

- (void)stopFunctioning {
	DebugLog(@"KopteriewController#stopFunctioning");
}
- (void)startFunctioning {
	DebugLog(@"KopterViewController#startFunctioning");
	[self locatus];
	[www fech];
}

- (void)dealloc {
	[location release];
	[locationManager release];
	[www release];
    [super dealloc];
}
@end
