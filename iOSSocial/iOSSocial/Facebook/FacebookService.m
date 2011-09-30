//
//  FacebookService.m
//  iOSSocial
//
//  Created by Christopher White on 9/29/11.
//  Copyright (c) 2011 Mad Races, Inc. All rights reserved.
//

#import "FacebookService.h"
#import "iOSSLog.h"
#import "LocalFacebookUser.h"
#import "iOSSocialServiceOAuth2ProviderConstants.h"

@interface FacebookService ()

@property(nonatomic, readwrite, assign) BOOL primary;
@property(nonatomic, retain)            NSString *theApiKey;
@property(nonatomic, retain)            NSString *theApiSecret;
@property(nonatomic, retain)            NSString *theApiScope;

@end

static FacebookService *facebookService = nil;

@implementation FacebookService

@synthesize name;
@synthesize logoImage;
@synthesize primary;
@synthesize theApiKey;
@synthesize theApiSecret;
@synthesize theApiScope;

+ (id<iOSSocialServiceProtocol>)sharedService;
{
    @synchronized(self) {
        if(facebookService == nil) {
            facebookService = [[super allocWithZone:NULL] init];
            [[iOSSocialServicesStore sharedServiceStore] registerService:facebookService];
        }
    }
    return facebookService;
}

- (id)init
{
    self = [super init];
    if (self) {
    }
    
    return self;
}

- (void)assignOAuthParams:(NSDictionary*)params asPrimary:(BOOL)isPrimary
{
    self.theApiKey = [params objectForKey:kSMOAuth2ClientID];
    self.theApiSecret = [params objectForKey:kSMOAuth2ClientSecret];
    self.theApiScope = [params objectForKey:kSMOAuth2Scope];
    
    self.primary = isPrimary;
}

- (NSString*)name
{
    return @"Facebook";
}

- (NSString*)apiKey
{
    return self.theApiKey;
}

- (NSString*)apiSecret
{
    return self.theApiSecret;
}

- (NSString*)apiScope
{
    return self.theApiScope;
}

- (UIImage*)logoImage
{
    NSURL *logoURL = [[NSBundle mainBundle] URLForResource:@"facebook_trans" withExtension:@"png"];
    UIImage *theLogoImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:logoURL]];
    return theLogoImage;
}

- (id<iOSSocialLocalUserProtocol>)localUser
{
    return [LocalFacebookUser localFacebookUser];
}

- (id<iOSSocialLocalUserProtocol>)localUserWithDictionary:(NSDictionary*)dictionary
{
    LocalFacebookUser *theUser = [[LocalFacebookUser alloc] initWithDictionary:dictionary];
    [LocalFacebookUser setLocalFacebookUser:theUser];
    return theUser;
}

- (id<iOSSocialLocalUserProtocol>)localUserWithUUID:(NSString*)uuid
{
    LocalFacebookUser *theUser = [[LocalFacebookUser alloc] initWithUUID:uuid];
    [LocalFacebookUser setLocalFacebookUser:theUser];
    return theUser;
}

@end
