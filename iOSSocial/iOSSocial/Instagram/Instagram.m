//
//  Instagram.m
//  InstaBeta
//
//  Created by Christopher White on 7/14/11.
//  Copyright 2011 Mad Races, Inc. All rights reserved.
//

#import "Instagram.h"
#import "iOSSLog.h"

@interface IOSSOAuth2ParserClass : NSObject
// just enough of SBJSON to be able to parse
- (id)objectWithString:(NSString*)repr error:(NSError**)error;
@end

@implementation Instagram

- (id)init
{
    self = [super init];
    if (self) {
    }
    
    return self;
}

+ (NSURL*)authorizeURL:(NSURL*)URL
{
    /*
    NSString *access_token = [NSString stringWithFormat:@"?access_token=%@", auth.accessToken];
    NSURL *url = [NSURL URLWithString:access_token relativeToURL:URL];
    
    return url;
    */
    return nil;
}

+ (id)JSONFromData:(NSData*)data
{
    id obj = nil;
    NSError *error = nil;
    
    Class serializer = NSClassFromString(@"NSJSONSerialization");
    if (serializer) {
        const NSUInteger kOpts = (1UL << 0); // NSJSONReadingMutableContainers
        obj = [serializer JSONObjectWithData:data
                                     options:kOpts
                                       error:&error];
#if DEBUG
        if (error) {
            NSString *str = [[NSString alloc] initWithData:data
                                                   encoding:NSUTF8StringEncoding];
            iOSSLog(@"NSJSONSerialization error %@ parsing %@",
                  error, str);
        }
#endif
        return obj;
    } else {
        // try SBJsonParser or SBJSON
        Class jsonParseClass = NSClassFromString(@"SBJsonParser");
        if (!jsonParseClass) {
            jsonParseClass = NSClassFromString(@"SBJSON");
        }
        if (jsonParseClass) {
            IOSSOAuth2ParserClass *parser = [[jsonParseClass alloc] init];
            NSString *jsonStr = [[NSString alloc] initWithData:data
                                                       encoding:NSUTF8StringEncoding];
            if (jsonStr) {
                obj = [parser objectWithString:jsonStr error:&error];
#if DEBUG
                if (error) {
                    iOSSLog(@"%@ error %@ parsing %@", NSStringFromClass(jsonParseClass),
                          error, jsonStr);
                }
#endif
                return obj;
            }
        }
    }
    return nil;
}

@end
