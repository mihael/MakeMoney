//
//  FechSomeViewController.h
//  MakeMoney
//
//  Created by mihael on 4/18/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IIController.h"
#import "IIWWW.h"

@class IIWWW;

@interface FechSomeViewController : IIController <IIWWWDelegate> {
	IBOutlet UIButton* button;
	IBOutlet UIProgressView* progress;
	IIWWW *www;
}
- (IBAction)buttonTouched:(id)sender;

@end
