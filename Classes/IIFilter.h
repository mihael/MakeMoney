//
//  IIFilter.h
//  MakeMoney
//
//this class should be overriden if you want to filter IWWW feches
@interface IIFilter : NSObject {
}
- (NSString*)filter:(NSString*)information;
- (NSString*)pageParamName;
- (NSString*)limitParamName;
@end
