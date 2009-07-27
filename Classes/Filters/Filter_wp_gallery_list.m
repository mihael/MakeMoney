//
//  Filter_wp_gallery_list.m
//  MakeMoney
//
#import "Filter_wp_gallery_list.h"
#import "JSON.h"
#import "URLPair.h"
#import "URLUtils.h"

@implementation Filter_wp_gallery_list

- (NSString*)pageParamName
{
	return @"g2_page";
}

- (NSString*)filter:(NSString*)information withOptions:(NSDictionary*)options
{
	//DebugLog(@"FILTERING WP_GALLERY_LIST %@", information);
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
		
		NSString *v_url = nil;
		NSString *d_url = nil;
		NSString *url_title = nil;
		NSArray *pars = [[urls objectAtIndex:i] componentsSeparatedByString:@"\""];
		//extract relevant relative links
		BOOL getInfoFromNextPar = NO;

		for (NSString *par in pars) {
			if (getInfoFromNextPar) {
				if (par) 
					url_title = par;			
				getInfoFromNextPar = NO;
			} else {
				if ([par hasPrefix:@"v/"])
					v_url = par;
				if ([par hasPrefix:@"d/"])
					d_url = par;
				if ([par hasPrefix:@" alt"]) 
					getInfoFromNextPar = YES;				
			}
		}
		
		if (v_url)
			[transends appendFormat:@"{\"ii\":\"FecherView\", \"ions\":{\"reuse\":\"true\", \"message\":\"%@\", \"url\":\"%@/%@\", \"page\":1, \"fech_all\":\"true\", \"filter\":\"wp_gallery\", \"filter_base_url\":\"%@\", \"background_url\":\"%@/%@\"}, %@},", [URLUtils decodeHTTP:url_title], base_url, v_url, base_url, base_url, d_url, k_ior_stop_space];
			//[transends appendFormat:@"{\"ii\":\"FecherView\", \"ions\":{\"reuse\":\"true\", \"restore_key\":\"restore_key_%@\", \"message\":\"%@\", \"url\":\"%@/%@\", \"page\":1, \"fech_all\":\"true\", \"filter\":\"wp_gallery\", \"filter_base_url\":\"%@\", \"background_url\":\"%@/%@\"}, %@},", v_url, [URLUtils decodeHTTP:url_title], base_url, v_url, base_url, base_url, d_url, k_ior_stop_space];
	}
	return [NSString stringWithFormat:@"%@]", [transends substringToIndex:transends.length-1]];
}
@end
