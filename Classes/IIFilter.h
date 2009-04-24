//
//  IIFilter.h
//  MakeMoney
//
//this class should be overriden if you want to filter IWWW feches
@interface IIFilter : NSObject {
}
- (NSString*)filter:(NSString*)information;
- (NSString*)pageParamName;
- (NSString*)limitParamName;
- (NSMutableArray*)extractURLPairsFrom:(NSString*)information;

//supported assets 
+ (NSString*)assetUrl:(NSString*)url;
//pikchur
+ (BOOL)isPikchurUrl:(NSString*)url;
+ (NSString*)pikchurAssetUrlFrom:(NSString*)pikchurUrl withSize:(NSString*)sizeStr;
//twitpic
+ (BOOL)isTwitPicUrl:(NSString*)url;
+ (NSString*)twitPicAssetUrlFrom:(NSString*)twitPicUrl withSize:(NSString*)sizeStr;
	
@end
