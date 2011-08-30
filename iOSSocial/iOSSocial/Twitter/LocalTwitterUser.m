//
//  LocalTwitterUser.m
//  iOSSocial
//
//  Created by Christopher White on 7/22/11.
//  Copyright 2011 Mad Races, Inc. All rights reserved.
//

#import "LocalTwitterUser.h"
#import "Twitter.h"
#import "TwitterUser+Private.h"
#import "iOSSRequest.h"
#import "GTMOAuthAuthentication.h"
#import "iOSSLog.h"


NSString *const iOSSDefaultsKeyTwitterUserDictionary    = @"ioss_twitterUserDictionary";

static LocalTwitterUser *localTwitterUser = nil;

@interface LocalTwitterUser () 

@property(nonatomic, copy)      TwitterAuthenticationHandler authenticationHandler;
@property(nonatomic, retain)    GTMOAuthAuthentication *auth;
@property(nonatomic, retain)    NSString *keychainItemName;
@property(nonatomic, retain)    NSString *uuidString;

@end

@implementation LocalTwitterUser

@synthesize authenticated;
@synthesize authenticationHandler;
@synthesize username;
@synthesize servicename;
@synthesize auth;
@synthesize keychainItemName;
@synthesize uuidString;

+ (LocalTwitterUser *)localTwitterUser
{
    @synchronized(self) {
        if(localTwitterUser == nil)
            localTwitterUser = [[super allocWithZone:NULL] init];
    }
    return localTwitterUser;
}

+ (id<iOSSocialLocalUserProtocol>)localUser
{
    @synchronized(self) {
        if(localTwitterUser == nil)
            localTwitterUser = [[super allocWithZone:NULL] init];
    }
    return localTwitterUser;
}

- (NSDictionary *)ioss_twitterUserDictionary 
{ 
    return [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@-%@", iOSSDefaultsKeyTwitterUserDictionary, self.uuidString]];
}

- (void)ioss_setTwitterUserDictionary:(NSDictionary *)theUserDictionary 
{ 
    [[NSUserDefaults standardUserDefaults] setObject:theUserDictionary forKey:[NSString stringWithFormat:@"%@-%@", iOSSDefaultsKeyTwitterUserDictionary, self.uuidString]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (id)init
{
    self = [super init];
    if (self) {
        CFUUIDRef uuid = CFUUIDCreate(kCFAllocatorDefault);
        CFStringRef uuidStr = CFUUIDCreateString(kCFAllocatorDefault, uuid);
        self.uuidString = (__bridge NSString *)uuidStr;
        CFRelease(uuidStr);
        CFRelease(uuid); 
        
        self.keychainItemName = [NSString stringWithFormat:@"InstaBeta_Twitter_Service-%@", self.uuidString];
        self.auth = [[Twitter sharedService] checkAuthenticationForKeychainItemName:self.keychainItemName];
        
        // Initialization code here.
        NSDictionary *localUserDictionary = [self ioss_twitterUserDictionary];
        if (localUserDictionary) {
            self.userDictionary = localUserDictionary;
        }
    }
    
    return self;
}

- (id)initWithUUID:(NSString*)uuid
{
    self = [super init];
    if (self) {
        self.uuidString = uuid;
        
        self.keychainItemName = [NSString stringWithFormat:@"InstaBeta_Twitter_Service-%@", self.uuidString];
        self.auth = [[Twitter sharedService] checkAuthenticationForKeychainItemName:self.keychainItemName];
        
        // Initialization code here.
        NSDictionary *localUserDictionary = [self ioss_twitterUserDictionary];
        if (localUserDictionary) {
            self.userDictionary = localUserDictionary;
        }
    }
    
    return self;
}

- (void)setUserDictionary:(NSDictionary *)theUserDictionary
{
    if (theUserDictionary) {
        [super setUserDictionary:theUserDictionary];
        
        [self ioss_setTwitterUserDictionary:theUserDictionary];
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

- (NSURL*)authorizedURL:(NSURL*)theURL
{
    NSString *access_token = [NSString stringWithFormat:@"?oauth_token=%@", [self oAuthAccessToken]];
    NSURL *url = [NSURL URLWithString:access_token relativeToURL:theURL];
    
    return url;
}

- (void)fetchLocalUserDataWithCompletionHandler:(FetchUserDataHandler)completionHandler
{
    self.fetchUserDataHandler = completionHandler;

    NSString *urlString = [NSString stringWithFormat:@"http://api.twitter.com/1/users/show.json?user_id=%@", self.userID];
    NSURL *url = [NSURL URLWithString:urlString];
    
    iOSSRequest *request = [[iOSSRequest alloc] initWithURL:url  
                                                 parameters:nil 
                                              requestMethod:iOSSRequestMethodGET];
    
    [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        if (error) {
            if (self.fetchUserDataHandler) {
                self.fetchUserDataHandler(error);
                self.fetchUserDataHandler = nil;
            }
        } else {
            NSDictionary *dictionary = [Twitter JSONFromData:responseData];
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
    //assert if twitter is nil. params have not been set!
    
    self.authenticationHandler = completionHandler;
    
    //cwnote: also see if permissions have changed!!!
    if (NO == [self isAuthenticated]) {

        [[Twitter sharedService] authorizeFromViewController:vc 
                                                     forAuth:self.auth 
                                         andKeychainItemName:self.keychainItemName 
                                             andCookieDomain:@"twitter.com" 
                                       withCompletionHandler:^(GTMOAuthAuthentication *theAuth, NSDictionary *userInfo, NSError *error) {
            self.auth = theAuth;
            if (error) {
                if (self.authenticationHandler) {
                    self.authenticationHandler(error);
                    self.authenticationHandler = nil;
                }
            } else {
                NSDictionary *user = [userInfo objectForKey:@"user"];
                self.userDictionary = user;
                
                [self fetchLocalUserDataWithCompletionHandler:^(NSError *error) {
                    if (!error) {
                        [[iOSSocialServicesStore sharedServiceStore] registerAccount:self];
                    }
                    
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

- (void)logout
{
    [[Twitter sharedService] logout:self.auth forKeychainItemName:self.keychainItemName];
    
    self.auth = nil;
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
    return [Twitter sharedService].name;
}

@end
