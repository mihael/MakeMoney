//
//  Filter_promet_webcam.m
//  MakeMoney
//
#import "Filter_promet_webcam.h"
#import "JSON.h"
#import "URLPair.h"
#import "URLUtils.h"

@implementation Filter_promet_webcam

- (NSString*)pageParamName
{
	return @"page";
}

- (NSString*)limitParamName
{
	return @"limit";
}

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
	
	NSMutableArray* urls = [self extractFrom:information withPrefix:@"<img id=\"webcam" andSuffix:@"/>"];
	//DebugLog(@"EXTR %i", [urls count]);
	NSMutableString *transends = [NSMutableString stringWithString:@"["];
	NSUInteger i, count = [urls count];
	for (i = 0; i < count; i++) {
		NSString* u = [urls objectAtIndex:i];
		//DebugLog(@"filtering %@", u);
		NSArray* uc = [u componentsSeparatedByString:@"\""];
		if ([uc count] > 2) {
			NSString* link = [uc objectAtIndex:2];
			//DebugLog(@"LINK %@", link);
			[transends appendFormat:@"{\"ii\":\"message\", \"ions\":{\"refech\":\"true\", \"background_url\":\"%@\"}, %@},", [URLUtils encodeHTTP:link], k_ior_stop_space];		
		}
	}
	return [NSString stringWithFormat:@"%@]", [transends substringToIndex:transends.length-1]];
}
@end
