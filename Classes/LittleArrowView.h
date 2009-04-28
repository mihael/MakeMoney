//
//  LittleArrowView.h
//  ikoo
//
//  Created by Mihael on 1/5/09.
//  Copyright 2009 galaktim. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface LittleArrowView : UIButton {
	CGImageRef imageRef;
	CGFloat roundSize;
	CGFloat alpha;
}
- (id)initWithFrame:(CGRect)rect image:(UIImage*)image round:(CGFloat)r alpha:(CGFloat)a;
- (void)setImage:(UIImage*)image;
- (void)setRound:(CGFloat)r;
- (void)setAlpha:(CGFloat)a;

@end
