//
//  MakeMoneyAppDelegate.h
//  MakeMoney
//
#ifdef TEST_MODE
#define APP_SERVER_URL @"http://localhost:3000"
#else
#define APP_SERVER_URL @"http://kitschmaster.com"
#endif
#define APP_TITLE @"MakeMoney"
#define APP_ID @"5"
#define APP_WELCOME_KICH @"435"
#define PRICE 0.99
#define IRS 0.7
#define PRAYER @"Serve."
#define MANTRA @"Make Money."

#import "IIApplication.h"
@class RootViewController;

@interface MakeMoneyAppDelegate : IIApplication <UIApplicationDelegate> {
    UIWindow *window;
    RootViewController *rootViewController;
	NSDictionary *stage;
}

@property (nonatomic, readonly) IBOutlet RootViewController *rootViewController;
@property (nonatomic, readonly) IBOutlet UIWindow *window;
@property (nonatomic, readwrite, retain) NSDictionary *stage;

+ (NSString*) version;
+ (MakeMoneyAppDelegate*) app;

@end

