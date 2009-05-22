//
//  iAnnotationView.m
//  MakeMoney
//
#import "iAnnotationView.h"
#import <MapKit/MapKit.h>

@implementation iAnnotationView

- (id)initWithAnnotation:(id <MKAnnotation>)annotation reuseIdentifier:(NSString*)identifier 
{
	self = [super initWithAnnotation:annotation reuseIdentifier:identifier];
	if (self != nil) {
		[self setImage:[UIImage imageNamed:@"kepo.png"]];
	}
	return self;
}

@end
