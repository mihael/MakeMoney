//
//  FecherViewController.m
//  MakeMoney
//
#import "FecherViewController.h"
#import "IIWWW.h"
#import "JSON.h"

@implementation FecherViewController
@synthesize button, background;

- (IBAction)buttonTouched:(id)sender
{
	[button setHidden:YES];
	[self progressUp:[options valueForKey:@"page"]];
	[www fech];	
}

- (void)dealloc {
	[www release];
	www = nil;
    [super dealloc];
}

#pragma mark IIWWWDelegate
- (void)notFeched:(NSString*)err
{
	if ([options valueForKey:@"fech_all"]) { //program says we want all pages available
		//this is a fail, probably no more pages
		//repress error
		DebugLog(@"#notFeched probably finished feching all pages");
	} else {
		DebugLog(@"#notFeched %@ : %@", [options valueForKey:@"url"], err);
	}
	[button setHidden:NO];	
	[self progressDown];
	[notControls lightDown];			
	[self.transender transend];			
}

- (void)feched:(id)information
{
	if (information) {	
		
		if (!trimmedSelf)
			[self.transender trimMemories]; //trim all that follows

		if ([options valueForKey:@"message"]&&!trimmedSelf) { //delete self from program, if this is an automatic fech
			[self.transender vipeCurrentMemorie]; //vipe self
			trimmedSelf = YES;
		}
		
		if ([www.options valueForKey:@"page"]) { //www.options hold repages
			NSUInteger page = [[www.options valueForKey:@"page"] intValue];
			DebugLog(@"OPTIONS PAGE %i", page);
			//repage
			int page_plus = [[www.options valueForKey:@"page_plus"] intValue];
			if (page_plus<=0) {
				page_plus = 1;
			}
			NSUInteger nextPage = page + page_plus;	
			NSMutableDictionary *repaged_options = [NSMutableDictionary dictionaryWithDictionary:www.options];
			[repaged_options setValue:[NSString stringWithFormat:@"%i",nextPage] forKey:@"page"];				
			
			NSMutableArray *addedFecherList = [NSMutableArray arrayWithArray:[self persistedObject]];
			[addedFecherList addObjectsFromArray:information];
			
			[self.transender putMemories:information];
			//DebugLog(@"FECH ALL %@", information);

			if ([options valueForKey:@"fech_all"]) { //program says we want all pages available
				//this should add images from all pages
				[www loadOptions:repaged_options];
				[self progressUp:[NSString stringWithFormat:@"%i", nextPage]];
				[www fech];				
			} else { //half-automatic
				DebugLog(@"HALF_AUTOMATIC repage %i", nextPage);
				[self.transender addMemorieWithString:[NSString stringWithFormat:@"{\"ii\":\"FecherView\", \"ions\":%@, \"ior\":%@}", [repaged_options JSONFragment], [behavior JSONFragment]]];				
				[self progressDown];
				[notControls lightDown];			
				[self.transender transend];			
			}
			//cache
			[self saveFecherList:[NSArray arrayWithArray:addedFecherList]];

		} else { //no repaging, just one fech
			[self.transender putMemories:information]; //inserts into transender mem
			//cache
			[self saveFecherList:information];
			[self progressDown];
			[notControls lightDown];			
			[self.transender transend];			
		}		
	} else {
		//probably all is feched
		[self progressDown];
		[notControls lightDown];			
		[self.transender transend];			
	}
}

- (void)saveFecherList:(NSArray*)list
{
	[self persistObject:list];
}

- (void)cacheFeched:(NSArray*)list
{
	if (list) {	
		if (!trimmedSelf)
			[self.transender trimMemories]; //trim all that follows
		if ([options valueForKey:@"message"]&&!trimmedSelf) { //delete self from program, if this is an automatic fech
			[self.transender vipeCurrentMemorie]; //vipe self
			trimmedSelf = YES;
		}
		[self.transender putMemories:[list mutableCopy]];		
		[self.notControls lightDown];
		[self.transender transendNow];
	}			
}

#pragma mark IIController
- (void)functionalize {
	if (!www) {
		www = [[IIWWW alloc] init];//make a copy, man
		//DebugLog(@"LOADed OPTIONS from functionalize %i", [[options valueForKey:@"page"] intValue]);
		[www loadOptions:options];
		[www setDelegate:self];
	}
	
}

- (void)stopFunctioning {
	[www cancelFech];
	[self progressDown];
	DebugLog(@"#stopFunctioning");
}

- (void)startFunctioning {
	[button setHidden:NO];
	[www loadOptions:options]; //change options
	trimmedSelf = NO; //not yet trimmed self
	
	if ([options valueForKey:@"background_url"]) {
		[self.background setImage:[Kriya imageWithUrl:[options valueForKey:@"background_url"] feches:YES]];
	} else if ([options valueForKey:@"background"]) {
		[self.background setImage:[self.transender imageNamed:[options valueForKey:@"background"]]];
	}
	
	if (![self.background image]) {
		[self.background setImage:[self.transender imageNamed:@"main.jpg"]];
	}
	
	if ([options valueForKey:@"button_title"]) {
		[self.button setTitle:[options valueForKey:@"button_title"] forState:UIControlStateNormal];	
		[self.button setEnabled:YES];
	} else if ([options valueForKey:@"message"]) {
		[self.button setTitle:[options valueForKey:@"message"] forState:UIControlStateNormal];	
		[self.button setEnabled:NO];
	} else {
		[self.button setTitle:@"+" forState:UIControlStateNormal];
		[self.button setEnabled:YES];
	}
	//button.titleLabel.lineBreakMode = UILineBreakModeWordWrap;
	//button.titleLabel.textAlignment = UITextAlignmentCenter;
	
	if ([options valueForKey:@"message"]) {
		[self progressUp:[options valueForKey:@"page"]];
		if ([options valueForKey:@"restore_key"]) {
			id info = [self persistedObject]; //[[NSUserDefaults standardUserDefaults] objectForKey:[[www options] valueForKey:@"restore_key"]];
			if (info && [info isKindOfClass:[NSArray class]]) {
				if ([info count]>0) {//load from cache
					DebugLog(@"#fech loaded from cached object");
					[self cacheFeched:info];
					[self progressDown];
				} else {
					DebugLog(@"#refeching cached object");
					[www fech];							
				}
			} else {
				DebugLog(@"#refeching cached object");
				[www fech];			
			}
		} else { //normal handling, not use cache
			[www fech];					
		}
	}
	
	[self layout:[Kriya orientedFrame]];
	DebugLog(@"#startFunctioning");
	
}

- (void)layout:(CGRect)rect
{
	[self.view setFrame:rect];
	[button setFrame:CGRectMake(20, 20, rect.size.width - 20, rect.size.height - 20)];
	if (rect.size.width == 320.0) {
		[background setImage:[self.transender imageNamed:@"vmain.jpg"]];
	} else {
		[background setImage:[self.transender imageNamed:@"main.jpg"]];
	}
	[background setFrame:rect];
}

- (void)progressUp:(NSString*)page
{
	if (page)
		[notControls setProgress:[NSString stringWithFormat:@"Pulling page %@ ...", page] animated:YES];
	else
		[notControls setProgress:@"Pulling page ..." animated:YES];
}
- (void)progressDown
{
	[notControls setProgress:nil animated:YES];
}

@end
