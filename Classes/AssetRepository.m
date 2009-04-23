//
//  AssetRepository.m
//  MakeMoney
//
#import <CommonCrypto/CommonDigest.h>
#import "AssetRepository.h"
#import "ASIHTTPRequest.h"

static AssetRepository *_one = nil;

@implementation Asset
@synthesize image, delegate;

+ (NSString*)md5:(NSString*) str {
	const char *cStr = [str UTF8String];
	unsigned char result[CC_MD5_DIGEST_LENGTH];
	CC_MD5( cStr, strlen(cStr), result );
	return [NSString stringWithFormat: 
			@"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
			result[0], result[1],
			result[2], result[3],
			result[4], result[5],
			result[6], result[7],
			result[8], result[9],
			result[10], result[11],
			result[12], result[13],
			result[14], result[15]];
}

- (id)init {
	self = [super init];
	//delegates = [[[NSMutableArray alloc] init] retain];
	return self;
}

+ (NSString*)cacheFilenameForURL:(NSString*)url {
	return [[AssetRepository one].assetCacheRootPath stringByAppendingString:[Asset md5:url]];
}

+ (void)writeAsCacheFileForURL:(NSString*)url data:(NSData*)data {
	[AssetRepository saveWithFilename:[Asset cacheFilenameForURL:url] data:data];
}

+ (NSData*)readFromCacheFileForURL:(NSString*)url {
	return [AssetRepository loadWithFilename:[Asset cacheFilenameForURL:url]];
}

- (void)dealloc {
	[image release];
	//[delegates release];
	[url release];
	[super dealloc];
}

- (BOOL)fromURL:(NSString*)aUrl notify:(id)d {
	//[delegates addObject:delegate];
	[self setDelegate:d];
	NSData *cached = [Asset readFromCacheFileForURL:aUrl];
	if (cached) {
		[image release];
		image = [[[UIImage alloc] initWithData:cached] retain];
		return YES;
	} else {
		if (!downloading) {
			downloading = YES;
			[url release];
			url = aUrl;
			[url retain];

			ASIHTTPRequest *request = [[[ASIHTTPRequest alloc] initWithURL:[NSURL URLWithString:url]] autorelease];
			[request setRequestMethod:@"GET"];
			[request setDidFinishSelector:@selector(downloadSucceeded:)];
			[request setDidFailSelector:@selector(downloadFailed:)];
			[request setDelegate:self];
			[request start];
		}
	}
	return FALSE;
}

- (void)downloadSucceeded:(ASIHTTPRequest*)request {
	[image release];
	image = [[[UIImage alloc] initWithData:request.responseData] retain];
	[Asset writeAsCacheFileForURL:url data:request.responseData];
	[url release];
	url = nil;
	downloading = NO;
//	for (id d in delegates) {
		[self.delegate downloaded:self];
//	}
	//[delegates removeAllObjects];
}

- (void)downloadFailed:(ASIHTTPRequest*)request {
	[url release];
	url = nil;
	downloading = NO;
	//for (id d in delegates) {
		[self.delegate notDownloaded:self];
	//}
	//[delegates removeAllObjects];
}

@end

@implementation AssetRepository
@synthesize assetCacheRootPath;

+ (AssetRepository*) one {
    @synchronized (self) {
        if (!_one) {
            _one = [[self alloc] init];
        }
    }
    return _one;
}

- (id)init {
	self = [super init];
	urlToAsset = [[NSMutableDictionary alloc] initWithCapacity:100];
	assetCacheRootPath = [AssetRepository createImageCacheDirectory];
	[assetCacheRootPath retain];
	return self;
}

- (void) dealloc {
	[urlToAsset release];
	[assetCacheRootPath release];
	[super dealloc];
}

- (UIImage*)imageForURL:(NSString*)url withParams:(NSString*)params notify:(id)delegate 
{
	Asset *asset = [urlToAsset objectForKey:url];
	if (!asset) {
		asset = [[Asset alloc] init];
		[urlToAsset setObject:asset forKey:url];
		[asset release];
	}
	if (asset.image || [asset fromURL:url notify:delegate]) {
		return asset.image;
	}
	return nil;	
}

- (UIImage*)imageForURL:(NSString*)url notify:(id)delegate {
	Asset *asset = [urlToAsset objectForKey:url];
	if (!asset) {
		asset = [[Asset alloc] init];
		[urlToAsset setObject:asset forKey:url];
		[asset release];
	}
	DebugLog(@"AssetRepository#imageForURL urlToAsset size: %i", [urlToAsset count]);

	if (asset.image || [asset fromURL:url notify:delegate]) {
		return asset.image;
	}
	return nil;
}

- (Asset*)assetForURL:(NSString*)url notify:(id)delegate {
	Asset *asset = [urlToAsset objectForKey:url];
	if (!asset) {
		asset = [[Asset alloc] init];
		[urlToAsset setObject:asset forKey:url];
		[asset release];
	}
	if (asset.image || [asset fromURL:url notify:delegate]) {
		return asset;
	}
	return nil;
}

+ (NSString*)createCacheDirectoryWithName:(NSString*)name {
	NSString *path = [NSHomeDirectory() stringByAppendingString:@"/tmp"];
	[[NSFileManager defaultManager] createDirectoryAtPath:path attributes:nil];
	path = [NSString stringWithFormat:@"%@/%@", path, name];
	[[NSFileManager defaultManager] createDirectoryAtPath:path attributes:nil];
	return [path stringByAppendingString:@"/"];
}

+ (NSString*)createImageCacheDirectory {
	return [self createCacheDirectoryWithName:@"image_cache"];
}

+ (NSString*)createJSONCacheDirectory {
	return [self createCacheDirectoryWithName:@"json_cache"];
}

+ (NSString*)createTextCacheDirectory {
	return [self createCacheDirectoryWithName:@"text_cache"];
}

+ (void)saveWithFilename:(NSString*)filename data:(NSData*)data {
	[[NSFileManager defaultManager] createFileAtPath:filename contents:data attributes:nil];
	DebugLog(@"AssetRepository# wrote: %@", filename);
}

+ (NSData*)loadWithFilename:(NSString*)filename {
	NSFileHandle *fh = [NSFileHandle fileHandleForReadingAtPath:filename];
	NSData *ret = nil;
	if (fh) {
		ret = [fh readDataToEndOfFile];
		[fh closeFile];
		//[ret retain];
		//[fh release];
	}
	DebugLog(@"AssetRepository# loaded: %@", [ret description]);
	return ret;
}

+ (void)removeAllCachedData {
	[[NSFileManager defaultManager] removeItemAtPath:[AssetRepository createImageCacheDirectory] error:nil];
	[[NSFileManager defaultManager] removeItemAtPath:[AssetRepository createJSONCacheDirectory] error:nil];
	[[NSFileManager defaultManager] removeItemAtPath:[AssetRepository createTextCacheDirectory] error:nil];
}
@end
