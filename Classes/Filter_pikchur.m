//
//  Filter_pikchur.m
//  MakeMoney
//
#import "Filter_pikchur.h"

@implementation Filter_pikchur

- (NSString*)pageParamName
{
	return @"data[api][feeds][timeline][page]";
}

- (NSString*)limitParamName
{
	return @"data[api][feeds][timeline][limit]";
}

- (NSString*)filter:(NSString*)information
{
	NSArray* piks = [[information JSONValue] objectForKey:@"Piks"];
	
	NSString* behavior = @"\"behavior\":{\"stop\":\"false\"}";
	NSMutableString *transends = [NSMutableString stringWithString:@"["];
	
	NSUInteger i, count = [piks count];
	for (i = 0; i < count; i++) {
		NSDictionary * pik= [piks objectAtIndex:i];
		
		[transends appendFormat:@"{\"name\":\"remote_image\", \"options\":{\"url\":\"%@\"}, %@},", [self pikchurUrlFromID:[[pik valueForKey:@"Pik"] valueForKey:@"id"]  withSize:@"l"], behavior];
	}
	return [NSString stringWithFormat:@"%@]", [transends substringToIndex:transends.length-1]];
}

- (NSString*)pikchurUrlFromID:(NSString*)pikID withSize:(NSString*)sizeStr {
	return [NSString stringWithFormat:@"https://s3.amazonaws.com/pikchurimages/pic_%@_%@.jpg", pikID, sizeStr];
}

@end
