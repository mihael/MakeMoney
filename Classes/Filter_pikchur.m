//
//  Filter_pikchur.m
//  MakeMoney
//
#import "Filter_pikchur.h"
#import "JSON.h"

@implementation Filter_pikchur

- (NSString*)pageParamName
{
	return @"data[api][feeds][timeline][page]";
}

- (NSString*)limitParamName
{
	return @"data[api][feeds][timeline][limit]";
}

- (NSString*)filter:(NSString*)information withOptions:(NSDictionary*)options
{
	NSArray* piks = [[information JSONValue] objectForKey:@"Piks"];
	
	NSString* behavior = k_ior_notstop_space;
	NSMutableString *transends = [NSMutableString stringWithString:@"["];
	
	NSUInteger i, count = [piks count];
	for (i = 0; i < count; i++) {
		NSDictionary * pik= [piks objectAtIndex:i];
		
		[transends appendFormat:@"{\"ii\":\"message\", \"ions\":{\"background_url\":\"%@\"}, %@},", [self pikchurUrlFromID:[[pik valueForKey:@"Pik"] valueForKey:@"id"]  withSize:@"m"], behavior];
	}
	return [NSString stringWithFormat:@"%@]", [transends substringToIndex:transends.length-1]];
}

- (NSString*)pikchurUrlFromID:(NSString*)pikID withSize:(NSString*)sizeStr {
	return [NSString stringWithFormat:@"%@pic_%@_%@.jpg", kPikchurFormatFinal,pikID, sizeStr];
}

@end
