//
//  FecherListViewController.h
//  MakeMoney
//
#import "IIController.h"
#import "IIWWW.h"

@class IIWWW;

@interface FecherListViewController : IIController <IIWWWDelegate, UITableViewDelegate, UITableViewDataSource> {
	IBOutlet UITableView *fecherTable;
	IBOutlet UIImageView *background;
	IBOutlet UIActivityIndicatorView *indica;
	IIWWW *www;
	NSArray *fecherList;
	NSUInteger selectedFech;
}
@property (readonly) IBOutlet UIImageView *background;
@property (readwrite, retain) NSArray *fecherList;

- (void)feched:(id)information;
- (void)notFeched:(NSString*)err;
@end
