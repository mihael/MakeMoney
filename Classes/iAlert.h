@interface iAlert : NSObject <UIAlertViewDelegate> {
}
+ (id)instance;
- (void)alert:(NSString*)title withMessage:(NSString*)message;
@end
