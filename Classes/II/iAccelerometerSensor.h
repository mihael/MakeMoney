//
//  iAccelerometerSensor.h
//  MakeMoney
//
@protocol iAccelerometerSensorDelegate 

- (void)accelerometerDetected;

@end

@interface iAccelerometerSensor : NSObject<UIAccelerometerDelegate> {
	NSObject<iAccelerometerSensorDelegate> *delegate;
	UIAccelerationValue accAvg[3];
	CFTimeInterval lastFired;
}

+ (iAccelerometerSensor*)instance;

- (void)updateForShakes;

@property (readwrite, retain) NSObject<iAccelerometerSensorDelegate> *delegate;

@end
