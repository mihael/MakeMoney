//
//  Filter_promet_list.m
//  MakeMoney
//
#import "Filter_promet_list.h"
#import "JSON.h"
#import "URLPair.h"

@implementation Filter_promet_list

- (NSString*)filter:(NSString*)information withOptions:(NSDictionary*)options
{
	//DebugLog(@"FILTERING promet.si %@", information);
	NSString* base_url = @"";
	if (options) {
		if (![options valueForKey:@"filter_base_url"]) {
			base_url = [options valueForKey:@"url"];
		} else {
			base_url = [options valueForKey:@"filter_base_url"];
		}
	}
	NSMutableArray* urls = [IIFilter extractFrom:information withPrefix:@"<a href=\"" andSuffix:@"</a>"];
	NSMutableString *transends = [NSMutableString stringWithString:@"["];
	NSUInteger i, count = [urls count];
	for (i = 0; i < count; i++) {
		NSArray *hrefAndTitle = [[urls objectAtIndex:i] componentsSeparatedByString:@"\">"];
		if (hrefAndTitle)
			if ([[hrefAndTitle objectAtIndex:0] hasPrefix:@"?id=25&cloc="]) //link contains cloc= param
				[transends appendFormat:@"{\"ii\":\"FecherView\", \"ions\":{\"message\":\"%@\", \"url\":\"%@/%@\", \"filter\":\"promet_webcam\", \"filter_base_url\":\"%@\"}, %@},", [hrefAndTitle objectAtIndex:1], base_url, [hrefAndTitle objectAtIndex:0], base_url, k_ior_stop];
	}
	return [NSString stringWithFormat:@"%@]", [transends substringToIndex:transends.length-1]];
}
@end
