#define URLEXTRACTOR_PREFIX_HTTP @"http://"
#define URLEXTRACTOR_PREFIX_ID @"@"

@interface URLUtils : NSObject {

}
+ (id) utils;
- (NSMutableArray*) tokenizeByAll:(NSString*)aString;
- (NSMutableArray*) tokenizeByURL:(NSString*)aString;
- (NSMutableArray*) tokenizeByID:(NSString*)aString;
- (BOOL) isURLToken:(NSString*)token;
- (BOOL) isIDToken:(NSString*)token;
- (BOOL) isWhiteSpace:(NSString*)aString;

+ (NSString*) encodeHTTP:(NSString*)aString;
+ (NSString*) decodeHTTP:(NSString*)aString;

@end
