//
//  IIFilter.h
//  MakeMoney
//
//some usables, when writing a filter
#define k_ior_stop @"\"ior\":{\"stop\":\"true\"}"
#define k_ior_notstop @"\"ior\":{\"stop\":\"false\"}"

//this class should be overriden if you want to filter IWWW feches
@interface IIFilter : NSObject {
}
- (id)requestWith:(NSDictionary*)options;
- (NSString*)filter:(NSString*)information;
- (NSString*)pageParamName;
- (NSString*)limitParamName;
- (NSMutableArray*)extractURLPairsFrom:(NSString*)information;

//supported assets and userid links
+ (NSString*)assetUrl:(NSString*)url;
//pikchur
+ (BOOL)isPikchurUrl:(NSString*)url;
+ (NSString*)pikchurAssetUrlFrom:(NSString*)pikchurUrl withSize:(NSString*)sizeStr;
//twitpic
+ (BOOL)isTwitPicUrl:(NSString*)url;
+ (NSString*)twitPicAssetUrlFrom:(NSString*)twitPicUrl withSize:(NSString*)sizeStr;
	
+ (BOOL)isUserId:(NSString*)user_id;

@end
