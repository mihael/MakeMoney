//
//  IIMusic.h
//  MakeMoney
//
#import "IIMusic.h"
@implementation IIMusic
@synthesize delegate;

static IIMusic* music = nil;

static void Heard (SystemSoundID  SSID, void* myself) {
	AudioServicesRemoveSystemSoundCompletion (SSID);
	if (music.delegate) {
		[music.delegate heardMusic:myself];
	}
}

+ (id)musicWithFile:(NSString *)path {
    if (path) {
        return [[[IIMusic alloc] initWithFile:path] autorelease]; 
    }
    return nil;
}

- (id)initWithFile:(NSString *)path {
    self = [super init];
    
    if (self != nil) {
        NSURL *url = [NSURL fileURLWithPath:path isDirectory:NO];
        
        if (url != nil)  {
            SystemSoundID sID;
            OSStatus error = AudioServicesCreateSystemSoundID((CFURLRef)url, &sID);
			
            if (error == kAudioServicesNoError) {
                musicID = sID;
				AudioServicesAddSystemSoundCompletion (musicID,NULL,NULL,
													   Heard,
													   (void*) self);
				
            } else {
                NSLog(@"Error %d loading sound at path: %@", error, path);
                [self release], self = nil;
            }
        } else {
            NSLog(@"NSURL is nil for path: %@", path);
            [self release], self = nil;
        }
    }
	music = self;
    return self;
}

-(void)dealloc {
    AudioServicesDisposeSystemSoundID(musicID);
    [super dealloc];
}

-(void)listen {
    AudioServicesPlaySystemSound(musicID);
}

-(void)heard {
	AudioServicesDisposeSystemSoundID(musicID);
	if (delegate) {
			[delegate heardMusic:self];
	}	
}
@end
