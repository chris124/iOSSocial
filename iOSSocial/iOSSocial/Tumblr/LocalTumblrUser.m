//
//  LocalTumblrUser.m
//  iOSSocial
//
//  Created by Christopher White on 7/22/11.
//  Copyright 2011 Mad Races, Inc. All rights reserved.
//

#import "LocalTumblrUser.h"
#import "Tumblr.h"
#import "TumblrUser+Private.h"
#import "iOSSRequest.h"
#import "GTMOAuthAuthentication+Additions.h"
#import "iOSSLog.h"

NSString *const iOSSDefaultsKeyTumblrUserDictionary    = @"ioss_TumblrUserDictionary";

static LocalTumblrUser *localTumblrUser = nil;

@interface LocalTumblrUser () 

@property(nonatomic, copy)      TumblrAuthenticationHandler authenticationHandler;
@property(nonatomic, retain)    GTMOAuthAuthenticationWithAdditions *auth;
@property(nonatomic, retain)    NSString *keychainItemName;
@property(nonatomic, readwrite, retain)    NSString *identifier;

@end

@implementation LocalTumblrUser

@synthesize authenticated;
@synthesize authenticationHandler;
@synthesize username;
@synthesize servicename;
@synthesize auth;
@synthesize keychainItemName;
@synthesize identifier;

+ (LocalTumblrUser *)localTumblrUser
{
    @synchronized(self) {
        if(localTumblrUser == nil)
            localTumblrUser = [[super allocWithZone:NULL] init];
    }
    return localTumblrUser;
}

+ (id<iOSSocialLocalUserProtocol>)localUser
{
    @synchronized(self) {
        if(localTumblrUser == nil)
            localTumblrUser = [[super allocWithZone:NULL] init];
    }
    return localTumblrUser;
}

