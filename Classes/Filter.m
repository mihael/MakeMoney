//
//  Filter.m
//  MakeMoney
//

#import "Filter.h"
#import "JSON.h"

@implementation Filter
+ (NSString*)kitschmaster:(id)kiches_json 
{
	NSDictionary* kich = [[kiches_json JSONValue] objectForKey:@"kich"];
	NSArray* assets = [kich objectForKey:@"assets"];

	NSString* behavior = @"\"behavior\":{\"stop\":\"false\"}";
	NSMutableString *transends = [NSMutableString stringWithString:@"["];

	NSUInteger i, count = [assets count];
	for (i = 0; i < count; i++) {
		NSDictionary * asset= [assets objectAtIndex:i];
		[transends appendFormat:@"{\"name\":\"RemoteImageView\", \"options\":{\"url\":\"%@\"}, %@},", [asset valueForKey:@"public_url"], behavior];
	}
	NSString* fechSome = [NSMutableString stringWithString:@"{\"name\":\"FechSomeView\", \"options\":{\"url\":\"http://kitschmaster.com/kiches/144.json\", \"filter\":\"kitschmaster\"}, \"behavior\":{\"stop\":\"true\"}},"];	
	[transends appendFormat:@"%@", fechSome];
	return [NSString stringWithFormat:@"%@]", [transends substringToIndex:transends.length-1]];
}

+ (NSString*)koornk:(id)koornk_json
{
	return koornk_json;
}
+ (NSString*)pikchur:(id)pikchur_json
{
	NSLog(@"pikchur_json: %@", pikchur_json);
	NSArray* piks = [[pikchur_json JSONValue] objectForKey:@"Piks"];
	
	NSString* behavior = @"\"behavior\":{\"stop\":\"false\"}";
	NSMutableString *transends = [NSMutableString stringWithString:@"["];
	
	NSUInteger i, count = [piks count];
	for (i = 0; i < count; i++) {
		NSDictionary * pik= [piks objectAtIndex:i];
		
		[transends appendFormat:@"{\"name\":\"RemoteImageView\", \"options\":{\"url\":\"%@\"}, %@},", [Filter pikchurUrlFromID:[[pik valueForKey:@"Pik"] valueForKey:@"id"]  withSize:@"l"], behavior];
	}
	return [NSString stringWithFormat:@"%@]", [transends substringToIndex:transends.length-1]];
}
+ (NSString*)filter_twitter:(id)twitter_json
{
	return twitter_json;
}


- (NSString*)pikchur_getPublicTimelineWithPage:(int)page andSize:(int)pageSize {
	
	NSString *body = [NSString stringWithFormat:@"data[api][feeds][type]=timeline&data[api][key]=%@", kAPI_pikchur_api_key]; 
	NSString *url = @"https://api.pikchur.com/api/feeds/json"; 
	if (page<=0) {
		page = 1;
	}
	if (pageSize == 0) {
		pageSize = 5;
	}
	body = [NSString stringWithFormat:@"%@&data[api][feeds][timeline][page]=%d", body, page]; //page param
	if (pageSize < 50 && pageSize > 0) { //API 25 is default
		body = [NSString stringWithFormat:@"%@&data[api][feeds][timeline][limit]=%d", body, pageSize]; //add page parameter if page is not default and more than 0
	}	
	return [NSString stringWithFormat:@"%@%@", url, body];
}

+ (NSString*)pikchurUrlFromID:(NSString*)pikID withSize:(NSString*)sizeStr {
	return [NSString stringWithFormat:@"https://s3.amazonaws.com/pikchurimages/pic_%@_%@.jpg", pikID, sizeStr];
}

@end
