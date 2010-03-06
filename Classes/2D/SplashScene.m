//
//  SplashScene.m
//  MakeMoney
//
#import "cocos2d.h"
#import "SplashScene.h"

@implementation SplashScene

- (id)init {
	self = [super init];
	if (self != nil) {
		CCSprite * bg = [CCSprite spriteWithFile:@"main.png"];
		[bg setPosition:ccp(240, 160)];
		[self addChild:bg z:0];
		[self addChild:[Layer1 node] z:1];
	}
	return self;
}

@end

@implementation Layer1
-(id) init
{
	[super init];
	
	// timers
	label1 = [CCLabel labelWithString:@"0" fontName:@"Courier" fontSize:32];
	label2 = [CCLabel labelWithString:@"0" fontName:@"Courier" fontSize:32];
	label3 = [CCLabel labelWithString:@"0" fontName:@"Courier" fontSize:32];

	[self schedule: @selector(step1:) interval: 0.5f];
	[self schedule: @selector(step2:) interval:1.0f];
	[self schedule: @selector(step3:) interval: 1.5f];
	
	label1.position = ccp(80,160);
	label2.position = ccp(240,160);
	label3.position = ccp(400,160);
	
	[self addChild:label1];
	[self addChild:label2];
	[self addChild:label3];
	
	// Sprite

	CCSprite *rPad = [CCSprite spriteWithFile:@"icon.png"];
	rPad.position = ccp(240,100);
	[self addChild:rPad];

	CCSprite *lPad = [CCSprite spriteWithFile:@"finger.png"];
	lPad.position = ccp(50,10);
	[self addChild:lPad];
	
	// pause button
	CCMenuItem *item1 = [CCMenuItemFont itemFromString: @"Pause" target:self selector:@selector(pause:)];
	CCMenu *menu = [CCMenu menuWithItems: item1, nil];
	menu.position = ccp(480/2, 270);
	
	[self addChild: menu];
	
	return self;
}

- (void) dealloc
{
	[super dealloc];
}

-(void) pause: (id) sender
{
	[[CCDirector sharedDirector] pause];
	
	// Dialog
	UIAlertView* dialog = [[UIAlertView alloc] init];
	[dialog setDelegate:self];
	[dialog setTitle:@"Game Paused"];
	[dialog setMessage:@"Game paused"];
	[dialog addButtonWithTitle:@"Resume"];
	[dialog show];	
	[dialog release];
}

- (void) alertView:(UIAlertView *)alert clickedButtonAtIndex:(NSInteger)buttonIndex
{	
	[[CCDirector sharedDirector] resume];
}

-(void) step1: (ccTime) delta
{
	//	time1 +=delta;
	time1 +=1;	
	[label1 setString: [NSString stringWithFormat:@"%2.1f", time1] ];
}

-(void) step2: (ccTime) delta
{
	//	time2 +=delta;
	time2 +=1;
	[label2 setString: [NSString stringWithFormat:@"%2.1f", time2] ];
}

-(void) step3: (ccTime) delta
{
	//	time3 +=delta;
	time3 +=1;
	[label3 setString: [NSString stringWithFormat:@"%2.1f", time3] ];
}

@end