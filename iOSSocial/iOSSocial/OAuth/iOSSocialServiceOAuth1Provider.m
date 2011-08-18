//
//  iOSSocialServiceOAuth1Provider.m
//  iOSSocial
//
//  Created by Christopher White on 7/26/11.
//  Copyright 2011 Mad Races, Inc. All rights reserved.
//

#import "iOSSocialServiceOAuth1Provider.h"
#import "GTMOAuthAuthentication+Additions.h"
#import "GTMOAuthViewControllerTouch.h"
#import "iOSSocial.h"
#import "iOSSocialServiceOAuth1ProviderConstants.h"


@interface iOSSocialServiceOAuth1Provider ()

@property(nonatomic, readwrite, retain) NSString *clientID;
@property(nonatomic, readwrite, retain) NSString *clientSecret;
@property(nonatomic, readwrite, retain) NSString *keychainItemName;
@property(nonatomic, readwrite, retain) NSString *redirectURI;
@property(nonatomic, readwrite, retain) NSString *requestTokenURL;
@property(nonatomic, readwrite, retain) NSString *authorizeURL;
@property(nonatomic, readwrite, retain) NSString *accessTokenURL;
@property(nonatomic, readwrite, retain) NSString *serviceProviderName;
@property(nonatomic, readwrite, retain) UIViewController *viewController;
@property(nonatomic, copy)              AuthorizationHandler authenticationHandler;
@property(nonatomic, retain)            GTMOAuthAuthenticationWithAdditions *auth;

- (void)checkAuthentication;
- (GTMOAuthAuthenticationWithAdditions *)authForCustomService;

@end

@implementation iOSSocialServiceOAuth1Provider

@synthesize clientID;
@synthesize clientSecret;
@synthesize keychainItemName;
@synthesize redirectURI;
@synthesize requestTokenURL;
@synthesize authorizeURL;
@synthesize accessTokenURL;
@synthesize serviceProviderName;
@synthesize viewController;
@synthesize authenticationHandler;
@synthesize auth;

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
        self.clientID               = [dictionary objectForKey:kSMOAuth1ClientID];
        self.clientSecret           = [dictionary objectForKey:kSMOAuth1ClientSecret];
        self.redirectURI            = [dictionary objectForKey:kSMOAuth1RedirectURI];
        self.keychainItemName       = [dictionary objectForKey:kSMOAuth1KeychainItemName];
        self.requestTokenURL        = [dictionary objectForKey:kSMOAuth1RequestTokenURL];
        self.authorizeURL           = [dictionary objectForKey:kSMOAuth1AuthorizeURL];
        self.accessTokenURL         = [dictionary objectForKey:kSMOAuth1AccessTokenURL];
        self.serviceProviderName    = [dictionary objectForKey:kSMOAuth1ServiceProviderName];
        [self checkAuthentication];
    }
    
    return self;
}

- (void)viewController:(GTMOAuthViewControllerTouch *)viewController
      finishedWithAuth:(GTMOAuthAuthenticationWithAdditions *)newAuth
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
        
        self.auth = nil;
        
        [self.viewController dismissModalViewControllerAnimated:YES];
        
        if (self.authenticationHandler) {
            self.authenticationHandler(nil, error);
            self.authenticationHandler = nil;
        }
    } else {
        self.auth = newAuth;
        [self.viewController dismissModalViewControllerAnimated:YES];
        
        //cwnote: make these keys constants!!!
        NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
        NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
        [dictionary setObject:newAuth.userID forKey:@"id"];
        [dictionary setObject:newAuth.username forKey:@"username"];
        [userInfo setObject:dictionary forKey:@"user"];
        
        if (self.authenticationHandler) {
            self.authenticationHandler(userInfo, nil);
            self.authenticationHandler = nil;
        }
    }
}

- (void)authorizeWithScope:(NSString *)scope 
        fromViewController:(UIViewController*)vc 
     withCompletionHandler:(AuthorizationHandler)completionHandler
{
    self.viewController = vc;
    self.authenticationHandler = completionHandler;
    
    self.auth = [self authForCustomService];
    self.auth.scope = scope;
    
    NSURL *requestURL = [NSURL URLWithString:self.requestTokenURL];
    NSURL *accessURL = [NSURL URLWithString:self.accessTokenURL];
    NSURL *authorizationURL = [NSURL URLWithString:self.authorizeURL];
    
    GTMOAuthAuthenticationWithAdditions *auth = [self authForCustomService];
    
    // set the callback URL to which the site should redirect, and for which
    // the OAuth controller should look to determine when sign-in has
    // finished or been canceled
    //
    // This URL does not need to be for an actual web page
    [self.auth setCallback:self.redirectURI];
    
    // Display the autentication view
    GTMOAuthViewControllerTouch *oaViewController;
    oaViewController = [[GTMOAuthViewControllerTouch alloc] initWithScope:scope
                                                                 language:nil
                                                          requestTokenURL:requestURL
                                                        authorizeTokenURL:authorizationURL
                                                           accessTokenURL:accessURL
                                                           authentication:self.auth
                                                           appServiceName:self.keychainItemName
                                                                 delegate:self
                                                         finishedSelector:@selector(viewController:finishedWithAuth:error:)];
    
    [self.viewController presentModalViewController:oaViewController animated:YES];
}

- (BOOL)isSessionValid
{
    BOOL isSignedIn = self.auth.canAuthorize;;
    return isSignedIn;
}

- (GTMOAuthAuthenticationWithAdditions *)authForCustomService 
{
    GTMOAuthAuthenticationWithAdditions *newAuth;
    newAuth = [[GTMOAuthAuthenticationWithAdditions alloc] initWithSignatureMethod:kGTMOAuthSignatureMethodHMAC_SHA1
                                                                       consumerKey:self.clientID
                                                                        privateKey:self.clientSecret];
    
    // setting the service name lets us inspect the auth object later to know
    // what service it is for
    self.auth.serviceProvider = self.serviceProviderName;
    
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
    
    GTMOAuthAuthenticationWithAdditions *newAuth = [self authForCustomService];
    if (newAuth) {
        [GTMOAuthViewControllerTouch authorizeFromKeychainForName:self.keychainItemName 
                                                   authentication:newAuth];
    }
    
    self.auth = newAuth;
}

- (NSString*)oAuthAccessToken
{
    return self.auth.accessToken;
}

- (void)logout
{
    if ([self.auth.serviceProvider isEqual:kGTMOAuthServiceProviderGoogle]) {
        // remove the token from Google's servers
        [GTMOAuthViewControllerTouch revokeTokenForGoogleAuthentication:self.auth];
    }
    
    // remove the stored Google authentication from the keychain, if any
    [GTMOAuthViewControllerTouch removeParamsFromKeychainForName:self.keychainItemName];
    
    // Discard our retained authentication object.
    self.auth = nil;
}

@end
