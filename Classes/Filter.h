//
//  Filter.h
//  MakeMoney
//
#import <Foundation/Foundation.h>
#define kAPI_pikchur_api_key @"plusOOts6YVcBSFGgT0jaA"

@interface Filter : NSObject {

}

+ (NSString*)kitschmaster:(id)kiches_json;

+ (NSString*)koornk:(id)koornk_json;

+ (NSString*)pikchur:(id)pikchur_json;
+ (NSString*)pikchurUrlFromID:(NSString*)pikID withSize:(NSString*)sizeStr;

+ (NSString*)filter_twitter:(id)twitter_json;
@end
