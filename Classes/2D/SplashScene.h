//
//  SplashScene.h
//  MakeMoney
//
#import "cocos2d.h"

@interface SplashScene : CCScene {

}

@end

@interface Layer1 : CCLayer
{
	CCLabel *label1;
	CCLabel *label2;
	CCLabel *label3;
	
	ccTime time1, time2, time3;
}

-(void) step1: (ccTime) dt;
-(void) step2: (ccTime) dt;
-(void) step3: (ccTime) dt;

@end
