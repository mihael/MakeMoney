//
//  iAccelerometerSensor.m
//  MakeMoney
//
#import "iAccelerometerSensor.h"

static iAccelerometerSensor *_sharedInstance;

@interface iAccelerometerSensor(Private)
- (void)accIntervalTimerExpired;
- (void)accIntervalTimerStart;
@end


@implementation iAccelerometerSensor

@synthesize delegate;

+ (iAccelerometerSensor*)instance {
	if (_sharedInstance == nil) {
		_sharedInstance = [[iAccelerometerSensor alloc] init];
	}
	return _sharedInstance;
}

- (id)init {
	if (self = [super init]) {
		[self updateForShakes];
	}
	return self;
}

- (void)dealloc {
	[self accIntervalTimerExpired];
	[delegate release];
	[super dealloc];
}

- (void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration {
	const UIAccelerationValue gthreshold = 1.7;
	const UIAccelerationValue filterFactor = 0.1;
	const CFTimeInterval interval = 0.5;
		
	accAvg[0] = acceleration.x * filterFactor + accAvg[0] * (1.0 - filterFactor);
	accAvg[1] = acceleration.y * filterFactor + accAvg[1] * (1.0 - filterFactor);
	accAvg[2] = acceleration.z * filterFactor + accAvg[2] * (1.0 - filterFactor);
	
	UIAccelerationValue x = acceleration.x - accAvg[0];
	UIAccelerationValue y = acceleration.y - accAvg[1];
	UIAccelerationValue z = acceleration.z - accAvg[2];
	
	UIAccelerationValue g = sqrt(x*x + y*y + z*z);
	
	CFTimeInterval now = CFAbsoluteTimeGetCurrent();
	if (g > gthreshold && now > lastFired + interval) {
		[delegate accelerometerDetected];
		lastFired = now;
	}
}

- (void)updateForShakes {
	DebugLog(@"UPDATE FOR SHAKES");
	//if ([[ikooConfiguration instance] shakeToReload]) {
		[UIAccelerometer sharedAccelerometer].delegate = self;
		[UIAccelerometer sharedAccelerometer].updateInterval = 0.05;
	//} else {
		//[UIAccelerometer sharedAccelerometer].delegate = nil;
		//[UIAccelerometer sharedAccelerometer].updateInterval = 1.0;
	//}
}


@end
