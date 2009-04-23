//
//  IITranscender.m
//  MakeMoney
//
#import <UIKit/UIKit.h>
#import "IITransender.h"
#import "JSON.h"
#import "ASIHTTPRequest.h"
#ifdef __APPLE__
#include "TargetConditionals.h"
#endif

typedef enum {
	IITransenderFailedWithImage = 0,
	IITransenderFailedWithMovie = 1,
	IITransenderFailedWithSound = 2,
	IITransenderFailedWithView = 3	
} IITransenderFailedWith;

@implementation IITransender
@synthesize memories, delegate, direction;

#pragma mark Om Init
// always connect with Mother Earth before acting
- (void)om 
{
	direction = kIITransenderDirectionUp;
	memoriesSpot = kIITransenderZero - 1; //if direction is down should be + 1 here
	memoriesCount = 0;
	nextMemorySpot = kIITransenderZero;
	vibe = kIITransenderVibeLong; 
	beat = nil;
	transendsPath = [[[[NSBundle mainBundle] pathForResource:@"listing" ofType:@"json"] stringByDeletingLastPathComponent] retain];
}

//for simple fast usage with 0_prefixed.jpg images, sounds and movies
//finds all resources with prefix "0" and adds them for transending
- (id)init
{
	if (self = [super init]) {
		[self om];	
		NSMutableString *transends = [NSMutableString stringWithString:@"["];	

		NSArray *paths = [[NSBundle mainBundle] pathsForResourcesOfType:nil inDirectory:@""];
		NSUInteger i, count = [paths count];
		for (i = 0; i < count; i++) {
			NSString * p = [paths objectAtIndex:i];
			if ([[p lastPathComponent] hasPrefix:@"0"]) {
				[transends appendFormat:@"{\"name\":\"%@\"},", p]; // [[p componentsSeparatedByString:@"/"] lastObject]];
			}
		}
		[self rememberMemoriesWithString:[NSString stringWithFormat:@"%@]", [transends substringToIndex:transends.length-1]]];
	}
	return self;
}

//adds all resources listed in json listing
- (id)initWith:(NSString*)jsonMemories
{
	if (self = [super init]) {
		[self om];
		[self rememberMemoriesWithString:jsonMemories];
	}
	return self;
}

- (void)dealloc {
	[transendsPath release];
    [super dealloc];
}

#pragma mark Work Purifies
- (void)rememberMemoriesWithString:(NSString*)s
{
	[self rememberMemories:[s JSONValue]];
}

- (void)rememberMemories:(NSMutableArray*)m 
{
	[self setMemories:m];
	memoriesCount = [memories count]; //calculate size once on every listing change	
}

- (void)addMemorieWithString:(NSString*)s 
{
	DebugLog(@"IITransender#addMemorieWithString %@", s);
	if (s) {
		[self.memories addObject:[s JSONValue]];
		memoriesCount = [memories count];
	}
}

#pragma mark Transendence
//vibe is time beetwen transends
- (void)setTransendenceVibe:(float)v
{
	if (v>kIITransenderVibeShort && v<kIITransenderVibeLong) {
		vibe = v;
		//DebugLog(@"IITransender#setTransendenceVibe %f", vibe);
	}
}

//transend invoke
- (void)invokeTransend 
{
	[self invokeTransend:nil];
}

//find next memories position based on direction and current value of memoriesSpot(currently holding the last transended position)
- (void)computeSpot 
{
	if (direction == kIITransenderDirectionUp) {
		if (memoriesSpot + 1 >= memoriesCount) //reinventing circular motion
			memoriesSpot = kIITransenderZero - 1; //if overflow jump to begining of array
		memoriesSpot++; //simply increase spot - then transend with this spot
	} else {
		if (memoriesSpot - 1 < kIITransenderZero) //reinventing circular motion
			memoriesSpot = memoriesCount; //if underflow jump to end of array
		memoriesSpot--; //simply decrease spot - then transend with this spot		
	}
}

