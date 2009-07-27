//
//  IIMusic.h
//  MakeMoney
//
#import <AudioToolbox/AudioServices.h>
@protocol IIMusicDelegate
  - (void)heardMusic:(id)sender;
@end

@interface IIMusic : NSObject {
    id <IIMusicDelegate> delegate;
    SystemSoundID musicID;
}
@property (nonatomic, assign) id <IIMusicDelegate> delegate;
+ (id)musicWithFile:(NSString *)path;
- (id)initWithFile:(NSString *)path;
- (void)listen;
- (void)heard;

@end
