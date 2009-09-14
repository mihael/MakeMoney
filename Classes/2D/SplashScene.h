//
//  SplashScene.h
//  MakeMoney
//
//  Created by mihael on 9/10/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//
#import "cocos2d.h"

@interface SplashScene : Scene {

}

@end

@interface Layer1 : Layer
{
	Label *label1;
	Label *label2;
	Label *label3;
	
	ccTime time1, time2, time3;
}

-(void) step1: (ccTime) dt;
-(void) step2: (ccTime) dt;
-(void) step3: (ccTime) dt;

@end
