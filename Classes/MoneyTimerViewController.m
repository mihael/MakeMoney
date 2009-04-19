//
//  MoneyTimerViewController.m
//  MakeMoney
#import "MoneyTimerViewController.h"

@implementation MoneyTimerViewController
@synthesize hourly;
- (void)viewDidLoad {
    [super viewDidLoad];
	NSLog(@"MoneyTimerViewController#viewDidLoad");
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	NSLog(@"MoneyTimerViewController#viewWillAppear");
	[self startik];
}
- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	NSLog(@"MoneyTimerViewController#viewWillDisappear");
	[self endtik];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}


- (void)dealloc {
	//[wiev release];
	if (tiktak) {
		[tiktak invalidate];
		[tiktak release];
	}
    [super dealloc];
}

- (void)startik {
	if (tiktak) {
		[tiktak invalidate];
		[tiktak release];
	}
	seconds = 0; //zapomni si kje točno sem ostal
	costofonehour = pow(10, [hourly value]);
	NSLog(@"STARTIK");// cost %i", costofonehour);
	tiktak = [[NSTimer scheduledTimerWithTimeInterval:1
											   target:self 
											 selector:@selector(taktik:)
											 userInfo:nil
											  repeats:YES] retain];	
}

- (void)endtik {
	if (tiktak) {
		[tiktak invalidate];
		[tiktak release];
	}
}

- (void)taktik:(NSTimer*)t {
	//counter.text = [NSString stringWithFormat:@"%i", t];
	seconds++;
	NSLog(@"taktik %i", seconds);
	[self showMoney];
	[self updateSliderLabel];
}

- (void)showMoney {
	NSLog(@"showMoney cost of one hour: %i seconds: %i money: %f", costofonehour, seconds, ((float)seconds/3600 * (float)costofonehour));
	money.text = [NSString stringWithFormat:@"%i. %f", seconds, ((float)seconds/3600 * (float)costofonehour)];
}

- (void) updateSliderLabel {
	double value = pow(10, [hourly value]);
    hourlyLabel.text = [NSString stringWithFormat:@"%.0f", value];
}

- (IBAction)sliderValueChanged:(id)sender {
	// The distance filter slider is an exponential scale, base 10.
	// Slider returns a value in the range 0.0 to 3.0 (set in Interface Builder).
	// Corresponds to a range of 1 to 1000, exponentially.
	costofonehour = pow(10, hourly.value);
	[self updateSliderLabel];
}

#pragma mark IIController overrides
- (void)stopFunctioning {
	[self endtik];
	NSLog(@"MoneyTimerViewController#stopFunctioning");
}
- (void)startFunctioning {
	[self startik];
	NSLog(@"MoneyTimerViewController#startFunctioning");
}
@end
