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
	//DebugLog(@"TWITS \n%@\n", twits);
	NSString* behavior = @"\"ior\":{ \"stop\":\"false\", \"effect\":1 }";
	NSMutableString *transends = [NSMutableString stringWithString:@"["];
	NSUInteger i, count = [twits count];
	DebugLog(@"TWITS COUNT: %i", count);
	for (i = 0; i < count; i++) {
		NSDictionary* twit = (NSDictionary*)[twits objectAtIndex:i];
		NSMutableString * status = [[[twit valueForKey:@"text"] mutableCopy] autorelease];
		//extract pairs
		NSMutableArray* urls = [self extractURLPairsFrom:status];
		//find images - download them in background
		if (urls) {
			NSUInteger i, count = [urls count];
			for (i = 0; i < count; i++) {
				URLPair* urlpair = (URLPair*)[urls objectAtIndex:i];
				NSString* imageLink = [IIFilter assetUrl:urlpair.url];
				if (imageLink) {
					//add the same message for all images found in this status
					//remove this image link from status so it does not bloat information
					[status replaceOccurrencesOfString:urlpair.url withString:@"" options:0 range:NSMakeRange(0, [status length])];
					[transends appendFormat:@"{\"ii\":\"MessageView\", \"ions\":{\"message\":\"text\", \"data\":%@, \"icon_url\":\"%@\", \"background_url\":\"%@\"}, %@},", [twit JSONRepresentation], [[twit valueForKey:@"user"] valueForKey:@"profile_image_url"], imageLink, behavior];
					NSLog(@"TWIT: %@", status);
					
				}
			}
			if (count<=0)
				[transends appendFormat:@"{\"ii\":\"MessageView\", \"ions\":{\"message\":\"text\", \"data\":%@, \"icon_url\":\"%@\", \"background_url\":\"%@\"}, %@},", [twit JSONRepresentation], [[twit valueForKey:@"user"] valueForKey:@"profile_image_url"], [[twit valueForKey:@"user"] valueForKey:@"profile_background_image_url"], behavior];
		} else {
			[transends appendFormat:@"{\"ii\":\"MessageView\", \"ions\":{\"message\":\"text\", \"data\":%@, \"icon_url\":\"%@\", \"background_url\":\"%@\"}, %@},", [twit JSONRepresentation], [[twit valueForKey:@"user"] valueForKey:@"profile_image_url"], [[twit valueForKey:@"user"] valueForKey:@"profile_background_image_url"], behavior];
		}

		
	}
	transends = [NSString stringWithFormat:@"%@]", [transends substringToIndex:transends.length-1]];
	NSLog(@"TWITTER FILTERED:\n%@\n", transends);
	return transends; 
}

@end
