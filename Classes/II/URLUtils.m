#import "URLUtils.h"

@implementation URLUtils

+ (id) utils {
    return [[[[self class] alloc] init] autorelease];
}

- (NSMutableArray*) tokenize:(NSString*)aString acceptedChars:(NSCharacterSet*)acceptedChars prefix:(NSString*)prefix {
    
    NSMutableArray *back = [NSMutableArray arrayWithCapacity:10];
    
    NSRange startRange = [aString rangeOfString:prefix];
    if (startRange.location == NSNotFound) {
        if ([aString length] > 0) {
            [back addObject:aString];
        }
        return back;
    }
    
    if (startRange.location > 0) {
        [back addObject:[aString substringWithRange:NSMakeRange(0, startRange.location)]];
    }
    
    NSRange searchRange = NSMakeRange(startRange.location + [prefix length], 1);
    while (searchRange.location < [aString length]) {
        NSRange r = [aString rangeOfCharacterFromSet:acceptedChars options:0 range:searchRange];
        if (r.location == NSNotFound) {
            break;
        }
        searchRange.location += r.length;
    }
    
    NSRange targetRange = NSMakeRange(startRange.location, searchRange.location - startRange.location);
    NSString *extracted = [aString substringWithRange:targetRange];
    [back addObject:extracted];
    
    NSArray *subBack = [self tokenize:[aString substringWithRange:
                                       NSMakeRange(targetRange.location + targetRange.length, [aString length] - (targetRange.location + targetRange.length))]
                                     acceptedChars:acceptedChars
                                     prefix:prefix];
    
    [back addObjectsFromArray:subBack];
    
    return back;
}

- (NSMutableArray*) tokenizeByURL:(NSString*)aString {
    
    NSCharacterSet *acceptedCharacterSet = [NSCharacterSet characterSetWithCharactersInString:
                                            @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789;/?:@&=+$,-_.!~*'%"];
    return [self tokenize:aString 
            acceptedChars:acceptedCharacterSet
                   prefix:URLEXTRACTOR_PREFIX_HTTP];
}

- (NSMutableArray*) tokenizeByID:(NSString*)aString {

    NSCharacterSet *acceptedCharacterSet = [NSCharacterSet characterSetWithCharactersInString:
                                            @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_"];

    return [self tokenize:aString 
            acceptedChars:acceptedCharacterSet
                   prefix:URLEXTRACTOR_PREFIX_ID];
    
}

- (NSMutableArray*) tokenizeByAll:(NSString*)aString {
    NSMutableArray *back = [NSMutableArray arrayWithCapacity:100];

    NSMutableArray *tokensById = [[self tokenizeByID:aString] mutableCopy];
    
    int i;
    for (i = 0; i < [tokensById count]; i++) {
        [back addObjectsFromArray:[self tokenizeByURL:[tokensById objectAtIndex:i]]];
    }
	
	[tokensById release];
    
    return back;
}

- (BOOL) isURLToken:(NSString*)token {
    if ([token rangeOfString:URLEXTRACTOR_PREFIX_HTTP].location == 0 && [token length] > [URLEXTRACTOR_PREFIX_HTTP length]) {
        return TRUE;
    }
    return FALSE;
}

- (BOOL) isIDToken:(NSString*)token {
    if ([token rangeOfString:URLEXTRACTOR_PREFIX_ID].location == 0  && [token length] > [URLEXTRACTOR_PREFIX_ID length]) {
        return TRUE;
    }
    return FALSE;
}

- (BOOL) isWhiteSpace:(NSString*)aString {
    unichar space = [@" " characterAtIndex:0];
    int i;
    for (i = 0; i < [aString length]; i++) {
        unichar c = [aString characterAtIndex:i];
        if (c != space) {
            break;
        }
    }
    
    if (i == [aString length]) {
        return TRUE;
    }
    return FALSE;
}

+ (NSString*) encodeHTTP:(NSString*)aString {
	NSString *escaped = (NSString*)CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)aString, NULL, NULL, kCFStringEncodingUTF8);
	NSMutableString *s = [[escaped mutableCopy] autorelease];
	[s replaceOccurrencesOfString:@"&" withString:@"%26" options:0 range:NSMakeRange(0, [s length])];
	[s replaceOccurrencesOfString:@"+" withString:@"%2B" options:0 range:NSMakeRange(0, [s length])];
	[s replaceOccurrencesOfString:@"?" withString:@"%3F" options:0 range:NSMakeRange(0, [s length])];
	[escaped release];
	return s;
}

+ (NSString*) decodeHTTP:(NSString*)aString {
//	NSString *decaped = (NSString*)CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)aString, NULL, NULL, kCFStringEncodingUTF8);
	NSMutableString *s = [[aString mutableCopy] autorelease];
	[s replaceOccurrencesOfString:@"&amp;" withString:@"&" options:0 range:NSMakeRange(0, [s length])];
	[s replaceOccurrencesOfString:@"%2B" withString:@"+" options:0 range:NSMakeRange(0, [s length])];
	[s replaceOccurrencesOfString:@"%3F" withString:@"?" options:0 range:NSMakeRange(0, [s length])];
	//[decaped release];
	return s;
}

@end
