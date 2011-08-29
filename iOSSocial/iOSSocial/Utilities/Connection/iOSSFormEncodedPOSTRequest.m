//
//  iOSSFormEncodedPOSTRequest.m
//  iOSSocial
//
//  Created by Christopher White on 7/20/11.
//  Copyright 2011 Mad Races, Inc. All rights reserved.
//

#import "iOSSFormEncodedPOSTRequest.h"
#import "iOSSLog.h"
//#import "NSString+iOSSURLAdditions.h"

@implementation iOSSFormEncodedPOSTRequest


+ (id)requestWithURL:(NSURL *)url formParameters:(NSDictionary *)params
{
    return nil;
}

- (id)initWithURL:(NSURL *)url formParameters:(NSDictionary *)params
{
    if ((self = [super initWithURL:url])) {
        [self setHTTPMethod:@"POST"];
        [self setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        [self setFormParameters:params]; 
    }
    return self;
}

- (void)setFormParameters:(NSDictionary *)params
{
    /*
    NSStringEncoding enc = NSUTF8StringEncoding; 
    NSMutableString *postBody = [NSMutableString string];
    for (NSString *paramKey in params) {
        if ([paramKey length] > 0) { 
            NSString *value = [params objectForKey:paramKey]; 
            NSString *encodedValue = [value ioss_URLEncodedFormStringUsingEncoding:enc];
            NSUInteger length = [postBody length]; 
            NSString *paramFormat = (length == 0 ? @"%@=%@" : @"&%@=%@"); 
            [postBody appendFormat:paramFormat, paramKey, encodedValue];
        }
    }
    iOSSLog(@"postBody is now %@", postBody); 
    [self setHTTPBody:[postBody dataUsingEncoding:enc]];
    */
}

@end
