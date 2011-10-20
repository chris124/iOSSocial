//
//  LocalTwitterUserLegacy.m
//  iOSSocial
//
//  Created by Christopher White on 7/22/11.
//  Copyright 2011 Mad Races, Inc. All rights reserved.
//

#import "LocalTwitterUserLegacy.h"
#import "Twitter.h"
#import "TwitterUserLegacy+Private.h"
#import "iOSSRequest.h"
#import "GTMOAuthAuthentication.h"
#import "iOSSLog.h"


NSString *const iOSSDefaultsKeyTwitterUserLegacyDictionary    = @"ioss_twitterUserLegacyDictionary";

static LocalTwitterUserLegacy *localTwitterUser = nil;

@interface LocalTwitterUserLegacy () 

@property(nonatomic, copy)      AuthenticationHandler authenticationHandler;
@property(nonatomic, retain)    GTMOAuthAuthentication *auth;
@property(nonatomic, retain)    NSString *keychainItemName;
@property(nonatomic, readwrite, retain)    NSString *identifier;

@end

@implementation LocalTwitterUserLegacy

@synthesize authenticated;
@synthesize authenticationHandler;
@synthesize username;
@synthesize servicename;
@synthesize auth;
@synthesize keychainItemName;
@synthesize identifier;

+ (LocalTwitterUserLegacy *)localTwitterUser
{
    @synchronized(self) {
        if(localTwitterUser == nil)
            localTwitterUser = [[super allocWithZone:NULL] init];
    }
    return localTwitterUser;
}

- (NSDictionary *)ioss_twitterUserDictionary 
{ 
    return [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@-%@", iOSSDefaultsKeyTwitterUserLegacyDictionary, self.identifier]];
}

- (void)ioss_setTwitterUserDictionary:(NSDictionary *)theUserDictionary 
{ 
    [[NSUserDefaults standardUserDefaults] setObject:theUserDictionary forKey:[NSString stringWithFormat:@"%@-%@", iOSSDefaultsKeyTwitterUserLegacyDictionary, self.identifier]];
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
    
    
    self.keychainItemName = [NSString stringWithFormat:@"%@-%@", [[Twitter sharedService] serviceKeychainItemName], self.identifier];
    self.auth = [[Twitter sharedService] checkAuthenticationForKeychainItemName:self.keychainItemName];
    
    // Initialization code here.
    NSDictionary *localUserDictionary = [self ioss_twitterUserDictionary];
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
        
        NSMutableDictionary *newUserDictionary = [NSMutableDictionary dictionary];
        
        NSString *theUserID = [theUserDictionary objectForKey:@"id"];
        if (theUserID) {
            self.userID = theUserID;
            [newUserDictionary setObject:self.userID forKey:@"id"];
        }
        
        NSString *theProfilePictureURL = [theUserDictionary objectForKey:@"profile_image_url_https"];
        if (theProfilePictureURL) {
            self.profilePictureURL = theProfilePictureURL;
            [newUserDictionary setObject:self.profilePictureURL forKey:@"profile_image_url_https"];
        }
        NSString *theUsername = [theUserDictionary objectForKey:@"username"];
        if (theUsername) {
            self.alias = theUsername;
            [newUserDictionary setObject:self.alias forKey:@"username"];
        } else {
            self.alias = [theUserDictionary objectForKey:@"screen_name"];
            [newUserDictionary setObject:self.alias forKey:@"screen_name"];
        }
        
        [super setUserDictionary:newUserDictionary];
        
        [self ioss_setTwitterUserDictionary:newUserDictionary];
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

- (void)getMentions
{
    //self.fetchUserDataHandler = completionHandler;
    
    NSString *urlString = [NSString stringWithFormat:@"https://api.twitter.com/1/statuses/mentions.json"];
    
    NSURL *url = [NSURL URLWithString:urlString];
    
    iOSSRequest *request = [[iOSSRequest alloc] initWithURL:url  
                                                 parameters:nil  
                                              requestMethod:iOSSRequestMethodGET];
    
    NSMutableDictionary *oauthParams = [NSMutableDictionary dictionary];
    [oauthParams setObject:[[Twitter sharedService] apiKey] forKey:kASIOAuthConsumerKey];
    [oauthParams setObject:[[Twitter sharedService] apiSecret] forKey:kASIOAuthConsumerSecret];
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
            //NSDictionary *dictionary = [Twitter JSONFromData:responseData];
            
            if (self.fetchUserDataHandler) {
                self.fetchUserDataHandler(nil);
                self.fetchUserDataHandler = nil;
            }
        }
    }];
}

