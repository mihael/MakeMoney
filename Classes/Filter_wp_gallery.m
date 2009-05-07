//
//  Filter_wp_galery.m
//  MakeMoney
//
#import "Filter_wp_gallery.h"
#import "JSON.h"
#import "URLPair.h"

@implementation Filter_wp_gallery

- (NSString*)pageParamName
{
	return @"g2_page";
}

- (NSString*)limitParamName
{
	return @"limit";
}

- (NSString*)filter:(NSString*)information withOptions:(NSDictionary*)options
{
	DebugLog(@"FILTERING WP %@", information);
	NSString* base_url = @"";
	if (options) {
		if (![options valueForKey:@"filter_base_url"]) {
			base_url = [options valueForKey:@"url"];
		} else {
			base_url = [options valueForKey:@"filter_base_url"];
		}
	}
	
	NSMutableArray* urls = [self extractFrom:information withPrefix:@"<img src=\"" andSuffix:@"\""];
	NSMutableString *transends = [NSMutableString stringWithString:@"["];
	NSUInteger i, count = [urls count];
	for (i = 0; i < count; i++) {
		NSString* link = [urls objectAtIndex:i];
		[transends appendFormat:@"{\"ii\":\"message\", \"ions\":{\"background_url\":\"%@/%@\"}, %@},", base_url, [link stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"], k_ior_notstop];
	}
	return [NSString stringWithFormat:@"%@]", [transends substringToIndex:transends.length-1]];
}
@end
