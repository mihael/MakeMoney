//
//  IIController.m
//  MakeMoney
//
#import "IIController.h"

@implementation IIController
@synthesize transender, options, notControls, behavior;

//THIS IS CALLED ON EVERY VIEW TRANSEND - 
//something like re-init, since transender can reuse views, they need to be re-initialized.
- (void)functionalize 
{
	//write this in subclass
}

//code you implement here should start some functions or enable something after transending
- (void)startFunctioning 
{
	//write this in subclass
}

//code you implement here should stop some functions or denable something 
- (void)stopFunctioning 
{
	//write this in subclass
}

//persist some controller needed object beetween startups
- (void)persistObject:(id)o
{
	if ([options valueForKey:@"restore_key"]&&o!=nil) {
		[[NSUserDefaults standardUserDefaults] setObject:o forKey:[options valueForKey:@"restore_key"]];
		[[NSUserDefaults standardUserDefaults] synchronize];
	}
}

//load some controller needed object beetween startups
- (id)persistedObject 
{
	if ([options valueForKey:@"restore_key"]) {
		return [[NSUserDefaults standardUserDefaults] objectForKey:[options valueForKey:@"restore_key"]];
	}
	return nil;
}

//return transend format - or how to call this IIControler subclass from program.json 
//this is useful for inserts in filtering
+ (NSString*)transendFormat
{
	//implement this in subclass, else you get this
	return @"{\"ii\":\"message\", \"ions\":{\"message\":\"%@\", \"background\":\"%@\"}, %@},";
}


//not needed to implement in subclass
- (void)viewDidLoad {
    [super viewDidLoad];
	[self functionalize];
}

//not needed to implement in subclass
- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	[self.transender meditate];
	[self.notControls lightUp];
	[[iAlert instance] alert:[NSString stringWithFormat:@"Received Memory Warning in %@", [self class]] withMessage:@"Good luck!"];
}

@end
