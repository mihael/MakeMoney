//
//  IIFilter.m
//  MakeMoney
//
#import "IIFilter.h"
#import "JSON.h"
#import "URLPair.h"
#import "URLUtils.h"
#import "ASIHTTPRequest.h"

@implementation IIFilter

- (id)prepareRequestFor:(NSDictionary*)options 
{
	//override this if you want to prepare requests from within filter code
	return nil;
}

- (NSArray*)prepareRequestsFor:(NSDictionary*)options
{
	//override this if you want to prepare requests from within filter code
	return nil;
}

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
+ (NSMutableArray*)extractURLPairsFrom:(NSString*)information 
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
// example 
// <img src="$$$"> 
// pre => <img src=" 
// suf => "
+ (NSMutableArray*)extractFrom:(NSString*)information withPrefix:(NSString*)pre andSuffix:(NSString*)suf
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
//shorters
+ (NSString*)redirectedUrlMaybe:(NSString*)r 
{
	if ([r hasPrefix:@"http://bit.ly/"]) {
		return [self decode_bit_ly:r];
	} 
	return nil;
}

//$$$supported sharing experiences are returned magically, others are nil$$$
+ (NSString*)assetUrl:(NSString*)url 
{
	NSString * size = [[NSUserDefaults standardUserDefaults] valueForKey:@"pikchur_download_size"];
	if (!size) 
		size = @"l";
	
	NSString *urlMagic = [IIFilter redirectedUrlMaybe:url];
	
	if (!urlMagic) {
		urlMagic = url;
	}
	
	if ([IIFilter isPikchurUrl:urlMagic]) {
		return [IIFilter pikchurAssetUrlFrom:urlMagic withSize:size];
	} else if ([IIFilter isTwitPicUrl:urlMagic]) {
		return [IIFilter twitPicAssetUrlFrom:urlMagic withSize:@"full"];		
	} else if ([IIFilter isStreamUrl:urlMagic]) {
		return [IIFilter streamAssetUrlFrom:urlMagic];
	} else if ([IIFilter isYutubUrl:urlMagic]) {
		return [IIFilter yutubAssetUrlFrom:urlMagic];
	}
	return nil;
}

//is it pikchur or twitpic
+ (BOOL)isImageUrl:(NSString*)url {
	return ([IIFilter isPikchurUrl:url]||[IIFilter isTwitPicUrl:url]);
}

//pikchur
+ (BOOL)isPikchurUrl:(NSString*)url {
	return [url hasPrefix:kPikchurFormat]||[url hasPrefix:kPikchurFormatFinal];
}

+ (NSString*)pikchurAssetUrlFrom:(NSString*)pikchurUrl withSize:(NSString*)sizeStr {
	return [NSString stringWithFormat:@"%@pic_%@_%@.jpg", kPikchurFormatFinal, [pikchurUrl substringFromIndex:19], sizeStr];
}

//twitpic
+ (BOOL)isTwitPicUrl:(NSString*)url {
	return [url hasPrefix:kTwitPicFormat]||[url hasPrefix:kTwitPicFormatFinal];
}

+ (NSString*)twitPicAssetUrlFrom:(NSString*)twitPicUrl withSize:(NSString*)sizeStr {
	if ([twitPicUrl hasPrefix:kTwitPicFormat]) {
		//fech full image webpage - this is the place to find the real asset url
		ASIHTTPRequest* request = [[[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/full", twitPicUrl]]]autorelease];
		[request start];
		NSError *error = [request error];
		if (!error) {
			NSMutableArray *urls = [IIFilter extractFrom:[request responseString] withPrefix:@"<img class=\"photo-large\" src=\"" andSuffix:@"\""];
			if ([urls count]==1) {
				return [urls objectAtIndex:0];
			}
			/*
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
			 */
		} 
	}
	return twitPicUrl; //return original, if code failed
}

//userid
+ (BOOL)isUserId:(NSString*)userid
{
	return [userid hasPrefix:@"@"];
}

//audio streams
+ (BOOL)isStreamUrl:(NSString*)url {
	NSString *fileExtension = [url pathExtension];
	if ([fileExtension isEqual:@"mp3"])
	{
		return YES;
	}
	else if ([fileExtension isEqual:@"wav"])
	{
		return YES;
	}
	else if ([fileExtension isEqual:@"aifc"])
	{
		return YES;
	}
	else if ([fileExtension isEqual:@"aiff"])
	{
		return YES;
	}
	else if ([fileExtension isEqual:@"m4a"])
	{
		return YES;
	}
	else if ([fileExtension isEqual:@"mp4"])
	{
		return YES;
	}
	else if ([fileExtension isEqual:@"caf"])
	{
		return YES;
	}
	else if ([fileExtension isEqual:@"aac"])
	{
		return YES;
	}
	return NO;
}

+ (NSString*)streamAssetUrlFrom:(NSString*)url 
{
	return url;
}

//yutub
+ (BOOL)isYutubUrl:(NSString*)url 
{
	return [url hasPrefix:@"http://www.youtube.com/watch?v="];
}

+ (NSString*)yutubAssetUrlFrom:(NSString*)url 
{
	return url;
}

//stupid little redirectors, because stupid little web is based on stupid little 140 chars
+ (NSString*)decode_bit_ly:(NSString*)encodedUrl
{
	ASIHTTPRequest* request = [[[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:encodedUrl]]autorelease];
	[request start];
	NSError *error = [request error];
	if (!error) {
		NSMutableArray *urls = [IIFilter extractURLPairsFrom:[request responseString]];
		if ([urls count]>0)
			return [[urls objectAtIndex:0] url];
	} 	
	return encodedUrl;
}
@end
