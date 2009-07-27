//
//  AssetRepository.h
//  MakeMoney
//
#import <Foundation/Foundation.h>
#import "ASIHTTPRequest.h"
@class Asset;

@protocol AssetDownloadDelegate
- (void)downloaded:(id)a;
- (void)notDownloaded:(id)a;
@end

@interface Asset : NSObject 
{
	UIImage *image;
	NSMutableArray *delegates;
	id <AssetDownloadDelegate> delegate;
	NSString *url;
	BOOL downloading;
}
@property (readonly) UIImage *image;
@property (readwrite, retain) id <AssetDownloadDelegate> delegate;

- (BOOL)fromURL:(NSString*)url notify:(id)d;
- (void)downloadSucceeded:(ASIHTTPRequest*)request;
- (void)downloadFailed:(ASIHTTPRequest*)request;
	
@end

@interface AssetRepository : NSObject {
    NSMutableDictionary *urlToAsset;
	NSString *assetCacheRootPath;
}
@property (readonly) NSString *assetCacheRootPath;
+ (AssetRepository*)one;
- (UIImage*)imageForURL:(NSString*)url withParams:(NSString*)params notify:(id)delegate;
- (UIImage*)imageForURL:(NSString*)url notify:(id)delegate;
- (Asset*)assetForURL:(NSString*)url notify:(id)delegate;

+ (NSString*)createCacheDirectoryWithName:(NSString*)name;
+ (NSString*)createImageCacheDirectory;
+ (NSString*)createJSONCacheDirectory;
+ (NSString*)createTextCacheDirectory;
+ (void)saveWithFilename:(NSString*)filename data:(NSData*)data;
+ (NSData*)loadWithFilename:(NSString*)filename;
+ (void)removeAllCachedData;

@end
