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
		NSUInteger j, c = [assets count];
		if (c>0) {
			//first asset is background for this kich
			[transends appendFormat:@"{\"ii\":\"MessageView\", \"ions\":{\"message\":\"title\", \"data\":%@, \"background_url\":\"%@\"}, %@},", [kich JSONFragment], [[assets objectAtIndex:0] valueForKey:@"public_url"], behavior];

			if (c>1) {
				//other assets are shown
				for (j = 1; j < c; j++) {
					NSDictionary * asset= [assets objectAtIndex:j];
					//[transends appendFormat:@"{\"name\":\"remote_image\", \"options\":{\"url\":\"%@\"}, %@},", [asset valueForKey:@"public_url"], behavior];
					[transends appendFormat:@"{\"ii\":\"MessageView\", \"ions\":{\"message\":\"title\", \"data\":%@, \"background_url\":\"%@\"}, %@},", [kich JSONFragment], [asset valueForKey:@"public_url"], behavior];
				}
			}
			
		} else {
			//no assets for this kich
			[transends appendFormat:@"{\"ii\":\"MessageView\", \"ions\":{\"message\":\"title\", \"data\":%@}, %@},", [kich JSONFragment], behavior];
		}

	}
	//DebugLog(@"TRANSENDS FILTERED: %@", transends);
	return [NSString stringWithFormat:@"%@]", [transends substringToIndex:transends.length-1]];
}

@end
