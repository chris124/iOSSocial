//
//  Twitter.m
//  iOSSocial
//
//  Created by Christopher White on 7/22/11.
//  Copyright 2011 Mad Races, Inc. All rights reserved.
//

#import "Twitter.h"
#import "iOSSLog.h"
#import "LocalTwitterUser.h"

@interface IOSSOAuthParserClass : NSObject
// just enough of SBJSON to be able to parse
- (id)objectWithString:(NSString*)repr error:(NSError**)error;
@end

static Twitter *twitterService = nil;

@implementation Twitter

@synthesize name;
@synthesize logoImage;

+ (id<iOSSocialServiceProtocol>)sharedService;
{
    @synchronized(self) {
        if(twitterService == nil) {
            twitterService = [[super allocWithZone:NULL] init];
            [[iOSSocialServicesStore sharedServiceStore] registerService:twitterService];
        }
    }
    return twitterService;
}

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (NSString*)name
{
    return @"Twitter";
}

- (UIImage*)logoImage
{
    NSURL *logoURL = [[NSBundle mainBundle] URLForResource:@"twitter-logo" withExtension:@"png"];
    UIImage *theLogoImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:logoURL]];
    return theLogoImage;
}

- (id<iOSSocialLocalUserProtocol>)localUser
{
    return [[LocalTwitterUser alloc] init];
}

- (id<iOSSocialLocalUserProtocol>)localUserWithUUID:(NSString*)uuid
{
    return [[LocalTwitterUser alloc] initWithUUID:uuid];
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
            //NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            //iOSSLog(@"NSJSONSerialization error %@ parsing %@", error, str);
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
            IOSSOAuthParserClass *parser = [[jsonParseClass alloc] init];
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
