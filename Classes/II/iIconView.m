//
//  iIconView.m
//  MakeMoney
//
#import "iIconView.h"
#import "ASIHTTPRequest.h"
#define kNotificationName @"iIconViewImageAvailable"

@implementation iIconView

- (id)initWithFrame:(CGRect)rect image:(UIImage*)image round:(CGFloat)r alpha:(CGFloat)a {
	if (self = [super initWithFrame:rect]) {		
		self.backgroundColor = [UIColor clearColor];
		[self setAlpha:a];
		[self setRound:r];
		[self setImage:image];
		observing = NO;
	}
	return self;
}

- (id)initWithFrame:(CGRect)rect imageUrl:(NSString*)url round:(CGFloat)r alpha:(CGFloat)a {
	if (self = [super initWithFrame:rect]) {		
		self.backgroundColor = [UIColor clearColor];
		[self setAlpha:a];
		[self setRound:r];
		imageUrl = url;
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(imageUrlAvailable:) name:kNotificationName object:nil];
		observing = YES;
		[self fetchImage];
	}
	return self;
}

- (float)toRadians:(float)deg
{
    return deg * 3.14/180.0;
}

- (void)setAlpha:(CGFloat)a {
	alpha = a;
}

- (void)setRound:(CGFloat)r {
	roundSize = r;
}

- (void)imageUrlAvailable:(NSNotification *)notification {
	//DLog(@"iIconView#imageUrlAvailable %@", notification);
	if (observing) {
		if ([[notification object] isKindOfClass:[NSString class]]) {
			if ([(NSString*)[notification object] isEqualToString:imageUrl]) {
				[self setImage:[Kriya imageWithUrl:imageUrl feches:NO]];
				[self setNeedsDisplay];
			}
		}
	}
}

- (void)setImageUrl:(NSString*)image_url {
	if (imageUrl)
		[imageUrl release];
	imageUrl = [image_url copy];
	if (!observing)
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(imageUrlAvailable:) name:kNotificationName object:nil];
	[self fetchImage];
}

- (void)setImage:(UIImage*)image {
	if (image) {
		if (imageRef) {
			CGImageRelease(imageRef);
		}
		imageRef = CGImageRetain([image CGImage]);
		[super setNeedsDisplay];
		observing = NO;
	}
}

- (void)fetchImage
{
	UIImage *icon = [Kriya imageWithUrl:imageUrl feches:NO];
	if (icon) { //image is cached
		//DLog(@"iIconView#fetchImage from cache")
		[self setImage:icon];
		[self setNeedsDisplay];
	} else { //fech anew
		//DLog(@"iIconView#fetchImage from web")
		[Kriya imageWithUrl:imageUrl delegate:self finished:@selector(fetchImageFinished:) failed:@selector(fetchImageFailed:)];
	}
}

- (void)fetchImageFinished:(id)response 
{
	if ([response isKindOfClass:[ASIHTTPRequest class]]){
		//just cache it
		[Kriya imageWithInMemoryImage:[UIImage imageWithData:[response responseData]] forUrl:[[response url] absoluteString]];
		//todo notify about this, whoever wants to know
		NSNotification *n = [NSNotification notificationWithName:kNotificationName object:[[response url] absoluteString]];
		[[NSNotificationCenter defaultCenter] postNotification:n];
	}
	//DLog(@"iconWithUrlFinished");
}

- (void)fetchImageFailed:(id)response 
{
	DLog(@"fetchImageFailed");
}

- (void)drawRect:(CGRect)rect {
	if (roundSize<=0)
		roundSize = 5;
	if (alpha<=0)
		alpha = 1.0;
	
	if (imageRef) {
		CGRect b = rect;
		CGContextRef context = UIGraphicsGetCurrentContext();
		
		//set alpha
		CGContextSetAlpha(context, alpha);
		
		// flip the coordinate system to avoid upside-down image drawing
		CGContextTranslateCTM(context, 0.0, b.size.height);
		CGContextScaleCTM(context, 1.0, -1.0);
		
		CGFloat w = b.size.width;
		CGFloat h = b.size.height;
		
		// setup rounded-rect clip
		CGContextBeginPath (context);
		CGContextMoveToPoint(context,w/2, 0);
		//CGContextAddLineToPoint(context, w, 0);
		CGContextAddArcToPoint(context, w, 0, w, h/2, roundSize);
		//CGContextAddLineToPoint(context, w,h);
		CGContextAddArcToPoint(context, w, h, w/2, h, roundSize);
		//CGContextAddLineToPoint(context, w/2, h);
		
		CGContextAddArcToPoint(context, 0, h, 0, h/2, roundSize);
		CGContextAddArcToPoint(context, 0, 0, w/2, 0, roundSize);
		CGContextClosePath (context);
		CGContextClip (context);
		
		// draw image with rounded-rect clip
		CGContextDrawImage (context, b, imageRef);
		/*	
		 // outline 
		 CGContextSetLineWidth(context, 2.f);
		 CGContextSetRGBStrokeColor(context, 0.5f, 0.5f, 0.5f, 0.2f);
		 CGContextBeginPath (context);
		 CGContextMoveToPoint(context,w/2, 0);
		 CGContextAddArcToPoint(context, w, 0, w, h/2, roundSize);
		 CGContextAddArcToPoint(context, w, h, w/2, h, roundSize);
		 CGContextAddArcToPoint(context, 0, h, 0, h/2, roundSize);
		 CGContextAddArcToPoint(context, 0, 0, w/2, 0, roundSize);
		 CGContextClosePath(context);
		 CGContextStrokePath(context);*/
	}
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:kNotificationName object:nil];
	CGImageRelease(imageRef);
	[super dealloc];
}


@end
