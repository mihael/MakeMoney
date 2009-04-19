//
//  MakeMoneyAppDelegate.h
//  MakeMoney
//
#define PRAYER @"Serve."
#define MANTRA @"Make Money."
#define APP_TITLE @"MakeMoney"
#define APP_URL @"202"
#define APP_SUPPORT_URL @"5"
#define PRICE 0.99
#define IRS 0.7

#import <UIKit/UIKit.h>
@class RootViewController;

@interface MakeMoneyAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    RootViewController *rootViewController;
	NSDictionary *stage;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet RootViewController *rootViewController;
@property (readwrite, retain) NSDictionary *stage;

+ (NSString*) version;
+ (MakeMoneyAppDelegate*) app;

@end

