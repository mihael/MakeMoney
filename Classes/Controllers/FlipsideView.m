//
//  FlipsideView.m
//  MakeMoney
//
#import "FlipsideView.h"

@implementation FlipsideView


- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        // Initialization code
    }
    return self;
}


- (void)drawRect:(CGRect)rect {
	CGRect b = rect;
    CGContextRef context = UIGraphicsGetCurrentContext();
	CGFloat w = b.size.width;
	CGFloat h = b.size.height;
	CGFloat pad = 2;

	CGContextBeginPath (context);
	CGContextMoveToPoint(context,0, 0);
	CGContextAddLineToPoint(context, w, 0);
	CGContextAddLineToPoint(context, w,h);
	CGContextAddLineToPoint(context, 0, h);
	CGContextClosePath (context);

	CGContextSetFillColorWithColor(context, [UIColor blackColor].CGColor);
	CGContextDrawPath(context, kCGPathFill);
	CGContextFillPath(context);

	CGContextBeginPath (context);
	CGContextMoveToPoint(context, pad, 4*pad);
	CGContextAddArcToPoint(context, pad, pad, 4*pad, pad, 20);
	CGContextAddLineToPoint(context, w-4*pad, pad);
	CGContextAddArcToPoint(context, w-pad, pad, w-pad, 4*pad, 20);

	CGContextAddLineToPoint(context, w-pad,h-pad);
	CGContextAddLineToPoint(context, pad, h-pad);

	CGContextClosePath (context);
	
	CGContextSetFillColorWithColor(context, [UIColor viewFlipsideBackgroundColor].CGColor);
	CGContextDrawPath(context, kCGPathFill);
	CGContextFillPath(context);
	
}


- (void)dealloc {
    [super dealloc];
}


@end
