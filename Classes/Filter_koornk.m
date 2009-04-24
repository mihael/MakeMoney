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
		//[transends appendFormat:@"{\"name\":\"MessageView\", \"options\":{\"message\":\"%@\", \"image\":\"main.png\"}, \"behavior\":{\"stop\":\"false\"}},", status];

		//extract pairs
		NSMutableArray* urls = [self extractURLPairsFrom:status];
		NSLog(@"EXTRACTED %i URLS", [urls count]);
		//find images - download them in background
		NSUInteger i, count = [urls count];
		for (i = 0; i < count; i++) {
			URLPair* urlpair = (URLPair*)[urls objectAtIndex:i];
			
			NSString* imageLink = [IIFilter assetUrl:urlpair.url];
			NSLog(@"IMAGE LINK %@", imageLink);
			if (imageLink) {
				//add the same message for all images found in this status
				[transends appendFormat:@"{\"name\":\"remote_image\", \"options\":{\"url\":\"%@\"}, %@},", imageLink, behavior];
			}
		}

	}
	NSLog(@"ALMOST FILTERED LISTING %@", transends);
	
	transends = [NSString stringWithFormat:@"%@]", [transends substringToIndex:transends.length-1]];
	NSLog(@"FILTERED LISTING %@", transends);

	return transends; 
	//return @"[{\"name\":\"FecherView\", \"options\":{\"button_title\":\"+kokodajsrlni\", \"url\":\"http://www.koornk.com/api/timeline/ikoodeveloper\", \"method\":\"get\", \"page\":1, \"limit\":10, \"params\":\"username=ikoodeveloper&password=ikooikoo\", \"filter\":\"koornk\"}, \"behavior\":{\"stop\":\"true\"}}]";
}

@end
