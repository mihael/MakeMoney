//
//  Filter_pikchur.m
//  MakeMoney
//
#import "Filter_pikchur.h"
#import "CJSONDeserializer.h"

@implementation Filter_pikchur

- (NSString*)pageParamName
{
	return @"data[api][feeds][page]";
}

- (NSString*)limitParamName
{
	return @"data[api][feeds][limit]";
}

- (NSString*)filter:(NSString*)information withOptions:(NSDictionary*)options
{

	NSError *error = nil;
	NSDictionary *informationDictionary = [[CJSONDeserializer deserializer] deserializeAsDictionary:[information dataUsingEncoding:NSUTF8StringEncoding] error:&error];

	if (error!=nil)
		DebugLog(@"ERROR: %@", [error localizedDescription]);
	
	NSArray* piks = [informationDictionary objectForKey:@"feed"];
	
	NSString* behavior = k_ior_notstop_space;
//	NSString* behavior = @"\"ior\":{\"stop\":\"false\", \"space\":\"true\", \"content_mode\":\"fit\"}";
	NSMutableString *transends = [NSMutableString stringWithString:@"["];
	
	NSUInteger i, count = [piks count];
	for (i = 0; i < count; i++) {
		NSDictionary * pik= [piks objectAtIndex:i];
		
		[transends appendFormat:@"{\"ii\":\"message\", \"ions\":{\"background_url\":\"%@\"}, %@},", [self pikchurUrlFromID:[[pik valueForKey:@"media"] valueForKey:@"short_code"]  withSize:@"m"], behavior];
	}
	return [NSString stringWithFormat:@"%@]", [transends substringToIndex:transends.length-1]];
}

- (NSString*)pikchurUrlFromID:(NSString*)pikID withSize:(NSString*)sizeStr {
	return [NSString stringWithFormat:@"%@pic_%@_%@.jpg", kPikchurFormatFinal,pikID, sizeStr];
}

@end
