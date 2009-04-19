//
//  IIWWW.h
//  MakeMoney
//
#import "ASIHTTPRequest.h"
#import "ASINetworkQueue.h"

@class ASINetworkQueue;

@protocol IIWWWDelegate

- (void)feched:(NSMutableArray*)listing;
- (void)notFeched:(NSString*)err;

@end


@interface IIWWW : NSObject {

    id <IIWWWDelegate> delegate; //the delegate to be notified of feches
	NSURL *url;
	NSString *params;
	ASINetworkQueue* server;
	NSString *filterName;

}
@property (nonatomic, assign) id <IIWWWDelegate> delegate;
@property (readwrite, retain) NSURL *url;
@property (readwrite, retain) NSString *params;
@property (readonly, retain) ASINetworkQueue *server;
@property (readwrite, retain) NSString *filterName;

- (id)initWithUrl:(NSString*)lru andParams:(NSString*)p;
- (void)fech;
- (void)fechPath:(NSString*)urlPath;
- (void)setProgressDelegate:(id)d;

@end
