//
//  IIWindow.h
//  MakeMoney
//

@protocol IIWindowDelegate
- (void)didTapObservedView:(id)tap;
@end

@interface IIWindow : UIWindow {
    UIView *observedView;
    id <IIWindowDelegate> observer;
}

@property (nonatomic, retain) UIView *observedView;
@property (nonatomic, assign) id <IIWindowDelegate> observer;

@end

