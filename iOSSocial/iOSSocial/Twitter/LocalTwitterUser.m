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
        
        [accountStore requestAccessToAccountsWithType:accountType 
                                     withCompletionHandler:^(BOOL granted, NSError *error) {
                                         if (NO == granted) {
                                             
                                         } else {
                                             NSArray *twitterAccounts = 
                                             [accountStore accountsWithAccountType:accountType];
                                             
                                             if ([twitterAccounts count] > 0) {
                                                 // Use the first account for simplicity 
                                                 ACAccount *account = [twitterAccounts objectAtIndex:0];
                                                 
                                                 if (account) {
                                                     self.auth = account;
                                                     self.identifier = account.identifier;
                                                 } else {
                                                     self.auth = nil;
                                                     self.identifier = nil;
                                                 }
                                             }
                                             
                                             /*
                                             if (granted) {
                                             } else {
                                                 ACAccount *account = nil;
                                                 
                                                 NSArray *twitterAccounts = [accountStore accountsWithAccountType:accountType];
                                                 if (!twitterAccounts.count) {
                                                 } else {
                                                     
                                                     for (ACAccount *anAccount in twitterAccounts) {
                                                         if (NSOrderedSame == [anAccount.username compare:self.username]) {
                                                             //self.auth = account;
                                                             //self.identifier = account.identifier;
                                                             account = anAccount;
                                                             break;
                                                         }
                                                     }
                                                 }
                                                 
                                                 if (account) {
                                                     self.auth = account;
                                                     self.identifier = account.identifier;
                                                 } else {
                                                     self.auth = nil;
                                                     self.identifier = nil;
                                                 }
                                             }
                                            */
                                         }
                                     }];

        NSMutableDictionary *localUserDictionary = [NSMutableDictionary dictionary];
        [localUserDictionary setObject:[dictionary objectForKey:@"userId"] forKey:@"id"];
        [localUserDictionary setObject:[dictionary objectForKey:@"username"] forKey:@"username"];
        self.userDictionary = localUserDictionary;
    }
    return self;
}

- (id)initWithIdentifier:(NSString*)theIdentifier
{
    ACAccount *account = nil;
    
    ACAccountStore *accountStore = [[ACAccountStore alloc] init];
    
    ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
    NSArray *twitterAccounts = [accountStore accountsWithAccountType:accountType];
    if (!twitterAccounts.count) {
    } else {
        
        for (ACAccount *anAccount in twitterAccounts) {
            if (NSOrderedSame == [anAccount.username compare:self.username]) {
                //self.auth = account;
                //self.identifier = account.identifier;
                account = anAccount;
                break;
            }
        }
    }
    
    if (account) {
        self.auth = account;
        self.identifier = account.identifier;
    } else {
        self.auth = nil;
        self.identifier = nil;
    }
    
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

- (void)postTweetFromViewController:(UIViewController*)viewController 
                         withParams:(NSDictionary*)params 
              withCompletionHandler:(FetchUserDataHandler)completionHandler
{
    self.fetchUserDataHandler = completionHandler;
    
    if (YES == [TWTweetComposeViewController canSendTweet]) {
        TWTweetComposeViewController *tweet = [[TWTweetComposeViewController alloc] init];
        [tweet setInitialText:[params objectForKey:@"message"]];
        [tweet addURL:[NSURL URLWithString:[params objectForKey:@"url"]]];
        tweet.completionHandler = ^(TWTweetComposeViewControllerResult result) {
            if (TWTweetComposeViewControllerResultCancelled == result) {
                [viewController dismissModalViewControllerAnimated:YES];
            }
            
            if (self.fetchUserDataHandler) {
                self.fetchUserDataHandler(nil);
                self.fetchUserDataHandler = nil;
            }
        };
        [viewController presentModalViewController:tweet animated:YES];
    } else {
        //send back an error!
        if (self.fetchUserDataHandler) {
            self.fetchUserDataHandler(nil);
            self.fetchUserDataHandler = nil;
        }
    }
}

- (void)postTweetWithParams:(NSDictionary*)params 
      withCompletionHandler:(FetchUserDataHandler)completionHandler
{
    //use twitter request object for this

    self.fetchUserDataHandler = completionHandler;
    
    NSString *urlString = [NSString stringWithFormat:@"https://api.twitter.com/1/statuses/update.json"];
    
    NSURL *url = [NSURL URLWithString:urlString];
    
    //  Now we can create our request.  Note that we are performing a POST request.
    TWRequest *request = [[TWRequest alloc] initWithURL:url 
                                             parameters:params 
                                          requestMethod:TWRequestMethodPOST];
    
    [request setAccount:self.auth];
    
    //  Perform our request
    [request performRequestWithHandler:
     ^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
         
         if (responseData) {
             //  Use the NSJSONSerialization class to parse the returned JSON
             NSDictionary *dict = 
             (NSDictionary *)[NSJSONSerialization JSONObjectWithData:responseData 
                                                             options:0 
                                                               error:nil];
             
             // Log the result
             NSLog(@"%@", dict);
         }
     }];
    
    /*
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

- (UIViewController*)authenticateFromViewController:(UIViewController*)vc 
                              withCompletionHandler:(AuthenticationHandler)completionHandler;
{
    self.authenticationHandler = completionHandler;

    if (NO == [self isAuthenticated]) {

        if (nil == self.auth) {
            [self commonInit:nil];
        }
        
        ACAccountStore *accountStore = [[ACAccountStore alloc] init];
        
        ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
        
        [accountStore requestAccessToAccountsWithType:accountType 
                                withCompletionHandler:^(BOOL granted, NSError *error) {
                                    if (NO == granted) {
                                        
                                    } else {
                                        NSArray *twitterAccounts = 
                                        [accountStore accountsWithAccountType:accountType];
                                        
                                        if ([twitterAccounts count] > 0) {
                                            // Use the first account for simplicity 
                                            ACAccount *account = [twitterAccounts objectAtIndex:0];
                                            
                                            if (account) {
                                                self.auth = account;
                                                self.identifier = account.identifier;
                                                
                                                //cwnote: need to set user dictionary here. save identifier and username?
                                                
                                            } else {
                                                self.auth = nil;
                                                self.identifier = nil;
                                            }
                                            
                                            if (self.authenticationHandler) {
                                                self.authenticationHandler(error);
                                                self.authenticationHandler = nil;
                                            }
                                        }
                                    }
                                }];


        /*
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
        }];*/
    }
    
    return nil;
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
