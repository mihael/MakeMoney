//
//  IIFilter.m
//  MakeMoney
//
#import "IIFilter.h"
#import "JSON.h"

@implementation IIFilter

- (NSString*)filter:(NSString*)information
{
	//override this
	return information; //default filter does not do anything
}

- (NSString*)pageParamName
{
	//override this if you have other param name for paging
	return @"page";
}

- (NSString*)limitParamName
{
	//override this if you have other param name for paging limit
	return @"limit";
}


/*
- (NSString*)pikchur_getPublicTimelineWithPage:(int)page andSize:(int)pageSize {
	
	NSString *body = [NSString stringWithFormat:@"data[api][feeds][type]=timeline&data[api][key]=%@", kAPI_pikchur_api_key]; 
	NSString *url = @"https://api.pikchur.com/api/feeds/json"; 
	if (page<=0) {
		page = 1;
	}
	if (pageSize == 0) {
		pageSize = 5;
	}
	body = [NSString stringWithFormat:@"%@&data[api][feeds][timeline][page]=%d", body, page]; //page param
	if (pageSize < 50 && pageSize > 0) { //API 25 is default
		body = [NSString stringWithFormat:@"%@&data[api][feeds][timeline][limit]=%d", body, pageSize]; //add page parameter if page is not default and more than 0
	}	
	return [NSString stringWithFormat:@"%@%@", url, body];
}
*/

@end
