//
//  RootViewController.h
//  MakeMoney
//
#import <UIKit/UIKit.h>
#import "IINotControls.h"
#import "IITransenderViewController.h"

@class FlipsideViewController;
@class IINotControls;

@interface RootViewController : UIViewController <IITransenderViewControllerDelegate> {
	IINotControls *notControls;
    UIViewController *mainViewController;
    UIViewController *flipsideViewController;
    UINavigationBar *flipsideNavigationBar;
}

@property (nonatomic, retain) IINotControls *notControls;
@property (nonatomic, retain) UIViewController *mainViewController;
@property (nonatomic, retain) UINavigationBar *flipsideNavigationBar;
@property (nonatomic, retain) UIViewController *flipsideViewController;

- (void)toggleView;
@end
