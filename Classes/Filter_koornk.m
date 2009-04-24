//
//  Filter_koornk.m
//  MakeMoney
//
#import "Filter_koornk.h"
#import "JSON.h"

@implementation Filter_koornk

- (NSString*)pageParamName
{
	return @"page";
}

- (NSString*)limitParamName
{
	return @"limit";
}

- (NSString*)filter:(NSString*)information
{
	NSLog(@"FILTERING %@", information);
	NSArray* kokodajsi = [[information JSONValue] objectForKey:@"list"];
	NSLog(@"KOKODAJSOV: %i", [kokodajsi count]);
	NSString* behavior = @"\"behavior\":{\"stop\":\"false\"}";
	NSMutableString *transends = [NSMutableString stringWithString:@"["];
	NSUInteger i, count = [kokodajsi count];
	for (i = 0; i < count; i++) {
		NSDictionary* koo = (NSDictionary*)[kokodajsi objectAtIndex:i];
		NSMutableString * status = [[[koo valueForKey:@"status"] mutableCopy] autorelease];
		[status replaceOccurrencesOfString:@"\"" withString:@"'" options:0 range:NSMakeRange(0, [status length])];
		[transends appendFormat:@"{\"name\":\"MessageView\", \"options\":{\"message\":\"%@\", \"image\":\"main.png\"}, %@},", status, behavior];
		NSLog(@"KOO %i = %@", i, koo);

	}
	NSLog(@"ALMOST FILTERED LISINTG %@", transends);
	
	transends = [NSString stringWithFormat:@"%@]", [transends substringToIndex:transends.length-1]];
	NSLog(@"FILTERED LISINTG %@", transends);

	return transends; 
	//return @"[{\"name\":\"FecherView\", \"options\":{\"button_title\":\"+kokodajsrlni\", \"url\":\"http://www.koornk.com/api/timeline/ikoodeveloper\", \"method\":\"get\", \"page\":1, \"limit\":10, \"params\":\"username=ikoodeveloper&password=ikooikoo\", \"filter\":\"koornk\"}, \"behavior\":{\"stop\":\"true\"}}]";
}

@end