//the main method
- (void)invokeTransend:(NSTimer*)timer
{
	if (delegate) {
		//find out what is next
		[self computeSpot];

		//transend with memoriesSpot
		DebugLog(@"IITransender#invokeTransend %i vibe: %f", memoriesSpot, vibe);
		
		NSDictionary *behavior = [[memories objectAtIndex:memoriesSpot] objectForKey:@"behavior"];
		NSDictionary *options = [[memories objectAtIndex:memoriesSpot] objectForKey:@"options"];
		NSString *memoryName = [[memories objectAtIndex:memoriesSpot] valueForKey:@"name"];		
		NSString *diskName = nil;
		
		if ([memoryName isEqualToString:@"remote_image"]){
			//do nothing until II
			
			//get diskName from url
			diskName = [[options valueForKey:@"url"] lastPathComponent];
			
			NSString *path = [NSHomeDirectory() stringByAppendingString:@"/tmp"];
			[[NSFileManager defaultManager] createDirectoryAtPath:path attributes:nil];			
			path = [NSString stringWithFormat:@"%@/%@", path, diskName];
			//if diskName exist?
			if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
				//transend with it
				UIImage* img = [[UIImage alloc] initWithContentsOfFile:path];
				[delegate transendedWithImage:img andBehavior:behavior];
				[img release];				
			} else {
				//feching could last longer than the vibe - lets meditate on this
				[self meditate]; 
				//notify we are feching
				if ([delegate respondsToSelector:@selector(fechingTransend)])
					[delegate fechingTransend];

				NSURL *url = [NSURL URLWithString:[options valueForKey:@"url"]];
				ASIHTTPRequest *request = [[[ASIHTTPRequest alloc] initWithURL:url] autorelease];
				[request setDownloadDestinationPath:path];
				[request start];
				NSError *error = [request error];
				if (!error) {
					if ([delegate respondsToSelector:@selector(fechedTransend)])
						[delegate fechedTransend];

					UIImage* img = [[UIImage alloc] initWithContentsOfFile:path];
					[delegate transendedWithImage:img andBehavior:behavior];
					[img release];	
				} else {
					DebugLog(@"IITransender#invokeTransend failed remote_image fech");
					[self invokeTransendFailed:IITransenderFailedWithImage];
				}
				[self transend]; //resume with transending
			}
		} else if ([memoryName hasSuffix:@"View"]) {
			NSString *className = [NSString stringWithFormat:@"%@Controller", memoryName];
			Class viewControllerClass = NSClassFromString(className);
			id viewController = nil;
					
			if ([Kriya xibExists:memoryName] ) { //load from nib if there is one
				viewController = [[[viewControllerClass alloc] initWithNibName:memoryName bundle:nil] autorelease];
			} else { //just init, view controller should load it self programmatically
				viewController = [[[viewControllerClass alloc] init]autorelease]; 
			}		
			
			//transend
			if (viewController && [viewController respondsToSelector:@selector(startFunctioning)] && delegate) {
				if (options) {
					if ([viewController respondsToSelector:@selector(setTransender:)])
						[viewController setTransender:self];
					if ([viewController respondsToSelector:@selector(setOptions:)])
						[viewController setOptions:options];			
				}
				if (behavior) {
					if ([viewController respondsToSelector:@selector(setBehavior:)])
						[viewController setBehavior:behavior];
				}
					
				if ([delegate respondsToSelector:@selector(transendedWithView:andBehavior:)])
					[delegate transendedWithView:viewController andBehavior:behavior];
			} else {
				DebugLog(@"IITransender#invokeTransend not transended %i: %@", memoriesSpot, memoryName);
				[self invokeTransendFailed:IITransenderFailedWithView];
			}	
		
		} else {
			if ([memoryName hasPrefix:@"0"]) { //a simple 0-prefixed transend
				diskName = [NSString stringWithFormat:@"%@/%@", transendsPath, memoryName];
			} else if ([memoryName hasPrefix:@"/"]) { //a direct path
				diskName = memoryName;
			}
		
			if ([[memoryName pathExtension] isEqualToString:@"jpg"]) {
				if ([delegate respondsToSelector:@selector(transendedWithImage:andBehavior:)]) {
					UIImage* img = [[UIImage alloc] initWithContentsOfFile:diskName];
					[delegate transendedWithImage:img andBehavior:behavior];
					[img release];
				}					
			}

			//can not play sounds and movies in simulator, so do not transend
			#if !(TARGET_IPHONE_SIMULATOR)
			if ([[memoryName pathExtension] isEqualToString:@"mov"]) {
				if ([delegate respondsToSelector:@selector(transendedWithMovie:andBehavior:)])
					[delegate transendedWithMovie:diskName andBehavior:behavior];
			}
			if ([[memoryName pathExtension] isEqualToString:@"caf"]) {
				if ([delegate respondsToSelector:@selector(transendedWithMusic:andBehavior:)])
					[delegate transendedWithMusic:diskName andBehavior:behavior];
			}		
			#endif
		}

		//always call delegate when last transend in listing transended
		if (memoriesSpot == memoriesCount) {
			if ([delegate respondsToSelector:@selector(transendedAll:)])
				[delegate transendedAll:self];		
		}
	}	

}

