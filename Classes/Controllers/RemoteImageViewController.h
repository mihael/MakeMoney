//
//  RemoteImageViewController.h
//  MakeMoney
//
#import <UIKit/UIKit.h>
#import "AssetRepository.h"
#import "IIController.h"

@interface RemoteImageViewController : IIController <AssetDownloadDelegate>
{
	IBOutlet UIImageView* imageView;
	IBOutlet UIActivityIndicatorView *indica;
	UIImage *image;
}
@property (readonly) IBOutlet UIImageView* imageView;
@property (readonly) IBOutlet UIActivityIndicatorView *indica;
@property (readwrite, retain) UIImage *image;

- (void)loadRemoteImage;
- (void)showImage:(UIImage*)img;

@end
