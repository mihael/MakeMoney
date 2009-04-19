//
//  IIController.h
//  MakeMoney
//
#import <UIKit/UIKit.h>
#import "IITransender.h"

@class IITransender;

@interface IIController : UIViewController {
	NSDictionary* options;
	IITransender* transender; //a reference to core 
}
@property (readwrite, retain) NSDictionary* options;
@property (readwrite, assign) IITransender* transender;

- (void)startFunctioning;
- (void)stopFunctioning;
@end
