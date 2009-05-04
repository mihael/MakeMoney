//
//  Filter_hai_galery.m
//  MakeMoney
//
#import "Filter_hai_galery.h"
#import "JSON.h"
#import "URLPair.h"

@implementation Filter_hai_galery

- (NSString*)pageParamName
{
	return @"g2_page";
}

- (NSString*)limitParamName
{
	return @"limit";
}

- (NSString*)filter:(NSString*)information
{
	//NSLog(@"FILTERING HAI %@", information);
	NSMutableArray* urls = [self extractFrom:information withPrefix:@"<img src=\"gallery2/main.php?g2_view=core.DownloadItem" andSuffix:@"\""];
	NSMutableString *transends = [NSMutableString stringWithString:@"["];
	NSUInteger i, count = [urls count];
	for (i = 0; i < count; i++) {
		NSString* link = [urls objectAtIndex:i];
		[transends appendFormat:@"{\"ii\":\"message\", \"ions\":{\"background_url\":\"http://hireanillustrator.com/v2/gallery2/main.php?g2_view=core.DownloadItem%@\"}, %@},", [link stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"], k_ior_notstop];
	}
	return [NSString stringWithFormat:@"%@]", [transends substringToIndex:transends.length-1]];
}
@end
