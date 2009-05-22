//
//  IITranscender.m
//  MakeMoney
//
#import "IITransender.h"
#import "JSON.h"
#import "ASIHTTPRequest.h"
#ifdef __APPLE__
#include "TargetConditionals.h"
#endif

@implementation IITransender
@synthesize memories, delegate, direction, wies;

#pragma mark Om Init
// always connect with Mother Earth before acting
- (void)om 
{
	direction = kIITransenderDirectionUp;
	memoriesSpot = kIITransenderZero - 1; //if direction is down should be + 1 here
	memoriesCount = 0;
	vibe = kIITransenderVibeLong; 
	beat = nil;
	transendsPath = [[[[NSBundle mainBundle] pathForResource:@"program" ofType:@"json"] stringByDeletingLastPathComponent]retain];
	DebugLog(@"OM OM OM PATH %@", transendsPath);
	wies = [[NSMutableDictionary alloc] initWithCapacity:1];
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

- (void)saveMemoriesAndSpotToASettingInIphone
{
  //TODO
}

- (void)dealloc {
	[transendsPath release];
	[memories release];
	[wies release];
    [super dealloc];
}

#pragma mark Work Purifies
- (void)rememberMemoriesWithString:(NSString*)s
{
	[self rememberMemories:[s JSONValue]];
}

- (void)rememberMemories:(NSMutableArray*)m 
{
	if (m) {
		[self setMemories:m];
		memoriesCount = [memories count]; //calculate size once on every listing change	
    }else {
		[self invokeTransendFailed:IITransenderFailedWithProgram];
	}
}
//adds memories to the end pf program
- (void)addMemorieWithString:(NSString*)s 
{
	DebugLog(@"#addMemorieWithString %@", s);
	if (s) {
		[self.memories addObject:[s JSONValue]];
		memoriesCount = [memories count];
	} else {
		[self invokeTransendFailed:IITransenderFailedWithProgram];
	}
}

//inserts memories at spot
- (void)putMemories:(NSMutableArray*)m
{
	if (m) {
	DebugLog(@"#putMemories %i at spot %i", [m count], memoriesSpot+1);
	[self.memories insertObjects:m atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(memoriesSpot+1, [m count])]];
	memoriesCount = [memories count]; //calculate size once on every listing change	
	} else {
		[self invokeTransendFailed:IITransenderFailedWithProgram];
	}
}

//adds memorie to the end of program
- (void)addMemoriesWithString:(NSString*)s 
{
	DebugLog(@"#addMemoriesWithString %@", s);
	if (s) {
		[self.memories addObjectsFromArray:[s JSONValue]];
		memoriesCount = [memories count];
	} else {
		[self invokeTransendFailed:IITransenderFailedWithProgram];
	}
}

//inserts memorie at spot
- (void)insertMemorieWithString:(NSString*)m atSpot:(int)s
{
	DebugLog(@"#insertMemorieWithString %@", m);
	if (s>-1) {
		if (s>memoriesCount)			 
			[self.memories addObject:[m JSONValue]];
		else 
			[self.memories insertObject:[m JSONValue] atIndex:s];			
		memoriesCount = [memories count];
	}	
}

//deletes memories from current spot - only up direction
- (void)trimMemories
{
	if (direction == kIITransenderDirectionUp) {
		for (NSUInteger i=(memoriesCount-1); i>memoriesSpot; i--) {
			[self.memories removeObjectAtIndex:i];
			DebugLog(@"trimming one spot %i", i);
		}
		
	}
}

