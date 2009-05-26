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
	[notControls setProgress:@"Refreshing ..." animated:YES];
	[button setHidden:YES];
	[www loadOptions:[options copy]]; //start with initial options
	[notControls setProgress:@"Refreshing ..." animated:YES];	
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
		DebugLog(@"#notFeched %@ : %@", [[www options] valueForKey:@"url"], err);
	}
	[button setHidden:NO];	
	[notControls setProgress:nil animated:YES];
	[notControls lightDown];			
	[self.transender transend];			
}

- (void)feched:(id)information
{
	if (information) {	

		if ([options valueForKey:@"message"]&&!trimmedSelf) { //delete self from program, if this is an automatic fech
			[self.transender trimMemories]; //trim all that follows
			[self.transender vipeCurrentMemorie]; //vipe self
			trimmedSelf = YES;
		}
		
		if ([[www options] valueForKey:@"page"]) { 
			NSUInteger page = [[[www options] valueForKey:@"page"] intValue];
			//repage
			int page_plus = [[[www options] valueForKey:@"page_plus"] intValue];
			if (page_plus<=0) {
				page_plus = 1;
			}
			NSUInteger nextPage = page + page_plus;	
			NSMutableDictionary *repaged_options = [NSMutableDictionary dictionaryWithDictionary:[www options]];
			[repaged_options setValue:[NSString stringWithFormat:@"%i",nextPage] forKey:@"page"];				
			
			NSMutableArray *addedFecherList = [NSMutableArray arrayWithArray:[self persistedObject]];
			[addedFecherList addObjectsFromArray:information];
			
			[self.transender putMemories:information];
			//DebugLog(@"FECH ALL %@", information);

			if ([options valueForKey:@"fech_all"]) { //program says we want all pages available
				//this should add images from all pages
				[www loadOptions:repaged_options];
				[notControls setProgress:[NSString stringWithFormat:@"Pulling page %i ...", nextPage] animated:YES];
				[www fech];				
			} else { //half-automatic
				[self.transender addMemorieWithString:[NSString stringWithFormat:@"{\"ii\":\"FecherView\", \"ions\":%@, \"ior\":%@}", [repaged_options JSONFragment], [behavior JSONFragment]]];				
				[notControls setProgress:nil animated:YES];
				[notControls lightDown];			
				[self.transender transend];			
			}
			//cache
			[self saveFecherList:[NSArray arrayWithArray:addedFecherList]];

		} else { //no repaging, just one fech
			[self.transender putMemories:information]; //inserts into transender mem
			//cache
			[self saveFecherList:information];
			[notControls setProgress:nil animated:YES];
			[notControls lightDown];			
			[self.transender transend];			
		}		
	} else {
		//probably all is feched
		[notControls setProgress:nil animated:YES];
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
		if ([options valueForKey:@"message"]&&!trimmedSelf) { //delete self from program, if this is an automatic fech
			[self.transender trimMemories]; //trim all that follows
			[self.transender vipeCurrentMemorie]; //vipe self
			trimmedSelf = YES;
		}
		[self.transender putMemories:list];		
		[self.notControls lightDown];
		[self.transender transendNow];
	}			
}

#pragma mark IIController
- (void)functionalize {
	if (!www) {
		www = [[IIWWW alloc] initWithOptions:[options copy]];//make a copy, man
		[www setDelegate:self];
	}
	
	trimmedSelf = NO;

	if ([options valueForKey:@"background_url"]) {
		[self.background setImage:[Kriya imageWithUrl:[options valueForKey:@"background_url"]]];
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
		[self.button setTitle:@"+fech" forState:UIControlStateNormal];
		[self.button setEnabled:YES];
	}
	button.titleLabel.lineBreakMode = UILineBreakModeWordWrap;
	button.titleLabel.textAlignment = UITextAlignmentCenter;
	
	
}

- (void)stopFunctioning {
	[www cancelFech];
	[notControls setProgress:nil animated:YES];	
	DebugLog(@"#stopFunctioning");
}

- (void)startFunctioning {
	[button setHidden:NO];
	if ([options valueForKey:@"message"]) {
		[notControls setProgress:@"Pulling page ..." animated:YES];
		if ([options valueForKey:@"restore_key"]) {
			id info = [self persistedObject]; //[[NSUserDefaults standardUserDefaults] objectForKey:[[www options] valueForKey:@"restore_key"]];
			if (info && [info isKindOfClass:[NSArray class]]) {
				if ([info count]>0) {//load from cache
					DebugLog(@"#fech loaded from cached object");
					[self cacheFeched:info];
					[notControls setProgress:nil animated:YES];
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
	DebugLog(@"#startFunctioning");
	
}

@end
