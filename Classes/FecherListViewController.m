//
//  FecherListViewController.m
//  MakeMoney
//
#import "FecherListViewController.h"
#import "IIWWW.h"
#import "JSON.h"
#define kSelectedFech @"selectedFech"
@implementation FecherListViewController
@synthesize fecherList, background;

- (void)dealloc {
	[fecherList release];
	[www release];
    [super dealloc];
}
#pragma mark refreshing button
- (IBAction)refresh:(id)sender 
{
	[notControls setProgress:@"Refreshing ..." animated:YES];
	[www loadOptions:[options copy]]; //start with initial options
	[fecherList release];
	fecherList = nil;
	fecherList = [[NSArray alloc] init];
	selectedFech = 0;
	[fecherTable reloadData];
	[notControls setProgress:@"Refreshing ..." animated:YES];
	[www fech];
}


#pragma mark IIWWWDelegate
- (void)notFeched:(NSString*)err
{
	[notControls setProgress:nil animated:YES];	
	if ([options valueForKey:@"fech_all"]) { //program says we want all pages available
		//this is a fail, probably no more pages
		//repress error
		DebugLog(@"#notFeched probably finished feching all pages");
	} else {
		DebugLog(@"#notFeched %@ : %@", [[www options] valueForKey:@"url"], err);
	}
}

- (void)feched:(id)information
{
	if (information) {
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
			
			if ([options valueForKey:@"fech_all"]) { //program says we want all pages available
				//this should fech all pages
				//add current informations
				//DebugLog(@"FECH ALL %@", information);
				NSMutableArray *addedFecherList = [NSMutableArray arrayWithArray:[self fecherList]];
				[addedFecherList addObjectsFromArray:information];
				@synchronized(fecherList) {
					[self setFecherList:[NSArray arrayWithArray:addedFecherList]];
				}
				[fecherTable reloadData];			
				//reset www with repaged and call www again
				[www loadOptions:repaged_options];
				//refech				
				[notControls setProgress:[NSString stringWithFormat:@"Pulling page %i ...", nextPage - 1] animated:YES];
				[www fech];

			} else { //program says we want half-automatic repage
				//this runs once and is done
				@synchronized(fecherList) {
					[self setFecherList:information];
				}
				[fecherTable reloadData];			
				[notControls setProgress:nil animated:YES];					
				[self.transender addMemorieWithString:[NSString stringWithFormat:@"{\"ii\":\"FecherListView\", \"ions\":%@, \"ior\":%@}", [repaged_options JSONFragment], [behavior JSONFragment]]];
			}
		} else { //no page param
			@synchronized(fecherList) {
				[self setFecherList:information];
			}
			[fecherTable reloadData];			
			[notControls setProgress:nil animated:YES];	
		}
	} else { //if no information just close progress
		[notControls setProgress:nil animated:YES];	
	}
}

#pragma mark UITableViewDelegate methods
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	CGFloat height = 57.0;
	@synchronized(fecherList) {
//		height = [self cellHeightForIndex:[indexPath row]];
	}
	return height;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	NSInteger n = 0;
	@synchronized(fecherList) {
		n = [fecherList count];
	}
	return n;
}

- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSDictionary* fech = nil;
	@synchronized(fecherList) {
		fech = [fecherList objectAtIndex:[indexPath row]];
	}
	UITableViewCell *cell = (UITableViewCell*)[tv dequeueReusableCellWithIdentifier:@"reusemi"];
	if (cell == nil) {
		/* SDK 2.x
		 */
		cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"reusemi"] autorelease];
		cell.textColor = [UIColor whiteColor];
		cell.lineBreakMode = UILineBreakModeWordWrap;
		/* SDK 3.0
		 cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"reusemi"] autorelease];
		 [cell.textLabel setLineBreakMode:UILineBreakModeWordWrap];
		 [cell.textLabel setNumberOfLines:0];
		 [cell.textLabel setTextColor:[UIColor whiteColor]];
		 [cell.imageView setImage:[transender imageNamed:@"photo_icon.png"]];
		 */
		[cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];		
		[cell setSelectionStyle:UITableViewCellSelectionStyleGray];
	}		
	//update
	//SDK 2.x
	[cell setText:[[fech valueForKey:@"ions"] valueForKey:@"message"]];
	//SDK 3.0
	//[cell.textLabel setText:[[fech valueForKey:@"ions"] valueForKey:@"message"]];
	//[cell.imageView setImage:[Kriya imageWithUrl:[[fech valueForKey:@"ions"] valueForKey:@"background_url"]]];
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[notControls setProgress:@" " animated:YES];

	NSDictionary* fech = nil;
	@synchronized(fecherList) {
		fech = [fecherList objectAtIndex:[indexPath row]];
	}
	//DebugLog(@"selected %@", fech);
	selectedFech = [indexPath row];
	[[NSUserDefaults standardUserDefaults] setInteger:selectedFech forKey:kSelectedFech];

	[self.transender trimMemories];
	[self.transender putMemories:[NSMutableArray arrayWithObject:fech]];
	[self.transender transend];

}