- (void)vipeCurrentMemorie
{
	[self.memories removeObjectAtIndex:memoriesSpot];
	memoriesCount = [self.memories count];
	
	if (direction == kIITransenderDirectionUp) {
		if (memoriesSpot - 1 < kIITransenderZero)
			memoriesSpot = memoriesCount;
		memoriesSpot--; 
	} else {
		if (memoriesSpot + 1 >= memoriesCount)
			memoriesSpot = kIITransenderZero - 1; 
		memoriesSpot++; 
	}	
	DebugLog(@"viped current memorie now at %i", memoriesSpot);
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
		DebugLog(@"#invokeTransend timer:%@ spot:%i vibe: %f", timer, memoriesSpot, vibe);

		//read ii
		NSDictionary *memory = [memories objectAtIndex:memoriesSpot];
		NSDictionary *behavior = [memory objectForKey:@"ior"];
		NSDictionary *options = [memory objectForKey:@"ions"];
		NSString *memoryII = [memory valueForKey:@"ii"];		
		NSString *diskII = nil;
		
		//see what kind of transend this is and act		
		if ([memoryII isEqualToString:@"message"]) {
			UIImage* background = nil;
			//fech background_url icon_url if not yet

			//feching could last longer than the vibe - lets meditate on this
			[self meditate]; 
			NSDate *fechTime = [NSDate date];  //record point in time
			//notify we are feching
			if ([delegate respondsToSelector:@selector(fechingTransend)])
				[delegate fechingTransend];
			
			if ([options valueForKey:@"icon_url"])
				[Kriya imageWithUrl:[options valueForKey:@"icon_url"]];
			if ([options valueForKey:@"background_url"]) {
				if ([options valueForKey:@"refech"]) { //remove feched then, and refech
					[Kriya clearImageWithUrl:[options valueForKey:@"background_url"]];
				}
				background = [Kriya imageWithUrl:[options valueForKey:@"background_url"]];
			}
			if (!background && [options valueForKey:@"background"])
				background = [self imageNamed:[options valueForKey:@"background"]];
			if (!background)
				background = [self imageNamed:@"main.jpg"];
			
			//notify we feched
			if ([delegate respondsToSelector:@selector(fechedTransend)])
				[delegate fechedTransend];
			
			NSTimeInterval elapsedTime = [fechTime timeIntervalSinceNow];  
			DebugLog(@"Fech time: %f", -elapsedTime);              
						
			//transend
			if ([delegate respondsToSelector:@selector(transendedWithImage:withIons:withIor:)]) 
			{
				[delegate transendedWithImage:background withIons:options withIor:behavior];
			
				//[self transend]; //resume with transending
			}
			
		} else if ([memoryII hasSuffix:@"View"]) {

			NSString *className = [NSString stringWithFormat:@"%@Controller", memoryII];
			Class viewControllerClass = NSClassFromString(className);
			id viewController = [wies objectForKey:className];

			//if not in wies then laod with or without nib
			if (!viewController) {			
				if ([Kriya xibExists:memoryII] ) { //load from nib if there is one
					viewController = [[[viewControllerClass alloc] initWithNibName:memoryII bundle:nil] autorelease];
				} else { //just init, view controller should load it self programmatically
					viewController = [[[viewControllerClass alloc] init]autorelease]; 
				}		
			}
				
			//transend
			if (viewController && [viewController respondsToSelector:@selector(startFunctioning)] && delegate) {

				if ([viewController respondsToSelector:@selector(setTransender:)])
					[viewController setTransender:self];

				//send options to wiev, reusability
				if (options) {
					//set fresh options
					if ([viewController respondsToSelector:@selector(setOptions:)])
						[viewController setOptions:options];			
					//record this wiev into wievs - reuse view object?
					if ([options valueForKey:@"reuse"]) {
						[wies setObject:viewController forKey:className];
						DebugLog(@"#invokeTransend REUSING %@", className);
					}
				}
				
				//send behavior to wiev
				if (behavior) {
					if ([viewController respondsToSelector:@selector(setBehavior:)])
						[viewController setBehavior:behavior];
				}

				//functionalize
				if ([viewController respondsToSelector:@selector(functionalize)])
					[viewController functionalize];
				
				if ([delegate respondsToSelector:@selector(transendedWithView:withIons:withIor:)])
					[delegate transendedWithView:viewController withIons:options withIor:behavior];
			
			} else {
				DebugLog(@"#invokeTransend not transended %i: %@", memoriesSpot, memoryII);
				[self invokeTransendFailed:IITransenderFailedWithView];
			}	
			
		} else {
			if ([memoryII hasPrefix:@"0"]) { //a simple 0-prefixed transend
				diskII = [NSString stringWithFormat:@"%@/%@", transendsPath, memoryII];
			} else if ([memoryII hasPrefix:@"/"]) { //a direct path
				diskII = memoryII;
			}
		
			if ([[memoryII pathExtension] isEqualToString:@"jpg"]) {
				if ([delegate respondsToSelector:@selector(transendedWithImage:withIons:withIor:)]) {
					UIImage* img = [[UIImage alloc] initWithContentsOfFile:diskII];
					[delegate transendedWithImage:img withIons:options withIor:behavior];
					[img release];
				}					
			}

			//can not play sounds and movies in simulator, so do not transend
			#if !(TARGET_IPHONE_SIMULATOR)
			if ([[memoryII pathExtension] isEqualToString:@"mov"]) {
				if ([delegate respondsToSelector:@selector(transendedWithMovie:withIons:withIor:)])
					[delegate transendedWithMovie:diskII withIons:options withIor:behavior];
			}
			if ([[memoryII pathExtension] isEqualToString:@"caf"]) {
				if ([delegate respondsToSelector:@selector(transendedWithMusic:withIons:withIor:)])
					[delegate transendedWithMusic:diskII withIons:options withIor:behavior];
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
	NSDictionary* b = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"true", @"3", nil] forKeys:[NSArray arrayWithObjects:@"stop", @"effect", nil]];
	switch (failed) {
		case IITransenderFailedWithProgram:			
//			[delegate transendedWithImage:[self imageNamed:@"not_image.jpg"] withIons:nil withIor:b];
			DebugLog(@"Failed with program.");
			[self meditate];
			break;
		case IITransenderFailedWithImage:			
			[delegate transendedWithImage:[self imageNamed:@"not_image.jpg"] withIons:nil withIor:b];
			break;
		case IITransenderFailedWithMovie:			
			[delegate transendedWithImage:[self imageNamed:@"not_image.jpg"] withIons:nil withIor:b];
			break;
		case IITransenderFailedWithMusic:			
			[delegate transendedWithImage:[self imageNamed:@"not_image.jpg"] withIons:nil withIor:b];
			break;
		case IITransenderFailedWithView:			
			[delegate transendedWithImage:[self imageNamed:@"not_image.jpg"] withIons:nil withIor:b];
			break;
		default:
			[delegate transendedWithImage:[self imageNamed:@"not_image.jpg"] withIons:nil withIor:b];
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

//memories count
- (int)memoriesCount 
{
	return memoriesCount;
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

//return path for image relative to this transender
- (NSString*)pathForImageNamed:(NSString*)imageName 
{
	return [NSString stringWithFormat:@"%@/%@", transendsPath, imageName];
}

//return image for imageName 
- (UIImage*)imageNamed:(NSString*)imageName 
{
	return [UIImage imageWithContentsOfFile:[self pathForImageNamed:imageName]];
}
@end
