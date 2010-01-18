//
//  IIWWW.h
//  MakeMoney
//
#import "ASIHTTPRequest.h"
#import "ASINetworkQueue.h"
#import "IIFilter.h"
#import <CoreLocation/CoreLocation.h>
                            
#define kPikchurUploadURL @"http://api.pikchur.com/api/post/json"
#define kPikchurAuthURL @"https://api.pikchur.com/auth/json"
#define kPikchurAPIKey @"plusOOts6YVcBSFGgT0jaA"

#define kTwitPicUploadURL @"http://twitpic.com/api/uploadAndPost"

#define TIMEOUT_SEC 120

@class ASINetworkQueue;
@class IIFilter;

@protocol IIWWWDelegate
- (void)feched:(id)information;
- (void)notFeched:(NSString*)err;
@end

@interface IIWWW : NSObject {
    id <IIWWWDelegate> delegate; //the delegate to be notified of feches
	ASINetworkQueue* server;

	//classics
	NSURLConnection *connection;
	NSMutableData *recievedData;
	int statusCode;
	
	NSDictionary *options;
	int page;
	int limit;
	
	NSURL *url;
	NSString *params;

	IIFilter *filter;
	NSString *filterName;
	
	BOOL cancel;
}
@property (nonatomic, assign) id <IIWWWDelegate> delegate;
@property (readonly, retain) ASINetworkQueue *server;
@property (readwrite, retain) NSURL *url;
@property (readwrite, copy) NSString *params;
@property (readwrite, copy) NSString *filterName;
@property (readwrite, copy) NSDictionary *options;

- (id)initWithOptions:(NSDictionary*)o;
- (void)loadOptions:(NSDictionary*)o;
- (BOOL)hasWWWAccess;

- (void)setProgressDelegate:(id)d;


//generic for any sync request you like
- (void)invokeRequest:(id)request;

//generic for any async request you like
- (void)envokeRequest:(id)request;

//feching information from web
- (void)cancelFech; //cancel all operation
- (void)fech; //fech whatever is set in options

//fech methods - called automagically
- (void)formFech;
- (void)postFech;
- (void)getFech;

//asi delegates
- (void)fechFailed:(ASIHTTPRequest *)request;
- (void)fechFinished:(ASIHTTPRequest *)request;

//feching is also posting information to web
- (void)fechUpdateWithParams:(NSDictionary*)p;
//TODO- (void)fechUpdateWithImage:(UIImage*)i andParams:(NSDictionary*)p;

//supported pikchur upload, supply it in ions like this: "pikchur":"username@password"
- (void)fechUploadWithPikchur:(NSString*)imagePath withDescription:(NSString*)description andLocation:(CLLocation*)location andProgress:(id)progressDelegate;

//supported twitpic upload, supply it in ions like this: "twitter":"username@password"
- (void)fechUploadWithTwitPic:(NSString*)imagePath withDescription:(NSString*)description andLocation:(CLLocation*)location andProgress:(id)progressDelegate;


//preparing image for upload
- (UIImage*)scaleAndRotateImage:(UIImage*)image;

//this is sync
//authenticate with pikchur and save auth_key for later use
- (void)authenticateWithPikchur;
- (BOOL)isAuthenticatedWithPikchur;

//classic request
- (NSMutableURLRequest*)makeRequest:(NSString*)_url;


@end
