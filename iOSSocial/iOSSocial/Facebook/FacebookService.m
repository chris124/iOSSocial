/*
 * Copyright 2011 Mad Races, Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import "FacebookService.h"
#import "iOSSLog.h"
#import "LocalFacebookUser.h"
#import "iOSSocialServiceOAuth2ProviderConstants.h"

@interface FacebookService ()

@property(nonatomic, readwrite, assign) BOOL primary;
@property(nonatomic, retain)            NSString *theApiKey;
@property(nonatomic, retain)            NSString *theApiSecret;
@property(nonatomic, retain)            NSString *theApiScope;
@property(nonatomic, retain)            NSString *theURLSchemeSuffix;
@property(nonatomic, readwrite, retain) NSString *keychainItemName;

@end

static FacebookService *facebookService = nil;

@implementation FacebookService

@synthesize name;
@synthesize logoImage;
@synthesize primary;
@synthesize theApiKey;
@synthesize theApiSecret;
@synthesize theApiScope;
@synthesize theURLSchemeSuffix;
@synthesize keychainItemName;

+ (id<iOSSocialServiceProtocol>)sharedService;
{
    @synchronized(self) {
        if(facebookService == nil) {
            facebookService = [[super allocWithZone:NULL] init];
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
    self.theApiKey          = [params objectForKey:kSMOAuth2ClientID];
    self.theApiSecret       = [params objectForKey:kSMOAuth2ClientSecret];
    self.theApiScope        = [params objectForKey:kSMOAuth2Scope];
    self.theURLSchemeSuffix = [params objectForKey:kSMOAuth2URLSchemeSuffix];
    self.keychainItemName   = [params objectForKey:kSMOAuth2KeychainItemName];
    
    self.primary = isPrimary;
    
    [[iOSSocialServicesStore sharedServiceStore] registerService:self];
}

- (NSString*)name
{
    return @"Facebook";
}

- (NSString*)apiKey
{
    return self.theApiKey;
}

- (NSString*)urlSchemeSuffix
{
    return self.theURLSchemeSuffix;
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

- (NSString*)serviceKeychainItemName
{
    return self.keychainItemName;
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

- (id<iOSSocialLocalUserProtocol>)localUserWithIdentifier:(NSString*)identifier
{
    LocalFacebookUser *theUser = [[LocalFacebookUser alloc] initWithIdentifier:identifier];
    [LocalFacebookUser setLocalFacebookUser:theUser];
    return theUser;
}

@end
