//
//  IIFilter.m
//  MakeMoney
//
#import "IIFilter.h"
#import "JSON.h"
#import "URLPair.h"
#import "URLUtils.h"
#import "ASIHTTPRequest.h"

#define kPikchurFormat @"http://pikchur.com/"
#define kTwitPicFormat @"http://twitpic.com/"

@implementation IIFilter
- (NSString*)filter:(NSString*)information withOptions:(NSDictionary*)options
{
	//override this
	return information; //default filter does not do anything
}

- (NSString*)pageParamName
{
	//override this if you have other param name for paging
	return @"page";
}

- (NSString*)limitParamName
{
	//override this if you have other param name for paging limit
	return @"limit";
}

//find all urls within a string, package into URLPairs array
- (NSMutableArray*)extractURLPairsFrom:(NSString*)information 
{
	URLUtils *utils = [URLUtils utils];
	NSMutableArray *urlpairs = [NSMutableArray arrayWithCapacity:1];
    NSMutableArray *tokens = [utils tokenizeByAll:information];
	int i;
    for (i = 0; i < [tokens count]; i++) {
        NSString *token = [tokens objectAtIndex:i];
        if ([utils isURLToken:token]) {
			URLPair *pair = [[URLPair alloc] init];
			pair.text = token;
			pair.url = token;
			[urlpairs addObject:pair];
			[pair release];
		} else if ([utils isIDToken:token]) {
			URLPair *pair = [[URLPair alloc] init];
			pair.name = [token substringFromIndex:1];
			pair.text = [NSString stringWithFormat:@"%@", pair.name];
			pair.url = [pair name]; //TODO insert supported something url... brings you directly to somebody, not.
			[urlpairs addObject:pair];
			[pair release];
        }
    }
	return urlpairs;
}

//this scans for something like image urls... very basic and simple, no xml parsing shit
//whatever you need and can be put beetwen prefix and suffix 
// example <img src="$$$"> -> pre => <img src=" suf => "
- (NSMutableArray*)extractFrom:(NSString*)information withPrefix:(NSString*)pre andSuffix:(NSString*)suf
{
	NSUInteger info_length = [information length];
	NSUInteger pre_length = [pre length];
	NSMutableArray *urls = [NSMutableArray arrayWithCapacity:1];
	NSScanner *scanner = [NSScanner scannerWithString:information];
	NSString *url;
	BOOL foundOne;
	while (![scanner isAtEnd]) {
		url = nil;
		foundOne = NO;
		[scanner scanUpToString:pre intoString:nil]; //move to next occurence of pre
		if ([scanner scanLocation] + pre_length < info_length)
		{
			[scanner setScanLocation:[scanner scanLocation]+[pre length]];//move to the end of prefix		
			foundOne = [scanner scanUpToString:suf intoString:&url]; //fech data up to next occurence of suf
			if (foundOne && url) {
				[urls addObject:url];
				//DebugLog(@"EXTRACTED %@", url);
			}
		}
	}
	return urls;
}

//$$$supported sharing experiences are returned magically, others are nil$$$
+ (NSString*)assetUrl:(NSString*)url 
{
	if ([IIFilter isPikchurUrl:url]) {
		return [IIFilter pikchurAssetUrlFrom:url withSize:@"l"];
	} else if ([IIFilter isTwitPicUrl:url]){
		return [IIFilter twitPicAssetUrlFrom:url withSize:@"full"];		
	} 
	return nil;
}

//pikchur
+ (BOOL)isPikchurUrl:(NSString*)url {
	return [url hasPrefix:kPikchurFormat];
}

+ (NSString*)pikchurAssetUrlFrom:(NSString*)pikchurUrl withSize:(NSString*)sizeStr {
	return [NSString stringWithFormat:@"https://s3.amazonaws.com/pikchurimages/pic_%@_%@.jpg", [pikchurUrl substringFromIndex:19], sizeStr];
}

//twitpic
+ (BOOL)isTwitPicUrl:(NSString*)url {
	return [url hasPrefix:kTwitPicFormat];
}

+ (NSString*)twitPicAssetUrlFrom:(NSString*)twitPicUrl withSize:(NSString*)sizeStr {
	//fech full image webpage - this is the place to find the real asset url
	ASIHTTPRequest* request = [[[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/full", twitPicUrl]]]autorelease];
	[request start];
	NSError *error = [request error];
	if (!error) {
		//extract urls from page
		URLUtils *utils = [URLUtils utils];
		NSArray *tokens = [utils tokenizeByAll:[request responseString]];
		int i;
		for (i = 0; i < [tokens count]; i++) {
			NSString *token = [tokens objectAtIndex:i];
			if ([utils isURLToken:token]) {
				//is token the image if it ends with "-#{size}.jpg"
				if ([token hasSuffix:[NSString stringWithFormat:@"-full.jpg"]]) {
					return [NSString stringWithFormat:@"%@%@.jpg", [token substringToIndex:[token length]-8], sizeStr];
				} else if ([token hasPrefix:@"http://s3.amazonaws.com/twitpic/"] ) {
					return token;
				}
			} 
		}
	} 
	return twitPicUrl; //return original, if code failed
}

@end
