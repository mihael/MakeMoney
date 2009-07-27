#import "URLPair.h"
@implementation URLPair
@synthesize url, text, name;

- (void)dealloc {
	[url release];
	[text release];
	[name release];
	[super dealloc];
}
@end