#pragma mark IIController
//this method is repeated on each transend, so must be careful how you implement things
- (void)functionalize {
	if (!listbar) {
		listbar = [[[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 480, 44)] autorelease];
		[listbar setBarStyle:UIBarStyleBlackTranslucent];
		
		UIBarButtonItem *flexi = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease];		
		UIBarButtonItem *fixi = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil] autorelease];		
		[fixi setWidth:44.0];
		title = [[[UIBarButtonItem alloc] initWithTitle:[options valueForKey:@"title"] style:UIBarButtonItemStylePlain target:self action:@selector(refresh:)] autorelease];	
		button = [[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"photo_icon.png"] style:UIBarButtonItemStylePlain target:self action:@selector(refresh:)] autorelease];		
		[listbar setItems:[NSArray arrayWithObjects:fixi, flexi, title, flexi, button, nil]];
		
		littleArrowView = [[LittleArrowView alloc] initWithFrame:CGRectMake(436, 0, 44, 44) image:nil round:10 alpha:1.0];
		[littleArrowView addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventTouchUpInside];
		[self.view addSubview:littleArrowView];
		[self.view insertSubview:listbar belowSubview:littleArrowView];
	}	
	
	if ([options valueForKey:@"background"])
		[self.background setImage:[self.transender imageNamed:[options valueForKey:@"background"]]];
	if ([options valueForKey:@"title"]) {
		[title setTitle:[options valueForKey:@"title"]];
	} else {
		[title setTitle:@""];
	}

	if ([options valueForKey:@"button_icon"]) {
		[button setImage:[transender imageNamed:[options valueForKey:@"button_icon"]]];
	} else {
		[button setImage:nil];
		[button setEnabled:NO];
	}
	if ([options valueForKey:@"icon"])
		[littleArrowView setImage:[transender imageNamed:[options valueForKey:@"icon"]]];
	
	if (!www) {
		www = [[IIWWW alloc] initWithOptions:[options copy]];//make a copy, man
		[www setDelegate:self];
	}
	if (!fecherList) {
		fecherList = [[NSArray alloc] init];
		selectedFech = 0;
	}
	
}

- (void)stopFunctioning {
	[www cancelFech];
	[notControls setProgress:nil animated:YES];	
	//save current state if asked
	if ([options valueForKey:@"restore_key"])
		[[NSUserDefaults standardUserDefaults] setValue:fecherList forKey:[options valueForKey:@"restore_key"]];

	DebugLog(@"#stopFunctioning");
}

- (void)startFunctioning {
	selectedFech = [[NSUserDefaults standardUserDefaults] integerForKey:kSelectedFech];
	if ([options valueForKey:@"restore_key"]&&[[NSUserDefaults standardUserDefaults] valueForKey:[options valueForKey:@"restore_key"]]) {
		[fecherList release];
		fecherList = nil;
		fecherList = [[NSArray alloc] initWithArray:[[NSUserDefaults standardUserDefaults] valueForKey:[options valueForKey:@"restore_key"]]];		
		[fecherTable reloadData];
		//DebugLog(@"START FUNC with restore %@", [options valueForKey:@"restore_key"]);
		//try to reselect
		if (selectedFech>0&&selectedFech<[fecherList count]) {
			NSIndexPath *p = [NSIndexPath indexPathForRow:selectedFech inSection:0];
			[fecherTable selectRowAtIndexPath:p animated:YES scrollPosition:UITableViewScrollPositionMiddle];
		}
	} else {
		[notControls setProgress:@"Pulling ..." animated:YES];
		//[www loadOptions:[options copy]];
		[www fech];
	}
	
	[self becomeFirstResponder];
	DebugLog(@"#startFunctioning");
}


@end