- (void)postTweet
{
    //self.fetchUserDataHandler = completionHandler;
    
    NSString *urlString = [NSString stringWithFormat:@"https://api.twitter.com/1/statuses/update.json"];
    
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:@"bananas!" forKey:@"status"];
    
    iOSSRequest *request = [[iOSSRequest alloc] initWithURL:url  
                                                 parameters:params 
                                              requestMethod:iOSSRequestMethodPOST];

    NSMutableDictionary *oauthParams = [NSMutableDictionary dictionary];
    [oauthParams setObject:[[Twitter sharedService] apiKey] forKey:kASIOAuthConsumerKey];
    [oauthParams setObject:[[Twitter sharedService] apiSecret] forKey:kASIOAuthConsumerSecret];
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
            //NSDictionary *dictionary = [Twitter JSONFromData:responseData];
            
            if (self.fetchUserDataHandler) {
                self.fetchUserDataHandler(nil);
                self.fetchUserDataHandler = nil;
            }
        }
    }];
}

- (void)postTweetWithMedia
{
    //self.fetchUserDataHandler = completionHandler;
    
    NSString *urlString = [NSString stringWithFormat:@"https://upload.twitter.com/1/statuses/update_with_media.json"];
    
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:@"photo!" forKey:@"status"];
    
    iOSSRequest *request = [[iOSSRequest alloc] initWithURL:url  
                                                 parameters:params 
                                              requestMethod:iOSSRequestMethodPOST];
    
    //NSString *photoPath = [[NSBundle mainBundle] pathForResource:@"CIMG2891" ofType:@"JPG"];
    //[self.request setFile:photoPath forKey:@"media[]"];
    
    NSString *photoPath = [[NSBundle mainBundle] pathForResource:@"CIMG2891" ofType:@"JPG"];
    [request addFile:photoPath forKey:@"media[]"];
    
    NSMutableDictionary *oauthParams = [NSMutableDictionary dictionary];
    [oauthParams setObject:[[Twitter sharedService] apiKey] forKey:kASIOAuthConsumerKey];
    [oauthParams setObject:[[Twitter sharedService] apiSecret] forKey:kASIOAuthConsumerSecret];
    [oauthParams setObject:[self oAuthAccessToken] forKey:kASIOAuthTokenKey];
    [oauthParams setObject:kASIOAuthSignatureMethodHMAC_SHA1 forKey:kASIOAuthSignatureMethodKey];
    [oauthParams setObject:@"1.0" forKey:kASIOAuthVersionKey];
    [oauthParams setObject:[self oAuthAccessTokenSecret] forKey:kASIOAuthTokenSecretKey];
    
    request.oauth_params = oauthParams;
    
    [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        if (error) {
            if (self.fetchUserDataHandler) {
                self.fetchUserDataHandler(error);
                self.fetchUserDataHandler = nil;
            }
        } else {
            //NSDictionary *dictionary = [Twitter JSONFromData:responseData];
            
            if (self.fetchUserDataHandler) {
                self.fetchUserDataHandler(nil);
                self.fetchUserDataHandler = nil;
            }
        }
    }];
}

- (void)fetchLocalUserDataWithCompletionHandler:(FetchUserDataHandler)completionHandler
{
    self.fetchUserDataHandler = completionHandler;

    NSString *urlString = [NSString stringWithFormat:@"https://api.twitter.com/1/users/show.json?user_id=%@", self.userID];
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
    self.authenticationHandler = completionHandler;
    
    //cwnote: also see if permissions have changed!!!
    if (NO == [self isAuthenticated]) {
        
        if (nil == self.auth) {
            [self commonInit:nil];
        }

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

- (NSTimeInterval)oAuthAccessTokenExpirationDate
{
    return 0.0;
}

- (NSString*)oAuthAccessTokenSecret
{
    return self.auth.tokenSecret;
}

- (void)logout
{
    [[Twitter sharedService] logout:self.auth forKeychainItemName:self.keychainItemName];
    
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
    return [Twitter sharedService].name;
}

@end
