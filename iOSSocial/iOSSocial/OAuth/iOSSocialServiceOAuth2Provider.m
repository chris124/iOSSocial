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
#import "iOSSocial.h"
#import "iOSSocialServiceOAuth2ProviderConstants.h"

static GTMOAuth2Authentication *auth = nil;

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

- (void)checkAuthentication;
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
        
        auth = nil;
        
        [self.viewController dismissModalViewControllerAnimated:YES];
        
        if (self.authenticationHandler) {
            self.authenticationHandler(nil, error);
            self.authenticationHandler = nil;
        }
    } else {
        // Authentication succeeded
        auth = newAuth;
        [self.viewController dismissModalViewControllerAnimated:YES];
        
        NSDictionary *dictionary = auth.parameters;
        if (self.authenticationHandler) {
            self.authenticationHandler(dictionary, nil);
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
    
    auth = [self authForCustomService];
    auth.scope = scope;

    NSURL *authURL = [NSURL URLWithString:self.authorizeURL];
    
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

- (NSString*)oAuthAccessToken
{
    return auth.accessToken;
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

@end
