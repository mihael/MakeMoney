//
//  MoneyTimerViewController.h
//  MakeMoney

#import <UIKit/UIKit.h>
#import "IIController.h"

@interface MoneyTimerViewController : IIController {
	IBOutlet UILabel *money;
	IBOutlet UILabel *currency;
	IBOutlet UISlider *hourly;
	IBOutlet UILabel *hourlyLabel;
	NSTimer *tiktak;
	
	int seconds;
	int costofonehour;
	
}
@property (readonly) IBOutlet UISlider *hourly;

- (IBAction)sliderValueChanged:(id)sender;
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
@end
