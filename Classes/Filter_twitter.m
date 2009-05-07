//
//  Filter_twitter.m
//  MakeMoney
//
#import "Filter_twitter.h"
#import "JSON.h"
#import "URLPair.h"
#import "MessageViewController.h"

@implementation Filter_twitter

- (NSString*)pageParamName
{
	return @"page";
}

- (NSString*)limitParamName
{
	return @"count";
}

- (NSString*)filter:(NSString*)information withOptions:(NSDictionary*)options
{
	NSArray* twits = [information JSONValue];
	NSMutableString *transends = [NSMutableString stringWithString:@"["];
	NSUInteger i, twits_count = [twits count];

	for (i = 0; i < twits_count; i++) {
		NSMutableDictionary* twit = [(NSDictionary*)[twits objectAtIndex:i] mutableCopy];
		NSMutableString * text = [[[twit valueForKey:@"text"] mutableCopy] autorelease];
		
		//extract pairs
		NSMutableArray* urls = [self extractURLPairsFrom:text];
		NSMutableArray* user_ids = [NSMutableArray arrayWithCapacity:1];
		NSMutableArray* asset_urls = [NSMutableArray arrayWithCapacity:1];

		if (urls) {
			NSUInteger j, urls_count = [urls count];
			for (j = 0; j < urls_count; j++) {
				URLPair* urlPair = (URLPair*)[urls objectAtIndex:j];
				NSString* assetUrl = [IIFilter assetUrl:urlPair.url];
				if (urlPair.name) { //this is a userid
					[user_ids addObject:urlPair.name];
				} else if (assetUrl) {
					//remove this image link from status so it does not bloat information
					[text replaceOccurrencesOfString:urlPair.url withString:@"" options:0 range:NSMakeRange(0, [text length])];
					[twit setValue:text forKey:@"text"];
					[asset_urls addObject:assetUrl];					
				}				
			}//for urls

			if ([asset_urls count]<=0) { //no usable urls
//				[transends appendFormat:@"{\"ii\":\"MessageView\", \"ions\":{\"message\":\"text\", \"data\":%@, \"icon_url\":\"%@\", \"background_url\":\"%@\"}, %@},", [twit JSONRepresentation], [[twit valueForKey:@"user"] valueForKey:@"profile_image_url"], [[twit valueForKey:@"user"] valueForKey:@"profile_background_image_url"], k_ior_notstop];
				[transends appendFormat:[MessageViewController transendFormat], @"text", [twit JSONRepresentation], [[twit valueForKey:@"user"] valueForKey:@"profile_image_url"], [[twit valueForKey:@"user"] valueForKey:@"profile_background_image_url"], k_ior_notstop];
			} else { //add this message with all images/assets found in this message
				NSUInteger k, c = [asset_urls count];
				for (k = 0; k < c; k++) {
					[transends appendFormat:[MessageViewController transendFormat], @"text", [twit JSONRepresentation], [[twit valueForKey:@"user"] valueForKey:@"profile_image_url"], [asset_urls objectAtIndex:k], k_ior_notstop];					
				}
			}
			
			if ([user_ids count]>0) {
				NSUInteger x, uc = [user_ids count];
				for (x = 0; x < uc; x++) {
					NSString* user_id = [user_ids objectAtIndex:x];
					[transends appendFormat:@"{\"ii\":\"FecherView\", \"ions\":{\"button_title\":\"Fech %@?\", \"background\":\"main.png\", \"url\":\"http://twitter.com/statuses/user_timeline.json\", \"method\":\"get\", \"page\":1, \"params\":\"screen_name=%@\", \"filter\":\"twitter\"}, %@},", user_id, user_id, k_ior_stop];
				}
			}

		} else { //no urls in status
			[transends appendFormat:[MessageViewController transendFormat], @"text", [twit JSONRepresentation], [[twit valueForKey:@"user"] valueForKey:@"profile_image_url"], [[twit valueForKey:@"user"] valueForKey:@"profile_background_image_url"], k_ior_notstop];
		}
		
	}
	transends = [NSString stringWithFormat:@"%@]", [transends substringToIndex:transends.length-1]];
	//NSLog(@"TWITTER FILTERED:\n%@\n", transends);
	return transends; 
}

@end
