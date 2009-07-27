@interface URLPair : NSObject
{
	NSString *url;
	NSString *text;
	NSString *name;
}

@property(readwrite, retain) NSString *url, *text, *name;

@end