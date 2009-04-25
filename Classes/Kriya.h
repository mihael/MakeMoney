#define kBarHeightP 44.0
#define kBarHeightL 32.0
#define kPadding 3.0
#define kLightSpeed 0.8
#define kButtonSpeed 0.5
#define kButtonSize 57.0
#define kLeftRightButtonSize 38.0

#define SPOT @"kriya_spot"
#define RUNS @"kriya_runs"

@interface Kriya : NSObject {

}

+ (CGRect)appViewRect;

+ (NSInteger)appRunCount;
+ (void)incrementAppRunCount;

+ (void)prayInCode;

+ (NSString*)deviceId;

+ (NSString*)brickbox_url;
+ (NSString*)support_url;
+ (NSString*)kitsch_url;

+ (NSString*)howManyTimes:(int)i;

+ (NSDictionary*)stage;

+ (BOOL)xibExists:(NSString*)xibName;

//a disk in iphone is working at the speed of light
+ (void)writeWithPath:(NSString*)filepath data:(NSData*)data;
+ (NSData*)loadWithPath:(NSString*)filepath;
+ (UIImage*)imageWithUrl:(NSString*)url; //feches image from web, caches to disk

@end