- (NSDictionary *)ioss_TumblrUserDictionary 
{ 
    return [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@-%@", iOSSDefaultsKeyTumblrUserDictionary, self.identifier]];
}

- (void)ioss_setTumblrUserDictionary:(NSDictionary *)theUserDictionary 
{ 
    [[NSUserDefaults standardUserDefaults] setObject:theUserDictionary forKey:[NSString stringWithFormat:@"%@-%@", iOSSDefaultsKeyTumblrUserDictionary, self.identifier]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)commonInit:(NSString*)theIdentifier
{
    if (theIdentifier) {
        self.identifier = theIdentifier;
    } else {
        CFUUIDRef uuid = CFUUIDCreate(kCFAllocatorDefault);
        CFStringRef uuidStr = CFUUIDCreateString(kCFAllocatorDefault, uuid);
        self.identifier = (__bridge NSString *)uuidStr;
        CFRelease(uuidStr);
        CFRelease(uuid);
    }
    
    
    self.keychainItemName = [NSString stringWithFormat:@"%@-%@", [[Tumblr sharedService] serviceKeychainItemName], self.identifier];
    self.auth = [[Tumblr sharedService] checkAuthenticationForKeychainItemName:self.keychainItemName];
    
    // Initialization code here.
    NSDictionary *localUserDictionary = [self ioss_TumblrUserDictionary];
    if (localUserDictionary) {
        self.userDictionary = localUserDictionary;
    }
}

- (void)reset
{
    self.auth = nil;
    self.identifier = nil;
    self.keychainItemName = nil;
    self.userDictionary = nil;
}

- (id)init
{
    self = [super init];
    if (self) {
        [self commonInit:nil];
    }
    
    return self;
}

- (id)initWithDictionary:(NSDictionary*)dictionary
{
    self = [self init];
    if (self) {
        //set the local user dictionary based on params that have been sent in
        self.auth.accessToken = [dictionary objectForKey:@"access_token"];
        self.auth.tokenSecret = [dictionary objectForKey:@"access_token_secret"];
        NSMutableDictionary *localUserDictionary = [NSMutableDictionary dictionary];
        [localUserDictionary setObject:[dictionary objectForKey:@"userId"] forKey:@"id"];
        [localUserDictionary setObject:[dictionary objectForKey:@"username"] forKey:@"username"];
        self.userDictionary = localUserDictionary;
    }
    return self;
}

- (id)initWithIdentifier:(NSString*)theIdentifier
{
    self = [super init];
    if (self) {
        [self commonInit:theIdentifier];
    }
    
    return self;
}

- (void)setUserDictionary:(NSDictionary *)theUserDictionary
{
    if (theUserDictionary) {
        [super setUserDictionary:theUserDictionary];
        
        [self ioss_setTumblrUserDictionary:theUserDictionary];
    } else {
        iOSSLog(@"meh: no user dictionary");
    }
}

- (BOOL)isAuthenticated
{
    if (NO == self.auth.canAuthorize)
        return NO;
    return YES;
}

- (void)fetchLocalUserDataWithCompletionHandler:(FetchUserDataHandler)completionHandler
{
    self.fetchUserDataHandler = completionHandler;

    NSString *urlString = [NSString stringWithFormat:@"http://api.tumblr.com/v2/user/info"];
    
    NSURL *url = [NSURL URLWithString:urlString];

    iOSSRequest *request = [[iOSSRequest alloc] initWithURL:url  
                                                 parameters:nil 
                                              requestMethod:iOSSRequestMethodPOST];
    
    NSMutableDictionary *oauthParams = [NSMutableDictionary dictionary];
    [oauthParams setObject:[[Tumblr sharedService] apiKey] forKey:kASIOAuthConsumerKey];
    [oauthParams setObject:[[Tumblr sharedService] apiSecret] forKey:kASIOAuthConsumerSecret];
    [oauthParams setObject:[self oAuthAccessToken] forKey:kASIOAuthTokenKey];
    [oauthParams setObject:kASIOAuthSignatureMethodHMAC_SHA1 forKey:kASIOAuthSignatureMethodKey];
    [oauthParams setObject:@"1.0" forKey:kASIOAuthVersionKey];
    [oauthParams setObject:self.auth.tokenSecret forKey:kASIOAuthTokenSecretKey];
    
    request.oauth_params = oauthParams;

    [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        if (error) {
            if (self.fetchUserDataHandler) {
                self.fetchUserDataHandler(error);
                self.fetchUserDataHandler = nil;
            }
        } else {
            NSDictionary *dictionary = [Tumblr JSONFromData:responseData];
            self.userDictionary = dictionary;
            
            if (self.fetchUserDataHandler) {
                self.fetchUserDataHandler(nil);
                self.fetchUserDataHandler = nil;
            }
        }
    }];
}

- (void)authenticateFromViewController:(UIViewController*)vc 
                 withCompletionHandler:(AuthenticationHandler)completionHandler;
{
    self.authenticationHandler = completionHandler;
    
    //cwnote: also see if permissions have changed!!!
    if (NO == [self isAuthenticated]) {
        
        if (nil == self.auth) {
            [self commonInit:nil];
        }

        [[Tumblr sharedService] authorizeFromViewController:vc 
                                                     forAuth:self.auth 
                                         andKeychainItemName:self.keychainItemName 
                                             andCookieDomain:@"tumblr.com" 
                                       withCompletionHandler:^(GTMOAuthAuthentication *theAuth, NSDictionary *userInfo, NSError *error) {
            self.auth = (GTMOAuthAuthenticationWithAdditions*)theAuth;
            if (error) {
                if (self.authenticationHandler) {
                    self.authenticationHandler(error);
                    self.authenticationHandler = nil;
                }
            } else {
                if (userInfo) {
                    NSDictionary *user = [userInfo objectForKey:@"user"];
                    self.userDictionary = user;
                }

                [self fetchLocalUserDataWithCompletionHandler:^(NSError *error) {
                    if (self.authenticationHandler) {
                        self.authenticationHandler(error);
                        self.authenticationHandler = nil;
                    }
                }];
            }
        }];
    } else {
        [self fetchLocalUserDataWithCompletionHandler:^(NSError *error) {
            if (!error) {
                //
            }
            
            if (self.authenticationHandler) {
                self.authenticationHandler(error);
                self.authenticationHandler = nil;
            }
        }];
    }
}

- (NSString*)oAuthAccessToken
{
    return self.auth.accessToken;
}

- (NSString*)oAuthAccessTokenSecret
{
    return self.auth.accessToken;
}

- (NSTimeInterval)oAuthAccessTokenExpirationDate
{
    return 0.0;
}

- (void)logout
{
    [[Tumblr sharedService] logout:self.auth forKeychainItemName:self.keychainItemName];
    
    [self reset];
}

- (NSString*)userId
{
    return self.userID;
}

- (NSString*)username
{
    return self.alias;
}

- (NSString*)servicename
{
    return [Tumblr sharedService].name;
}

@end
