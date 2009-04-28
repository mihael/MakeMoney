//
//  LittleArrowView.m
//  ikoo
//
//  Created by Mihael on 1/5/09.
//  Copyright 2009 galaktim. All rights reserved.
//

#import "LittleArrowView.h"


@implementation LittleArrowView


- (id)initWithFrame:(CGRect)rect image:(UIImage*)image round:(CGFloat)r alpha:(CGFloat)a {
	if (self = [super initWithFrame:rect]) {		
		self.backgroundColor = [UIColor clearColor];
		[self setAlpha:a];
		[self setRound:r];
		[self setImage:image];
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

- (void)setImage:(UIImage*)image {
	if (image) {
		if (imageRef) {
			CGImageRelease(imageRef);
		}
		imageRef = CGImageRetain([image CGImage]);
		[super setNeedsDisplay];
	}
}

- (void)drawRect:(CGRect)rect {
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
	CGContextAddLineToPoint(context, w, 0);//CGContextAddArcToPoint(context, w, 0, w, h/2, roundSize);
	CGContextAddLineToPoint(context, w,h);//CGContextAddArcToPoint(context, w, h, w/2, h, roundSize);
	CGContextAddLineToPoint(context, w/2, h);
	
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

- (void)dealloc {
	CGImageRelease(imageRef);
	[super dealloc];
}

@end
