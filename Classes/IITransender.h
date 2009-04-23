//
//  IITranscender.h
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
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "IIController.h"
#import "IIFilter.h"
#define kIITransenderVibeShort 0.05
#define kIITransenderVibeLong 2.0
#define kIITransenderZero 0
#define kIITransenderDirectionUp NO
#define kIITransenderDirectionDown YES

@class IIController;

@protocol IITransenderDelegate <NSObject>
- (void)transendedWithView:(IIController*)transend andBehavior:(NSDictionary*)behavior;
- (void)transendedWithMovie:(NSString*)transend andBehavior:(NSDictionary*)behavior;
- (void)transendedWithMusic:(NSString*)transend andBehavior:(NSDictionary*)behavior;
- (void)transendedWithImage:(UIImage*)transend andBehavior:(NSDictionary*)behavior;
- (void)transendedAll:(id)sender;
- (void)fechingTransend;
- (void)fechedTransend;
@end

@interface IITransender : NSObject //<AssetDownloadDelegate> 
{
    id <IITransenderDelegate> delegate; //the delegate to be notified of transends
	NSMutableArray *memories; //holding our memories of transends
	int memoriesSpot; //exact position of last transended memorie
	int memoriesCount; //cached memories count - [memories count] should be recalled only once when listing changes
	
	float vibe; //time beetwen transends - vibration freq.
	NSTimer *beat;	//the beat generator and transend invoker
	
	int nextMemorySpot;
	
	NSString *transendsPath; //path to Transends
	
	BOOL direction; //indicator of moving left or right (up/down) in memories array
	
}

@property (nonatomic, assign) id <IITransenderDelegate> delegate;
@property (readwrite, retain) NSMutableArray *memories;
@property (readwrite) BOOL direction;

- (id)initWith:(NSString*)jsonMemories;
- (id)init;

- (void)rememberMemoriesWithString:(NSString*)s;
- (void)rememberMemories:(NSMutableArray*)m;
- (void)addMemorieWithString:(NSString*)s;
- (void)addMemoriesWithString:(NSString*)s;
- (void)putMemories:(NSMutableArray*)m atSpot:(int)s;
- (void)insertMemorieWithString:(NSString*)m atSpot:(int)s;

- (int)currentSpot;
- (float)currentVibe;

- (void)spot;
- (void)meditate;
- (void)transend;
- (void)transendNow;
- (void)transendOrMeditate;
- (void)transendWithVibe:(float)v;
- (void)reVibe:(float)v;
- (void)meditateWith:(int)memoryspot;
- (void)rememberSpot;
- (void)invokeTransend:(NSTimer*)timer;
- (void)invokeTransend;
- (BOOL)isTransending;
- (void)changeDirection;
- (void)changeDirectionTo:(BOOL)d;

#pragma mark AssetDownloadDelegate
- (void)downloaded:(id)a;
- (void)notDownloaded:(id)a;

@end
