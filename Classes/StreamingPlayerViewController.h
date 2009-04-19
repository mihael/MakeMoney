//
//  StreamingPlayerViewController.h
//
#import "IIController.h"
@class AudioStreamer;

@interface StreamingPlayerViewController : IIController
{
	AudioStreamer *streamer;
	IBOutlet UIImageView* background;
}
@property (readwrite, retain) IBOutlet UIImageView* background;

@end

