//
//  IITransender.h
//  MakeMoney
//
/*
 *
 * Transender creates circular motion and transends or meditates.
 *
 * Imagine a circle with images attached to the edge at interval points.
 * If you always look at a turning circle from the same position in space, 
 * you se only one part of the circle - a square. 
 * That square is the image you see - or the transend you can meditate upon.
 * 
 * Transends can be of many types. You may want to look at an image while meditating.
 * You could listen to music. Or watch a movie.
 *
 * Transends can also be full-blown applications. 
 * Or simply subclasses of IIController (a UIViewController subclass).
 * The only limitation are notControls which stay above Your application view. 
 *
*/
#import "ASIHTTPRequest.h"
#import "IIController.h"
#import "IIFilter.h"
#define kIITransenderVibeShort 0.05
#define kIITransenderVibeLong 10.0
#define kIITransenderZero 0
#define kIITransenderGoldCutZero 0
#define kIITransenderDirectionUp NO
#define kIITransenderDirectionDown YES

@class IIController;

@protocol IITransenderDelegate <NSObject>
- (void)transendedWithView:(IIController*)transend withIons:(NSDictionary*)ions withIor:(NSDictionary*)ior;
- (void)transendedWithImage:(UIImage*)transend withIons:(NSDictionary*)ions withIor:(NSDictionary*)ior;
- (void)transendedWithMovie:(NSString*)transend withIons:(NSDictionary*)ions withIor:(NSDictionary*)ior;
- (void)transendedWithMusic:(NSString*)transend withIons:(NSDictionary*)ions withIor:(NSDictionary*)ior;
- (void)transendedAll:(id)sender;
- (void)fechingTransend;
- (void)fechedTransend;
@end

typedef enum {
	IITransenderInvokeFailedWithView = 0,	
	IITransenderInvokeFailedWithImage = 1,
	IITransenderInvokeFailedWithMovie = 2,
	IITransenderInvokeFailedWithMusic = 3,
	IITransenderInvokeFailedWithMessage = 4,
	IITransenderFailedWithProgram = 5
} IITransenderFailedWith;

@interface IITransender : NSObject <KriyaDelegate>
{
    id <IITransenderDelegate> delegate; //the delegate to be notified of transends
	NSMutableArray *memories; //holding our memories of transends
	NSDictionary *memory; //holding the invoked memory
	int memoriesSpot; //exact position of last transended memorie
	int memoriesCount; //cached memories count - [memories count] should be recalled only once when program changes
	int memoriesGoldcut; //goldcut - splits memories into two virtual memories - one could be used for menus
	
	float vibe; //time beetwen transends - vibration freq.
	NSTimer *beat;	//the beat generator - default transend invoker
	
	NSString *transendsPath; //path to in bundle Transends content directory
	
	BOOL direction; //indicator of moving left or right (up/down) in memories array
	NSMutableDictionary *wies; //holding all transended controllers

	BOOL cancelFech;
	
	
}

@property (nonatomic, assign) id <IITransenderDelegate> delegate;
@property (readwrite, retain) NSMutableArray *memories;
@property (readwrite) BOOL direction;
@property (readwrite, retain) NSMutableDictionary *wies;

- (id)initWith:(NSString*)jsonMemories;
- (id)init;

- (void)rememberMemoriesWithString:(NSString*)s;
- (void)rememberMemories:(NSMutableArray*)m;
- (void)addMemorieWithString:(NSString*)s;
- (void)addMemoriesWithString:(NSString*)s;
- (void)putMemories:(NSMutableArray*)m;
- (void)insertMemorieWithString:(NSString*)m atSpot:(int)s;
- (void)trimMemories;
- (void)vipeCurrentMemorie;

- (int)currentSpot;
- (float)currentVibe;
- (int)memoriesCount;

- (void)spot;
- (void)meditate;
- (void)cancelFech;
- (void)transend;
- (void)transendNow;
- (void)transendOrMeditate;
- (void)transendWithVibe:(float)v;
- (void)reVibe:(float)v;
- (void)meditateWith:(int)memoryspot;
- (void)rememberSpot;
- (BOOL)isTransending;
- (void)invokeTransend;
- (void)invokeTransend:(NSTimer*)timer;
- (void)invokeMessageTransend;
- (void)invokeTransendFailed:(IITransenderFailedWith)failed;
- (void)changeDirection;
- (void)changeDirectionTo:(BOOL)d;
- (void)goldcutAt:(int)goldcut;

//KriyaDelegate
- (void)imageWithUrlFinished:(id)response;
- (void)imageWithUrlFailed:(id)response; 
- (void)iconWithUrlFinished:(id)response;
- (void)iconWithUrlFailed:(id)response; 

- (id)fechGoldcut;

- (NSString*)pathForTransendNamed:(NSString*)transendName;
- (UIImage*)imageNamed:(NSString*)imageName;
@end
