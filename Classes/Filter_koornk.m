//
//  Filter_koornk.m
//  MakeMoney
//
#import "Filter_koornk.h"
#import "JSON.h"
#import "URLPair.h"

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
	NSArray* kokodajsi = [[information JSONValue] objectForKey:@"list"];
	NSString* behavior = @"\"behavior\":{\"stop\":\"false\"}";
	NSMutableString *transends = [NSMutableString stringWithString:@"["];
	NSUInteger i, count = [kokodajsi count];
	for (i = 0; i < count; i++) {
		NSDictionary* koo = (NSDictionary*)[kokodajsi objectAtIndex:i];
		DebugLog(@"%@", koo);

		NSMutableString * status = [[[koo valueForKey:@"status"] mutableCopy] autorelease];
		//[status replaceOccurrencesOfString:@"\"" withString:@"'" options:0 range:NSMakeRange(0, [status length])];
		//[transends appendFormat:@"{\"name\":\"MessageView\", \"options\":{\"message\":\"%@\", \"background\":\"main.png\"}, \"behavior\":{\"stop\":\"false\"}},", status];

		//extract pairs
		NSMutableArray* urls = [self extractURLPairsFrom:status];
		//find images - download them in background
		NSUInteger i, count = [urls count];
		for (i = 0; i < count; i++) {
			URLPair* urlpair = (URLPair*)[urls objectAtIndex:i];
			NSString* imageLink = [IIFilter assetUrl:urlpair.url];
			if (imageLink) {
				//add the same message for all images found in this status
				//remove this image link from status so it does not bloat information
				[status replaceOccurrencesOfString:urlpair.url withString:@"" options:0 range:NSMakeRange(0, [status length])];
				[transends appendFormat:@"{\"name\":\"MessageView\", \"options\":{\"message\":\"status\", \"data\":%@, \"icon_url\":\"%@\", \"background_url\":\"%@\"}, %@},", [koo JSONFragment], [koo valueForKey:@""], imageLink, behavior];
			}
		}
		if (count==0) { //add just message if no image included in text
			[transends appendFormat:@"{\"name\":\"MessageView\", \"options\":{\"message\":\"status\", \"data\":%@, \"background\":\"main.png\"}, \"behavior\":{\"stop\":\"false\"}},", [koo JSONFragment], status];
		}

	}
	transends = [NSString stringWithFormat:@"%@]", [transends substringToIndex:transends.length-1]];

	return transends; 
}
@end
