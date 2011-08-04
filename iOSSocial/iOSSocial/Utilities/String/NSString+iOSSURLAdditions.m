//
//  NSString+iOSSURLAdditions.m
//  iOSSocial
//
//  Created by Christopher White on 7/20/11.
//  Copyright 2011 Mad Races, Inc. All rights reserved.
//

#import "NSString+iOSSURLAdditions.h"

@implementation NSString (iOSSURLAdditions)

- (NSString *)ioss_URLEncodedFormStringUsingEncoding:(NSStringEncoding)enc
{
    NSString *escapedStringWithSpaces = [self ioss_percentEscapedStringWithEncoding:enc
                                                               additionalCharacters:@"&=+" ignoredCharacters:nil];
    return escapedStringWithSpaces;
}

- (NSString *)ioss_percentEscapedStringWithEncoding:(NSStringEncoding)enc 
                               additionalCharacters:(NSString *)add
                                  ignoredCharacters:(NSString *)ignore
{
    CFStringEncoding convertedEncoding = CFStringConvertNSStringEncodingToEncoding(enc); 
    return (__bridge NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (__bridge CFStringRef)self, (__bridge CFStringRef)ignore, (__bridge CFStringRef)add, convertedEncoding);
}

@end
