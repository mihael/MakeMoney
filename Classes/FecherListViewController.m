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


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)dealloc {
	[www release];
	www = nil;
    [super dealloc];
}

#pragma mark IIWWWDelegate
- (void)notFeched:(NSString*)err
{
	DebugLog(@"#notFeched %@ : %@", [self.options valueForKey:@"url"], err);
	[indica stopAnimating];
}

- (void)feched:(id)information
{
	[indica stopAnimating];
	//[self.transender spot]; //rewind memory spots
	//[self.transender rememberMemories:listing]; //replaces transender mem
	//[self.transender trimMemoriesBeyondSpot:[self.transender currentSpot]];
	//[self.transender putMemories:information]; //inserts into transender mem
	//[fecherList release];
	[self setFecherList:information];
	
	if ([options valueForKey:@"page"]) { //program says we want automatic repage
		NSUInteger page = [[options valueForKey:@"page"] intValue];
		int page_plus = [[options valueForKey:@"page_plus"] intValue];
		if (page_plus<=0) {
			page_plus = 1;
		}
		NSUInteger nextPage = page + page_plus;	
		NSMutableDictionary *repaged_options = [NSMutableDictionary dictionaryWithDictionary:options];
		[repaged_options setValue:[NSString stringWithFormat:@"%i",nextPage] forKey:@"page"];	
		
		[self.transender addMemorieWithString:[NSString stringWithFormat:@"{\"ii\":\"FecherListView\", \"ions\":%@, \"ior\":%@}", [repaged_options JSONFragment], [behavior JSONFragment]]];
	}
	
	
	//update fecherList table
	[fecherTable reloadData];
	//scroll to remembered position	
	NSUInteger ii[2] = {0, selectedFech};
	NSIndexPath* iP = [NSIndexPath indexPathWithIndexes:ii length:2];
	//[fecherTable scrollToRowAtIndexPath:iP atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    [fecherTable selectRowAtIndexPath:iP animated:YES scrollPosition:UITableViewScrollPositionMiddle];
}

#pragma mark IIController
- (void)functionalize {
	if ([options valueForKey:@"background"])
		[self.background setImage:[self.transender imageNamed:[options valueForKey:@"background"]]];

	if (www)
		[www release];
	www = [[IIWWW alloc] initWithOptions:options];
	[www setDelegate:self];
	fecherList = [[NSArray alloc] init];
	selectedFech = 0;
	selectedFech = [[NSUserDefaults standardUserDefaults] integerForKey:kSelectedFech];
}

- (void)stopFunctioning {
	//DebugLog(@"#stopFunctioning");
}

- (void)startFunctioning {
	//DebugLog(@"#startFunctioning");
	[indica startAnimating];
	[www fech];
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
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"reusemi"] autorelease];
		[cell.textLabel setLineBreakMode:UILineBreakModeWordWrap];
		[cell.textLabel setNumberOfLines:0];
//		[cell.textLabel setMinimumFontSize:13.0];
		[cell. textLabel setTextColor:[UIColor whiteColor]];
	}		
	//update
	[cell.textLabel setText:[[fech valueForKey:@"ions"] valueForKey:@"message"]];
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSDictionary* fech = nil;
	@synchronized(fecherList) {
		fech = [fecherList objectAtIndex:[indexPath row]];
	}
	DebugLog(@"selected %@", fech);
	selectedFech = [indexPath row];
	[[NSUserDefaults standardUserDefaults] setInteger:selectedFech forKey:kSelectedFech];

	[self.transender trimMemories];
	[self.transender putMemories:[NSMutableArray arrayWithObject:fech]];
	[self.transender transend];
}


@end
