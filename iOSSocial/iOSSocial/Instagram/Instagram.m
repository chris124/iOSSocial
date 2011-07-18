//
//  Instagram.m
//  InstaBeta
//
//  Created by Christopher White on 7/14/11.
//  Copyright 2011 Mad Races, Inc. All rights reserved.
//

#import "Instagram.h"
#import "GTMOAuth2Authentication.h"
#import "GTMOAuth2ViewControllerTouch.h"
#import "GTMOAuth2SignIn.h"
#import "iOSSocial.h"
#import "InstagramConstants.h"

static GTMOAuth2Authentication *auth = nil;

@interface Instagram ()

@property(nonatomic, readwrite, retain) NSString *clientID;
@property(nonatomic, readwrite, retain) NSString *clientSecret;
@property(nonatomic, readwrite, retain) NSString *keychainItemName;
@property(nonatomic, readwrite, retain) NSString *redirectURI;
@property(nonatomic, readwrite, retain) UIViewController *viewController;
@property(nonatomic, copy)      AuthorizationHandler authenticationHandler;

- (void)checkAuthentication;
- (GTMOAuth2Authentication *)authForCustomService;

@end

@implementation Instagram

@synthesize clientID;
@synthesize clientSecret;
@synthesize keychainItemName;
@synthesize redirectURI;
@synthesize viewController;
@synthesize authenticationHandler;

- (id)init
{
    self = [super init];
    if (self) {
    }
    
    return self;
}

- (id)initWithDictionary:(NSDictionary*)dictionary
{
    self = [self init];
    if (self) {
        // Initialization code here.
        self.clientID           = [dictionary objectForKey:kSMInstagramClientID];
        self.clientSecret       = [dictionary objectForKey:kSMInstagramClientSecret];
        self.redirectURI        = [dictionary objectForKey:kSMInstagramRedirectURI];
        self.keychainItemName   = [dictionary objectForKey:kSMInstagramKeychainItemName];
        [self checkAuthentication];
    }
    
    return self;
}

- (void)viewController:(GTMOAuth2ViewControllerTouch *)viewController
      finishedWithAuth:(GTMOAuth2Authentication *)newAuth
                 error:(NSError *)error 
{
    if (error != nil) {
        // Authentication failed
        // Authentication failed (perhaps the user denied access, or closed the
        // window before granting access)
        iOSSLog(@"Authentication error: %@", error);
        NSData *responseData = [[error userInfo] objectForKey:@"data"]; // kGTMHTTPFetcherStatusDataKey
        if ([responseData length] > 0) {
            // show the body of the server's authentication failure response
            NSString *str = [[NSString alloc] initWithData:responseData
                                                  encoding:NSUTF8StringEncoding];
            iOSSLog(@"%@", str);
        }
        
        if (self.authenticationHandler) {
            self.authenticationHandler(nil, error);
            self.authenticationHandler = nil;
        }
        
        auth = nil;
        
        [self.viewController dismissModalViewControllerAnimated:YES];
    } else {
        // Authentication succeeded
        
        NSDictionary *dictionary = auth.parameters;
        if (self.authenticationHandler) {
            self.authenticationHandler(dictionary, nil);
            self.authenticationHandler = nil;
        }
        
        auth = newAuth;
        [self.viewController dismissModalViewControllerAnimated:YES];
    }
}


- (void)authorizeWithScope:(NSString *)scope 
        fromViewController:(UIViewController*)vc 
     withCompletionHandler:(AuthorizationHandler)completionHandler
{
    self.viewController = vc;
    self.authenticationHandler = completionHandler;
    
    auth = [self authForCustomService];
    auth.scope = scope;
    
    NSURL *authURL = [NSURL URLWithString:@"https://api.instagram.com/oauth/authorize"];
    
    // Display the authentication view
    GTMOAuth2ViewControllerTouch *oaViewController;
    oaViewController = [[GTMOAuth2ViewControllerTouch alloc] initWithAuthentication:auth
                                                                 authorizationURL:authURL
                                                                 keychainItemName:self.keychainItemName
                                                                         delegate:self
                                                                 finishedSelector:@selector(viewController:finishedWithAuth:error:)];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:@"touch" forKey:@"display"];
    oaViewController.signIn.additionalAuthorizationParameters = params;
    
    // Optional: display some html briefly before the sign-in page loads
    NSString *html = @"<html><body bgcolor=silver><div align=center>Loading sign-in page...</div></body></html>";
    oaViewController.initialHTMLString = html;
    
    [self.viewController presentModalViewController:oaViewController animated:YES];
}

- (BOOL)isSessionValid
{
    BOOL isSignedIn = auth.canAuthorize;;
    return isSignedIn;
}

- (GTMOAuth2Authentication *)authForCustomService 
{
    
    NSURL *tokenURL = [NSURL URLWithString:@"https://api.instagram.com/oauth/access_token"];
    
    GTMOAuth2Authentication *newAuth;
    newAuth = [GTMOAuth2Authentication authenticationWithServiceProvider:@"Instagram Service"
                                                                tokenURL:tokenURL
                                                             redirectURI:self.redirectURI
                                                                clientID:self.clientID
                                                            clientSecret:self.clientSecret];
    return newAuth;
}

- (void)checkAuthentication 
{
    // Listen for network change notifications
    /*
     NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
     [nc addObserver:self selector:@selector(incrementNetworkActivity:) name:kGTMOAuth2FetchStarted object:nil];
     [nc addObserver:self selector:@selector(decrementNetworkActivity:) name:kGTMOAuth2FetchStopped object:nil];
     [nc addObserver:self selector:@selector(signInNetworkLostOrFound:) name:kGTMOAuth2NetworkLost  object:nil];
     [nc addObserver:self selector:@selector(signInNetworkLostOrFound:) name:kGTMOAuth2NetworkFound object:nil];
     */
    
    GTMOAuth2Authentication *newAuth = [self authForCustomService];
    if (newAuth) {
        [GTMOAuth2ViewControllerTouch authorizeFromKeychainForName:self.keychainItemName 
                                                    authentication:newAuth];
    }

    auth = newAuth;
}

- (void)logout
{
    if ([auth.serviceProvider isEqual:kGTMOAuth2ServiceProviderGoogle]) {
        // remove the token from Google's servers
        [GTMOAuth2ViewControllerTouch revokeTokenForGoogleAuthentication:auth];
    }
    
    // remove the stored Google authentication from the keychain, if any
    [GTMOAuth2ViewControllerTouch removeAuthFromKeychainForName:self.keychainItemName];
    
    // Discard our retained authentication object.
    auth = nil;
}

+ (NSURL*)authorizeURL:(NSURL*)URL
{
    NSString *access_token = [NSString stringWithFormat:@"?access_token=%@", auth.accessToken];
    NSURL *url = [NSURL URLWithString:access_token relativeToURL:URL];
    
    return url;
}

@end
