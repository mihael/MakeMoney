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
}
@property (readonly) IBOutlet UIImageView* imageView;
@property (readonly) IBOutlet UIActivityIndicatorView *indica;

@end
