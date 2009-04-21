//
//  IIWWW.h
//  MakeMoney
//
#import "ASIHTTPRequest.h"
#import "ASINetworkQueue.h"
#import "IIFilter.h"

@class ASINetworkQueue;
@class IIFilter;

@protocol IIWWWDelegate
- (void)feched:(NSMutableArray*)listing;
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
- (void)fech;

@end
