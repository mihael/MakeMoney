//
//  IIFilter.h
//  MakeMoney
//

//supported image url formats
#define kPikchurFormat @"http://pikchur.com/"
#define kPikchurFormatShort @"http://pk.gd/"
#define kPikchurFormatFinal @"http://img.pikchur.com/"
#define kTwitPicFormat @"http://twitpic.com/"
#define kTwitPicFormatFinal @"http://s3.amazonaws.com/twitpic/"


//usable Behaviors, for when writing IIFilter subclasses
#define k_ior_stop @"\"ior\":{\"stop\":\"true\"}"
#define k_ior_notstop @"\"ior\":{\"stop\":\"false\"}"
#define k_ior_stop_space @"\"ior\":{\"stop\":\"true\", \"space\":\"true\"}"
#define k_ior_notstop_space @"\"ior\":{\"stop\":\"false\", \"space\":\"true\"}"
#define k_ior_stop_notspace @"\"ior\":{\"stop\":\"true\", \"space\":\"false\"}"
#define k_ior_notstop_notspace @"\"ior\":{\"stop\":\"false\", \"space\":\"false\"}"

//this class should be overriden if you want to filter IIWWW feches auto-magically
@interface IIFilter : NSObject {
}
- (id)prepareRequestFor:(NSDictionary*)options;
- (NSArray*)prepareRequestsFor:(NSDictionary*)options;
- (NSString*)filter:(NSString*)information withOptions:(NSDictionary*)options;
- (NSString*)pageParamName;
- (NSString*)limitParamName;

//simple URL extraction
+ (NSMutableArray*)extractURLPairsFrom:(NSString*)information;

//simple information extraction beetween prefix and suffix
+ (NSMutableArray*)extractFrom:(NSString*)information withPrefix:(NSString*)pre andSuffix:(NSString*)suf;

//supported assets and userid links
+ (NSString*)assetUrl:(NSString*)url;

//pikchur
+ (BOOL)isPikchurUrl:(NSString*)url;
+ (NSString*)pikchurAssetUrlFrom:(NSString*)pikchurUrl withSize:(NSString*)sizeStr;
//twitpic
+ (BOOL)isTwitPicUrl:(NSString*)url;
+ (NSString*)twitPicAssetUrlFrom:(NSString*)twitPicUrl withSize:(NSString*)sizeStr;
//checks for all supported 
+ (BOOL)isImageUrl:(NSString*)url;

//audio stream
+ (BOOL)isStreamUrl:(NSString*)url;
+ (NSString*)streamAssetUrlFrom:(NSString*)url;
//twitter style @userid	
+ (BOOL)isUserId:(NSString*)user_id;
//yutub
+ (BOOL)isYutubUrl:(NSString*)url;
+ (NSString*)yutubAssetUrlFrom:(NSString*)url;

//decoders
+ (NSString*)decode_bit_ly:(NSString*)encodedUrl;

@end
