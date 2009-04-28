//
//  Filter_twitter.m
//  MakeMoney
//
#import "Filter_twitter.h"
#import "JSON.h"
#import "URLPair.h"

@implementation Filter_twitter

- (NSString*)pageParamName
{
	return @"page";
}

- (NSString*)limitParamName
{
	return @"count";
}

- (NSString*)filter:(NSString*)information
{
	NSArray* twits = [information JSONValue];
	NSString* behavior = @"\"behavior\":{\"stop\":\"false\"}";
	NSMutableString *transends = [NSMutableString stringWithString:@"["];
	NSUInteger i, count = [twits count];
	for (i = 0; i < count; i++) {
		NSDictionary* twit = (NSDictionary*)[twits objectAtIndex:i];
		DebugLog(@"%@", twit);

		NSMutableString * status = [[[twit valueForKey:@"text"] mutableCopy] autorelease];
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
				[transends appendFormat:@"{\"name\":\"MessageView\", \"options\":{\"message\":\"text\", \"data\":%@, \"icon_url\":\"%@\", \"background_url\":\"%@\"}, %@},", [twit JSONFragment], [[twit valueForKey:@"user"] valueForKey:@"profile_image_url"], imageLink, behavior];
			}
		}
		if (count==0) { //add just message if no image included in text
			[transends appendFormat:@"{\"name\":\"MessageView\", \"options\":{\"message\":\"text\", \"data\":%@, \"icon_url\":\"%@\", \"background_url\":\"%@\"}, \"behavior\":{\"stop\":\"false\"}},", [twit JSONFragment], [[twit valueForKey:@"user"] valueForKey:@"profile_image_url"], [[twit valueForKey:@"user"] valueForKey:@"profile_background_image_url"]];
		}
		
	}
	transends = [NSString stringWithFormat:@"%@]", [transends substringToIndex:transends.length-1]];
	NSLog(@"TWITTER FILTERED LISTING: %@", transends);
	return transends; 
}

- (NSString*)pikchurUrlFromID:(NSString*)pikID withSize:(NSString*)sizeStr {
	return [NSString stringWithFormat:@"https://s3.amazonaws.com/pikchurimages/pic_%@_%@.jpg", pikID, sizeStr];
}

@end
