//
//  FecherListViewController.h
//  MakeMoney
//
#import "IIController.h"
#import "IIWWW.h"
#import "LittleArrowView.h"

#define kSavedFecherList @"savedFecherList"

@class IIWWW;
@class LittleArrowView;

@interface FecherListViewController : IIController <IIWWWDelegate, UITableViewDelegate, UITableViewDataSource> {
	IBOutlet UITableView *fecherTable;
	IBOutlet UIImageView *background;
	UIToolbar *listbar;
	UIBarButtonItem *title;
	UIBarButtonItem *button;
	LittleArrowView *littleArrowView;
	IIWWW *www;
	NSArray *fecherList;
	NSUInteger selectedFech;
}
@property (readonly) IBOutlet UIImageView *background;
@property (readwrite, retain) NSArray *fecherList;

- (IBAction)refresh:(id)sender;

- (void)feched:(id)information;
- (void)notFeched:(NSString*)err;
@end
