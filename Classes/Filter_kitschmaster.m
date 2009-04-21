//
//  Filter_kitschmaster.m
//  MakeMoney
//
#import "Filter_kitschmaster.h"

@implementation Filter_kitschmaster

- (NSString*)pageParamName
{
	return @"page";
}

- (NSString*)limitParamName
{
	return @"limit";
}

- (NSString*)filter:(NSString*)information
{
	NSDictionary* kich = [[information JSONValue] objectForKey:@"kich"];
	NSArray* assets = [kich objectForKey:@"assets"];
	
	NSString* behavior = @"\"behavior\":{\"stop\":\"false\"}";
	NSMutableString *transends = [NSMutableString stringWithString:@"["];
	
	NSUInteger i, count = [assets count];
	for (i = 0; i < count; i++) {
		NSDictionary * asset= [assets objectAtIndex:i];
		[transends appendFormat:@"{\"name\":\"RemoteImageView\", \"options\":{\"url\":\"%@\"}, %@},", [asset valueForKey:@"public_url"], behavior];
	}
	return [NSString stringWithFormat:@"%@]", [transends substringToIndex:transends.length-1]];
}

@end
