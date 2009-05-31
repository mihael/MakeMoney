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

@class ASINetworkQueue;
@class IIFilter;

@protocol IIWWWDelegate
- (void)feched:(id)information;
- (void)notFeched:(NSString*)err;
@end

@interface IIWWW : NSObject {
    id <IIWWWDelegate> delegate; //the delegate to be notified of feches
	ASINetworkQueue* server;

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
@property (readwrite, retain) NSString *params;
@property (readwrite, retain) NSString *filterName;
@property (readwrite, assign) NSDictionary *options;

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

//supported pikchur upload supply it in ions like this: "pikchur":"username@password"
- (void)fechUploadWithPikchur:(NSString*)imagePath withDescription:(NSString*)description andLocation:(CLLocation*)location andProgress:(id)progressDelegate;
- (UIImage*)scaleAndRotateImage:(UIImage*)image;

//this is sync
//authenticate with pikchur and save auth_key for later use
- (void)authenticateWithPikchur;
- (BOOL)isAuthenticatedWithPikchur;

@end
