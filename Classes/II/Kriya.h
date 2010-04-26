#define kBarHeightP 44.0
#define kBarHeightL 32.0
#define kPadding 3.0
#define kLightSpeed 0.8
#define kButtonSpeed 0.5
#define kBigButtonSize 57.0
#define kButtonSize 38.0
#define kLeftRightButtonSize 38.0

#define SPOT @"kriya_spot"
#define RUNS @"kriya_runs"
#define STARTUPS @"kriya_worldwide_application_startups"

//get app frame
CGRect KriyaFrame();

@protocol KriyaDelegate <NSObject>
- (void)imageWithUrlFinished:(id)response;
- (void)imageWithUrlFailed:(id)response;
- (void)iconWithUrlFinished:(id)response;
- (void)iconWithUrlFailed:(id)response; 
@end

@interface Kriya : NSObject {

}

+ (CGRect)orientedFrame;

+ (NSInteger)appRunCount;
+ (void)incrementAppRunCount;

+ (void)prayInCode;

+ (NSString*)deviceId;

+ (NSString*)app_title;
+ (NSString*)app_id;
+ (NSString*)server_url;
+ (NSString*)apn_register_url;
+ (NSString*)startup_url;
+ (NSString*)support_url;
+ (NSString*)welcome_url;

+ (NSString*)howManyTimes:(int)i;

+ (NSDictionary*)stage;

+ (BOOL)xibExists:(NSString*)xibName;

//a disk in iphone is working at the speed of light
+ (void)writeWithPath:(NSString*)filepath data:(NSData*)data;
+ (NSData*)loadWithPath:(NSString*)filepath;

+ (NSString*)imageWithInMemoryImage:(UIImage*)image;
+ (NSString*)imageWithInMemoryImage:(UIImage*)image forUrl:(NSString*)url;
+ (UIImage*)imageWithUrl:(NSString*)url feches:(BOOL)fechFromWeb;  //feches image from web, caches to disk
+ (void)imageWithUrl:(NSString*)url delegate:(id)delegate finished:(SEL)finishSelector failed:(SEL)failSelector;
+ (UIImage*)imageWithPath:(NSString*)path; //feches image from tmp/
+ (void)clearImageWithUrl:(NSString*)url; //clears feched image

//async envoke something
+ (void)envoke:(id)request;

//create some hash
+ (NSString*)md5:(NSString*)str;

//+ (*)textWithPath:(NSString*)filepath

//compare date to two other dates
+ (BOOL) date:(NSDate*)date isBetweenDate:(NSDate*)beginDate andDate:(NSDate*)endDate;

+ (void)saveState:(NSString*)value forField:(NSString*)key;
+ (NSString*)stateForField:(NSString*)key;

//scales and rotates an image
+ (UIImage*)scaleAndRotateImage:(UIImage*)image;

@end
