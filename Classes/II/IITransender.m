//
//  IITransender.m
//  MakeMoney
//
#import "Reachability.h"
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
	memoriesGoldcut = -1;
	vibe = kIITransenderVibeLong; 
	beat = nil;
	transendsPath = [[[[NSBundle mainBundle] pathForResource:@"program" ofType:@"json"] stringByDeletingLastPathComponent]retain];
	DebugLog(@"OM OM OM PATH %@", transendsPath);
	wies = [[NSMutableDictionary alloc] initWithCapacity:1];
	cancelFech = NO;
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
	DebugLog(@"viped current memorie, current spot %i", memoriesSpot);
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

#pragma mark invokes
//transend invoke
- (void)invokeTransend 
{
	[self invokeTransend:nil];
}

//find next memories position based on direction and current value of memoriesSpot(currently holding the last transended position)
- (void)computeSpot 
{
	BOOL rflow = NO;
	if (direction == kIITransenderDirectionUp) {
		if (memoriesSpot + 1 >= memoriesCount) {//reinventing circular motion
			rflow = YES;
			memoriesSpot = kIITransenderZero - 1; //if overflow jump to begining of array
		}
		memoriesSpot++; //simply increase spot - then transend with this spot
		if (memoriesGoldcut>-1&&memoriesGoldcut<memoriesCount){ //golden cutting is enabled
			if (rflow) { //crossing upper piece of transender program
				memoriesSpot = memoriesGoldcut + 1;
			} else {
				if (memoriesSpot==memoriesGoldcut+1) 
					memoriesSpot = kIITransenderZero; //back to first piece start
			}
		}			
	} else { //kIITransenderDirectionDown
		if (memoriesSpot - 1 < kIITransenderZero) {//reinventing circular motion
			rflow = YES;
			memoriesSpot = memoriesCount; //if underflow jump to end of array of memories
		}
		memoriesSpot--; //simply decrease spot - then transend with this spot		
		if (memoriesGoldcut>-1&&memoriesGoldcut<memoriesCount){ //golden cutting is enabled
			if (rflow) { //crossing lower piece of transender program
				memoriesSpot = memoriesGoldcut;
			} else {
				if (memoriesSpot==memoriesGoldcut) 
					memoriesSpot = memoriesCount - 1; //back to last piece end
			}			
		}
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
		memory = [memories objectAtIndex:memoriesSpot];
		NSDictionary *behavior = [memory objectForKey:@"ior"];
		NSDictionary *options = [memory objectForKey:@"ions"];
		NSString *memoryII = [memory valueForKey:@"ii"];		
		NSString *diskII = nil;
		
		DebugLog(@"#invokeTransend ii: %@ options: %@ behavior: %@", memoryII, options, behavior);
		//see what kind of transend this is and act	
		
		if ([memoryII isEqualToString:@"message"]) {
			//message
			
			[self invokeMessageTransend];
			
			/*
			 First incarnation of download was quick and dirty, completely in sync and blocking.
			 :)
			if ([[Reachability sharedReachability] internetConnectionStatus]!=NotReachable) {
				
				UIImage* background = nil;
				//fech background_url icon_url if not yet
				
				//feching could last longer than the vibe - lets meditate on this
				[self meditate]; 
				//NSDate *fechTime = [NSDate date];  //record point in time
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
				
				//NSTimeInterval elapsedTime = [fechTime timeIntervalSinceNow];  
				//DebugLog(@"Fech time: %f", -elapsedTime);              
				
				//transend
				if ([delegate respondsToSelector:@selector(transendedWithImage:withIons:withIor:)]) 
				{
					[delegate transendedWithImage:background withIons:options withIor:behavior];
					
					//[self transend]; //resume with transending
				}
			} else {
				[[iAlert instance] alert:@"Network unreachable" withMessage:@"Please connect device to internet. Thanks."];
				[self invokeTransendFailed:IITransenderInvokeFailedWithMessage];
			}
			*/
		} else if ([memoryII hasSuffix:@"View"]) {
			//*View
			
			BOOL functionalize = NO;
			NSString *className = [NSString stringWithFormat:@"%@Controller", memoryII];
			Class viewControllerClass = NSClassFromString(className);
			id viewController = [wies objectForKey:className];
			
			//if not in wies then laod with or without nib
			if (!viewController) {			
				if ([Kriya xibExists:memoryII] ) { //load from nib if there is one
					viewController = [[[viewControllerClass alloc] initWithNibName:memoryII bundle:nil] autorelease];
					DebugLog(@"#invokeTransend XIB viewController=%@ delegate=%@", viewController, delegate);

				} else { //just init, view controller should load it self programmatically
					
					DebugLog(@"#invokeTransend programmaticaly viewController=%@ delegate=%@", viewController, delegate);

					viewController = [[[viewControllerClass alloc] init] autorelease]; 
				}	
				//each loaded View should functionalize once
				functionalize = YES;
			}

			//transend
			if (viewController && delegate) {
				
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
				
				//functionalize only if first view load
				if (functionalize && [viewController respondsToSelector:@selector(functionalize)])
					[viewController functionalize];
				
				//finnaly transend
				if ([delegate respondsToSelector:@selector(transendedWithView:withIons:withIor:)])
					[delegate transendedWithView:viewController withIons:options withIor:behavior];
				
			} else {
				DebugLog(@"#invokeTransend not transended %i: %@", memoriesSpot, memoryII);
				[self invokeTransendFailed:IITransenderInvokeFailedWithView];
			}	
			
		} else {
			//simple transends like images, videos and sounds
			diskII = [self pathForTransendNamed:memoryII];

			//DebugLog(@"diskII %@ pathExtension %@", diskII, [memoryII pathExtension]);

			if ([[memoryII pathExtension] isEqualToString:@"jpg"]) {
				if ([delegate respondsToSelector:@selector(transendedWithImage:withIons:withIor:)]) {
					UIImage* img = [[UIImage alloc] initWithContentsOfFile:diskII];
					[delegate transendedWithImage:img withIons:options withIor:behavior];
					[img release];
				}					
			}
			
			//can not play sounds and movies in simulator, so do not transend while in simulator
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

- (void)invokeMessageTransend
{
	NSDictionary *options = [memory objectForKey:@"ions"];
	
	if ([[Reachability sharedReachability] internetConnectionStatus]!=NotReachable) {
		
		//feching could last longer than the vibe - lets meditate on this
		[self meditate]; 
		//NSDate *fechTime = [NSDate date];  //record point in time
		//notify we are feching
		if ([delegate respondsToSelector:@selector(fechingTransend)])
			[delegate fechingTransend];

		//is there an icon? fech it.
		if ([options valueForKey:@"icon_url"]) {
			if ([options valueForKey:@"refech_icon"]) { //remove feched then, and refech
				[Kriya clearImageWithUrl:[options valueForKey:@"icon_url"]];
			}
			UIImage *icon = [Kriya imageWithUrl:[options valueForKey:@"icon_url"] feches:NO];
			if (icon) { //image is cached
				[self iconWithUrlFinished:icon];
			} else { //fech anew
				[Kriya imageWithUrl:[options valueForKey:@"icon_url"] delegate:self finished:@selector(iconWithUrlFinished:) failed:@selector(iconWithUrlFailed:)];				
			}
		}
		
		//is there a background? fech it.
		if ([options valueForKey:@"background_url"]) {
			if ([options valueForKey:@"refech"]) { //remove feched then, and refech
				[Kriya clearImageWithUrl:[options valueForKey:@"background_url"]];
			}
			UIImage *background = [Kriya imageWithUrl:[options valueForKey:@"background_url"] feches:NO];
			if (background) { //image is cached
				[self imageWithUrlFinished:background];
			} else { //fech anew
				[Kriya imageWithUrl:[options valueForKey:@"background_url"] delegate:self finished:@selector(imageWithUrlFinished:) failed:@selector(imageWithUrlFailed:)];				
			}
		}		
	} else {
		[[iAlert instance] alert:@"Network unreachable" withMessage:@"Please connect device to internet. Thanks."];
		[self invokeTransendFailed:IITransenderInvokeFailedWithMessage];
	}	
}

- (void)iconWithUrlFinished:(id)response 
{
	if ([response isKindOfClass:[ASIHTTPRequest class]]){
		//just cache it
		[Kriya imageWithInMemoryImage:[UIImage imageWithData:[response responseData]] forUrl:[[response url] absoluteString]];
	}
	DebugLog(@"iconWithUrlFinished");
}

- (void)iconWithUrlFailed:(id)response 
{
	DebugLog(@"iconWithUrlFailed");
}

- (void)imageWithUrlFinished:(id)response 
{
	if (!cancelFech) {
		NSDictionary *behavior = [memory objectForKey:@"ior"];
		NSDictionary *options = [memory objectForKey:@"ions"];
		UIImage *background = nil;
		
		if ([response isKindOfClass:[UIImage class]]) {
			background = response;
		} else if ([response isKindOfClass:[ASIHTTPRequest class]]){
			background = [Kriya imageWithPath:[Kriya imageWithInMemoryImage:[UIImage imageWithData:[response responseData]] forUrl:[[response url] absoluteString]]];
		}

		if (!background && [options valueForKey:@"background"])
			background = [self imageNamed:[options valueForKey:@"background"]];
		if (!background)
			background = [self imageNamed:@"main.jpg"];
		
		//notify we feched
		if ([delegate respondsToSelector:@selector(fechedTransend)])
			[delegate fechedTransend];
		
		//transend
		if ([delegate respondsToSelector:@selector(transendedWithImage:withIons:withIor:)]) 
		{
			[delegate transendedWithImage:background withIons:options withIor:behavior];
		}
	}
	cancelFech = NO; //reset canceling indicator
	DebugLog(@"imageWithUrlFinished");
}

- (void)imageWithUrlFailed:(id)response 
{
	DebugLog(@"imageWithUrlFailed");
	[self invokeTransendFailed:IITransenderInvokeFailedWithMessage];
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
		case IITransenderInvokeFailedWithImage:			
			//[delegate transendedWithImage:[self imageNamed:@"not_image.jpg"] withIons:nil withIor:b];
			break;
		case IITransenderInvokeFailedWithMovie:			
			[delegate transendedWithImage:[self imageNamed:@"not_image.jpg"] withIons:nil withIor:b];
			break;
		case IITransenderInvokeFailedWithMusic:			
			[delegate transendedWithImage:[self imageNamed:@"not_image.jpg"] withIons:nil withIor:b];
			break;
		case IITransenderInvokeFailedWithView:			
			[delegate transendedWithImage:[self imageNamed:@"not_image.jpg"] withIons:nil withIor:b];
			break;
		default:
			[delegate transendedWithImage:[self imageNamed:@"not_image.jpg"] withIons:nil withIor:b];
			break;
	}
}

#pragma mark transends
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

- (void)cancelFech 
{
	cancelFech = YES;
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

//enable and set the goldcut
- (void)goldcutAt:(int)goldcut 
{
	if (goldcut>-2) {
		memoriesGoldcut = goldcut; //goldcutting enabled
	} else {
		memoriesGoldcut = -1; //disable cuttinggold
	}
}

- (id)fechGoldcut 
{
	if (memoriesGoldcut>-1) {
	//	memoriesGoldcut = goldcut; //goldcutting enabled
	} else {
		
	}
	return nil;
}


//return path for image relative to this transender
- (NSString*)pathForTransendNamed:(NSString*)transendName 
{
	return [NSString stringWithFormat:@"%@/%@", transendsPath, transendName];
}

//return image for imageName - only for images within Resources/Transends dir
- (UIImage*)imageNamed:(NSString*)imageName 
{
	return [UIImage imageWithContentsOfFile:[self pathForTransendNamed:imageName]];
}
@end