//failed with some? happens... although it is not shit. it is manuever, so you can grow.
- (void)invokeTransendFailed:(IITransenderFailedWith)failed 
{
	switch (failed) {
		case IITransenderFailedWithImage:			
			[delegate transendedWithImage:[UIImage imageNamed:@"not_image.jpg"] andBehavior:nil];
			break;
		case IITransenderFailedWithMovie:			
			[delegate transendedWithImage:[UIImage imageNamed:@"not_image.jpg"] andBehavior:nil];
			break;
		case IITransenderFailedWithSound:			
			[delegate transendedWithImage:[UIImage imageNamed:@"not_image.jpg"] andBehavior:nil];
			break;
		case IITransenderFailedWithView:			
			[delegate transendedWithImage:[UIImage imageNamed:@"not_image.jpg"] andBehavior:nil];
			break;
		default:
			[delegate transendedWithImage:[UIImage imageNamed:@"not_image.jpg"] andBehavior:nil];
			break;
	}
}

//if transending, meditate, if meditating, transend
- (void)transendOrMeditate 
{
	if ([self isTransending]) {
		[self meditate];
	} else {
		[self transend];
	}
}

//transends one memorie after another with the vibe 
- (void)transend 
{
	[self transendWithVibe:vibe];
}

//invokes first then starts transending 
- (void)transendNow 
{
	[self invokeTransend];
	[self transend];
}

- (void)transendWithVibe:(float)v
{
	[self meditate];
	[self setTransendenceVibe:v];
	beat = [[NSTimer scheduledTimerWithTimeInterval:vibe
											 target:self 
										   selector:@selector(invokeTransend:)
                                           userInfo:nil
                                            repeats:YES] retain];
}

//change the transending vibe - time beetween transends
- (void)reVibe:(float)v
{
	if ([self isTransending]) {
		[self transendWithVibe:v];
	} else {
		[self setTransendenceVibe:v];
	}
}

//transend directly to chosen transend
- (void)meditateWith:(int)memoryspot 
{
	//set to a previous position so computeSpot computes the right memories position
	if (direction == kIITransenderDirectionUp) {
		memoriesSpot = memoryspot - 1;
	} else {
		memoriesSpot = memoryspot + 1;
	}
	//invoke transend - computeSpot will be called increasing by 1 or decreasing by -1
	[self invokeTransend];
}

//stops transending memories for meditation
- (void)meditate
{
    if (beat) {
        [beat invalidate];
        [beat release];
		beat = nil;
		//time stop
    }
}

//push memory spot at start, do nothing about it
- (void)spot 
{
	memoriesSpot = kIITransenderZero - 1;
}

//return current memory spot
- (int)currentSpot 
{
	return memoriesSpot;
}

//remember last runs memory spot and meditate with
- (void)rememberSpot
{
	int s = [[NSUserDefaults standardUserDefaults] integerForKey:SPOT];
	[self meditateWith:s];
}

//return current vibe
- (float)currentVibe 
{
	return vibe;
}

//no beat, no transending
- (BOOL)isTransending 
{
	return (beat!=nil);
}

//change direction of circular array motion
- (void)changeDirection 
{
	if (direction == kIITransenderDirectionUp) {
		[self setDirection:kIITransenderDirectionDown];
	} else {
		[self setDirection:kIITransenderDirectionUp];	
	}
}

//change direction of circular array motion
- (void)changeDirectionTo:(BOOL)d 
{
	[self setDirection:d];
}

@end
