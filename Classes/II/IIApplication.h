//
//  IIApplication.h
//  MakeMoney
//
@interface IIApplication : NSObject {

}
- (void)apnProviderRegisterDeviceWithToken:(NSData*)deviceToken;
- (void)startup;
- (BOOL)handleLaunchOptions:(NSDictionary*)launchOptions;

@end
