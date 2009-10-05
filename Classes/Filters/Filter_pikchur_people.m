//
//  Filter_pikchur_people.m
//  MakeMoney
//
#import "Filter_pikchur_people.h"

@implementation Filter_pikchur_people

- (NSString*)pageParamName
{
	return @"data[api][feeds][page]";
}

- (NSString*)limitParamName
{
	return @"data[api][feeds][limit]";
}

@end
