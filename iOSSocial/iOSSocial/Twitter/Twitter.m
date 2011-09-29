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


@interface Twitter ()

@property(nonatomic, readwrite, assign)  BOOL primary;

@end

static Twitter *twitterService = nil;

@implementation Twitter

@synthesize name;
@synthesize logoImage;
@synthesize primary;

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

- (void)assignOAuthParams:(NSDictionary*)params asPrimary:(BOOL)isPrimary
{
    [super assignOAuthParams:params];
    
    self.primary = isPrimary;
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

- (id<iOSSocialLocalUserProtocol>)localUserWithDictionary:(NSDictionary*)dictionary
{
    LocalTwitterUser *theUser = [[LocalTwitterUser alloc] initWithDictionary:dictionary];
    return theUser;
}

- (id<iOSSocialLocalUserProtocol>)localUserWithUUID:(NSString*)uuid
{
    return [[LocalTwitterUser alloc] initWithUUID:uuid];
}

@end
