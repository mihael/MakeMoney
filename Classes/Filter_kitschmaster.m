//
//  Filter_kitschmaster.m
//  MakeMoney
//
#import "Filter_kitschmaster.h"
#import "JSON.h"

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
	NSLog(@"FILTERING %@", information);
	NSArray* kiches = [information JSONValue];
	NSString* behavior = @"\"behavior\":{\"stop\":\"false\"}";
	NSMutableString *transends = [NSMutableString stringWithString:@"["];
	NSUInteger i, count = [kiches count];
	for (i = 0; i < count; i++) {
		NSDictionary* kich = [[kiches objectAtIndex:i] objectForKey:@"kich"];
		NSArray* assets = [kich objectForKey:@"assets"];
		NSUInteger i, count = [assets count];
		for (i = 0; i < count; i++) {
			NSDictionary * asset= [assets objectAtIndex:i];
			[transends appendFormat:@"{\"name\":\"remote_image\", \"options\":{\"url\":\"%@\"}, %@},", [asset valueForKey:@"public_url"], behavior];
		}
	}
	return [NSString stringWithFormat:@"%@]", [transends substringToIndex:transends.length-1]];
}

@end
