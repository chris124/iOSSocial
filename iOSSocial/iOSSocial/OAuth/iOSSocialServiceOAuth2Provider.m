//
//  iOSSocialServiceOAuth2Provider.m
//  iOSSocial
//
//  Created by Christopher White on 7/26/11.
//  Copyright 2011 Mad Races, Inc. All rights reserved.
//

#import "iOSSocialServiceOAuth2Provider.h"
#import "GTMOAuth2Authentication.h"
#import "GTMOAuth2ViewControllerTouch.h"
#import "GTMOAuth2SignIn.h"
#import "iOSSLog.h"
#import "iOSSocialServiceOAuth2ProviderConstants.h"
#import "GTMOAuthAuthentication+Additions.h"


@interface iOSSocialServiceOAuth2Provider ()

@property(nonatomic, readwrite, retain) NSString *clientID;
@property(nonatomic, readwrite, retain) NSString *clientSecret;
@property(nonatomic, readwrite, retain) NSString *keychainItemName;
@property(nonatomic, readwrite, retain) NSString *redirectURI;
@property(nonatomic, readwrite, retain) NSString *authorizeURL;
@property(nonatomic, readwrite, retain) NSString *accessTokenURL;
@property(nonatomic, readwrite, retain) NSString *serviceProviderName;
@property(nonatomic, readwrite, retain) UIViewController *viewController;
@property(nonatomic, copy)              AuthorizationHandler authenticationHandler;
@property(nonatomic, retain)            NSString *scope;

- (GTMOAuth2Authentication *)authForCustomService;

@end

@implementation iOSSocialServiceOAuth2Provider

@synthesize clientID;
@synthesize clientSecret;
@synthesize keychainItemName;
@synthesize redirectURI;
@synthesize authorizeURL;
@synthesize accessTokenURL;
@synthesize serviceProviderName;
@synthesize viewController;
@synthesize authenticationHandler;
@synthesize scope;

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (id)initWithDictionary:(NSDictionary*)dictionary
{
    self = [self init];
    if (self) {
        // Initialization code here.
        self.clientID               = [dictionary objectForKey:kSMOAuth2ClientID];
        self.clientSecret           = [dictionary objectForKey:kSMOAuth2ClientSecret];
        self.redirectURI            = [dictionary objectForKey:kSMOAuth2RedirectURI];
        self.keychainItemName       = [dictionary objectForKey:kSMOAuth2KeychainItemName];
        self.authorizeURL           = [dictionary objectForKey:kSMOAuth2AuthorizeURL];
        self.accessTokenURL         = [dictionary objectForKey:kSMOAuth2AccessTokenURL];
        self.serviceProviderName    = [dictionary objectForKey:kSMOAuth2ServiceProviderName];
    }
    
    return self;
}

- (void)assignOAuthParams:(NSDictionary*)params
{
    self.clientID               = [params objectForKey:kSMOAuth2ClientID];
    self.clientSecret           = [params objectForKey:kSMOAuth2ClientSecret];
    self.redirectURI            = [params objectForKey:kSMOAuth2RedirectURI];
    self.keychainItemName       = [params objectForKey:kSMOAuth2KeychainItemName];
    self.authorizeURL           = [params objectForKey:kSMOAuth2AuthorizeURL];
    self.accessTokenURL         = [params objectForKey:kSMOAuth2AccessTokenURL];
    self.serviceProviderName    = [params objectForKey:kSMOAuth2ServiceProviderName];
    self.scope                  = [params objectForKey:kSMOAuth2Scope];
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
            //NSString *str = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
            //iOSSLog(@"%@", str);
        }
        
        [self.viewController dismissModalViewControllerAnimated:YES];
        
        if (self.authenticationHandler) {
            self.authenticationHandler(nil, nil, error);
            self.authenticationHandler = nil;
        }
    } else {
        // Authentication succeeded
        [self.viewController dismissModalViewControllerAnimated:YES];

        NSDictionary *dictionary = newAuth.parameters;
        if (self.authenticationHandler) {
            self.authenticationHandler(newAuth, dictionary, nil);
            self.authenticationHandler = nil;
        }
    }
}

- (void)authorizeFromViewController:(UIViewController*)vc 
                            forAuth:(GTMOAuth2Authentication*)theAuth 
                           andKeychainItemName:(NSString*)theKeychainItemName 
                    andCookieDomain:(NSString*)cookieDomain 
              withCompletionHandler:(AuthorizationHandler)completionHandler
{
    self.viewController = vc;
    self.authenticationHandler = completionHandler;

    theAuth.scope = self.scope;
    
    NSURL *authURL = [NSURL URLWithString:self.authorizeURL];

    if (cookieDomain) {
        NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
        NSArray *cookies = [cookieStorage cookies];
        
        for (NSHTTPCookie *cookie in cookies) {
            if ([[cookie domain] hasSuffix:cookieDomain]) {
                [cookieStorage deleteCookie:cookie];
            }
        }
    }
    
    // Display the authentication view
    GTMOAuth2ViewControllerTouch *oaViewController;
    oaViewController = [[GTMOAuth2ViewControllerTouch alloc] initWithAuthentication:theAuth
                                                                   authorizationURL:authURL
                                                                   keychainItemName:theKeychainItemName
                                                                           delegate:self
                                                                   finishedSelector:@selector(viewController:finishedWithAuth:error:)];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:@"touch" forKey:@"display"];
    oaViewController.signIn.additionalAuthorizationParameters = params;
    
    // Optional: display some html briefly before the sign-in page loads
    NSString *html = @"<html><body bgcolor=silver><div align=center>Loading sign-in page...</div></body></html>";
    oaViewController.initialHTMLString = html;
    
    //[self.viewController pushViewController:oaViewController
    [self.viewController presentModalViewController:oaViewController animated:YES];
}

- (GTMOAuth2Authentication *)authForCustomService 
{
    //cwnote: need to store access token url
    NSURL *tokenURL = [NSURL URLWithString:self.accessTokenURL];
    
    GTMOAuth2Authentication *newAuth;
    newAuth = [GTMOAuth2Authentication authenticationWithServiceProvider:self.serviceProviderName
                                                                tokenURL:tokenURL
                                                             redirectURI:self.redirectURI
                                                                clientID:self.clientID
                                                            clientSecret:self.clientSecret];
    return newAuth;
}

- (GTMOAuth2Authentication*)checkAuthenticationForKeychainItemName:(NSString*)theKeychainItemName
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
        [GTMOAuth2ViewControllerTouch authorizeFromKeychainForName:theKeychainItemName 
                                                    authentication:newAuth];
    }
    
    return newAuth;
}

- (void)logout:(GTMOAuth2Authentication*)theAuth forKeychainItemName:(NSString*)theKeychainItemName
{
    if ([theAuth.serviceProvider isEqual:kGTMOAuth2ServiceProviderGoogle]) {
        // remove the token from Google's servers
        [GTMOAuth2ViewControllerTouch revokeTokenForGoogleAuthentication:theAuth];
    }
    
    // remove the stored Google authentication from the keychain, if any
    [GTMOAuth2ViewControllerTouch removeAuthFromKeychainForName:theKeychainItemName];
    
    // Discard our retained authentication object.
    //theAuth = nil;
}

- (NSString*)apiKey
{
    return self.clientID;
}

- (NSString*)apiSecret
{
    return self.clientSecret;
}

- (NSString*)authorizationHeaderForRequest:(NSURLRequest *)request withAuth:(GTMOAuthAuthenticationWithAdditions*)auth;
{
    return nil;
}

@end
