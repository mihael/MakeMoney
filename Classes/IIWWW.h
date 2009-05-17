//
//  IIWWW.h
//  MakeMoney
//
#import "ASIHTTPRequest.h"
#import "ASINetworkQueue.h"
#import "IIFilter.h"
#import <CoreLocation/CoreLocation.h>

#define kPikchurUploadURL @"http://api.pikchur.com/api/post/json"
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

}
@property (nonatomic, assign) id <IIWWWDelegate> delegate;
@property (readonly, retain) ASINetworkQueue *server;
@property (readwrite, retain) NSURL *url;
@property (readwrite, retain) NSString *params;
@property (readwrite, retain) NSString *filterName;

- (id)initWithOptions:(NSDictionary*)o;
- (void)setProgressDelegate:(id)d;

//generic for any request you like
- (void)invokeRequest:(id)request;

//feching information from web
- (void)fech;
- (void)formFech;
- (void)postFech;
- (void)getFech;

 //feching is also posting information to web
- (void)fechUpdateWithParams:(NSDictionary*)p;
//TODO- (void)fechUpdateWithImage:(UIImage*)i andParams:(NSDictionary*)p;

//supported pikchur upload supply it in ions like this: "pikchur":"username@password"
- (NSString*)uploadWithPikchur:(NSString*)imagePath withDescription:(NSString*)description andLocation:(CLLocation*)location;

//authenticate with pikchur and save auth_key for later use
- (void)authenticateWithPikchur;

@end
