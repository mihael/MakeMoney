//
//  UIApplication-Network.m
//

#import "UIApplication-Network.h"

@implementation UIApplication (NetworkExtensions)


#define ReachableViaWiFiNetwork          2
#define ReachableDirectWWAN               (1 << 18)
// fast wi-fi connection
+(BOOL)hasActiveWiFiConnection
{
	SCNetworkReachabilityFlags     flags;
	SCNetworkReachabilityRef     reachabilityRef;
	BOOL                              gotFlags;
    
	reachabilityRef = SCNetworkReachabilityCreateWithName(CFAllocatorGetDefault(),[@"www.apple.com" UTF8String]);
	
	gotFlags = SCNetworkReachabilityGetFlags(reachabilityRef, &flags);
	CFRelease(reachabilityRef);
    
	if (!gotFlags)
	{
		return NO;
	}
    
	if( flags & ReachableDirectWWAN )
	{
		return NO;
	}
    
	if( flags & ReachableViaWiFiNetwork )
	{
		return YES;
	}
    
	return NO;
}

// any type of internet connection (edge, 3g, wi-fi)
+(BOOL)hasNetworkConnection;
{
    SCNetworkReachabilityFlags     flags;
    SCNetworkReachabilityRef     reachabilityRef;
    BOOL                              gotFlags;
	
    reachabilityRef     = SCNetworkReachabilityCreateWithName(CFAllocatorGetDefault(), [@"www.apple.com" UTF8String]);
    gotFlags          = SCNetworkReachabilityGetFlags(reachabilityRef, &flags);
    CFRelease(reachabilityRef);
	
    if (!gotFlags || (flags == 0) )
    {
        return NO;
    }
	
    return YES;
}

@end