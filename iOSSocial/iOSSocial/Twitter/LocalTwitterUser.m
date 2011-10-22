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
#import "iOSSLog.h"
#import <Accounts/Accounts.h>
#import <Twitter/Twitter.h>
#import <Accounts/Accounts.h>

NSString *const iOSSDefaultsKeyTwitterUserDictionary    = @"ioss_twitterUserDictionary";

static LocalTwitterUser *localTwitterUser = nil;

@interface LocalTwitterUser () 

@property(nonatomic, copy)      AuthenticationHandler authenticationHandler;
@property(nonatomic, retain)    ACAccount *auth;
@property(nonatomic, retain)    NSString *identifier;

@end

@implementation LocalTwitterUser

@synthesize authenticated;
@synthesize authenticationHandler;
@synthesize username;
@synthesize servicename;
@synthesize identifier;
@synthesize auth;

+ (LocalTwitterUser *)localTwitterUser
{
    @synchronized(self) {
        if(localTwitterUser == nil)
            localTwitterUser = [[super allocWithZone:NULL] init];
    }
    return localTwitterUser;
}

+ (void)setLocalTwitterUser:(LocalTwitterUser *)theLocalTwitterUser
{
    localTwitterUser = theLocalTwitterUser;
}


- (NSDictionary *)ioss_twitterUserDictionary 
{ 
    return [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@-%@", iOSSDefaultsKeyTwitterUserDictionary, self.identifier]];
}

- (void)ioss_setTwitterUserDictionary:(NSDictionary *)theUserDictionary 
{ 
    NSString *key = [NSString stringWithFormat:@"%@-%@", iOSSDefaultsKeyTwitterUserDictionary, self.identifier];
    [[NSUserDefaults standardUserDefaults] setObject:theUserDictionary forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)commonInit:(NSString*)theIdentifier
{
    self.identifier = theIdentifier;

    self.auth = [[Twitter sharedService] checkAuthenticationForKeychainItemName:self.identifier];
    
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
        
        ACAccountStore *accountStore = [[ACAccountStore alloc] init];
        
        ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
        NSArray *twitterAccounts = [accountStore accountsWithAccountType:accountType];
        if (!twitterAccounts.count) {
            
        } else {
            
            for (ACAccount *account in twitterAccounts) {
                if (NSOrderedSame == [account.username compare:[dictionary objectForKey:@"username"]]) {
                    self.auth = account;
                    self.identifier = account.identifier;
                    break;
                }
            }
        }

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
            theUsername = [theUserDictionary objectForKey:@"screen_name"];
            if (theUsername) {
                self.alias = theUsername;
                [newUserDictionary setObject:self.alias forKey:@"screen_name"];
            }
        }
        
        [super setUserDictionary:newUserDictionary];
        
        [self ioss_setTwitterUserDictionary:newUserDictionary];
    } else {
        iOSSLog(@"meh: no user dictionary");
    }
}

- (BOOL)isAuthenticated
{
    //cwnote: how do i determine this? does it matter?
    if (!self.auth) {
        return NO;
    }
    return YES;
}

- (void)getMentions
{
    //use twitter request object for this
    
    /*
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
    */
}

- (void)postTweet
{
    //use twitter request object for this
    
    /*
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
    */
}

- (void)postTweetWithMedia
{
    //use twitter request object for this
    
    /*
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
    */
}

- (void)fetchLocalUserDataWithCompletionHandler:(FetchUserDataHandler)completionHandler
{
    self.fetchUserDataHandler = completionHandler;

    NSString *urlString = @"https://api.twitter.com/1/users/show.json";
    NSURL *url = [NSURL URLWithString:urlString];
                          
    NSDictionary *parameters = [NSDictionary dictionaryWithObject:self.username forKey:@"screen_name"];
                          
    TWRequest *request = [[TWRequest alloc] initWithURL:url 
                                             parameters:parameters 
                                          requestMethod:TWRequestMethodGET];
    [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        //
        if (error) {
            if (self.fetchUserDataHandler) {
                self.fetchUserDataHandler(error);
                self.fetchUserDataHandler = nil;
            }
        } else {
            NSDictionary *dictionary = [Twitter JSONFromData:responseData];
            NSString *errorString = [dictionary objectForKey:@"error"];
            if (!errorString) {
                self.userDictionary = dictionary;
            } else {
                //most likely hit a rate limit. ugh!
                /*
                {
                    error = "Rate limit exceeded. Clients may not make more than 150 requests per hour.";
                    request = "/1/users/show.json?screen_name=christhepiss";
                }
                */
                
                error = [NSError errorWithDomain:@"SW" code:1 userInfo:nil];
            }
            
            if (self.fetchUserDataHandler) {
                self.fetchUserDataHandler(error);
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
                                         andKeychainItemName:nil 
                                             andCookieDomain:@"twitter.com" 
                                       withCompletionHandler:^(ACAccount *theAuth, NSDictionary *userInfo, NSError *error) {
            self.auth = theAuth;
            self.identifier = theAuth.identifier;
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
    return nil;
}

- (NSTimeInterval)oAuthAccessTokenExpirationDate
{
    return 0.0;
}

- (NSString*)oAuthAccessTokenSecret
{
    return nil;
}

- (void)logout
{
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
