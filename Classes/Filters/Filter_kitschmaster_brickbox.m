//
//  Filter_kitschmaster_brickbox.m
//  MakeMoney
//
#import "Filter_kitschmaster_brickbox.h"
#import "JSON.h"

@implementation Filter_kitschmaster_brickbox

- (NSString*)pageParamName
{
	return @"page";
}

- (NSString*)limitParamName
{
	return @"limit";
}

- (NSString*)filter:(NSString*)information withOptions:(NSDictionary*)options
{
	NSLog(@"FILTERING %@", information);
	NSArray* kiches = [information JSONValue];
	NSString* behavior = @"\"ior\":{\"stop\":\"false\"}";
	NSMutableString *transends = [NSMutableString stringWithString:@"["];
	NSUInteger i, count = [kiches count];
	for (i = 0; i < count; i++) {		
		NSDictionary* kich = [[kiches objectAtIndex:i] objectForKey:@"kich"];

		NSArray* assets = [kich objectForKey:@"assets"];
		NSUInteger i, count = [assets count];
		if (count>0) {
			//add a transend for every asset
			for (i = 0; i < count; i++) {
				NSDictionary * asset= [assets objectAtIndex:i];
				//[transends appendFormat:@"{\"name\":\"remote_image\", \"options\":{\"url\":\"%@\"}, %@},", [asset valueForKey:@"public_url"], behavior];
				[transends appendFormat:@"{\"ii\":\"MessageView\", \"ions\":{\"message\":\"title\", \"data\":%@, \"background_url\":\"%@\"}, %@},", [kich JSONFragment], [asset valueForKey:@"public_url"], behavior];
			}
		} else {
			//add a transend for kich that has no assets
			[transends appendFormat:@"{\"ii\":\"MessageView\", \"ions\":{\"message\":\"title\", \"data\":%@}, %@},", [kich JSONFragment], behavior];
		}
	}
	return [NSString stringWithFormat:@"%@]", [transends substringToIndex:transends.length-1]];
}

@end
