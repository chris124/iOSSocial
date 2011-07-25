//
//  Twitter.m
//  iOSSocial
//
//  Created by Christopher White on 7/22/11.
//  Copyright 2011 Mad Races, Inc. All rights reserved.
//

#import "Twitter.h"
#import "GTMOAuthAuthentication+TwitterAdditions.h"
#import "GTMOAuthViewControllerTouch.h"
#import "iOSSocial.h"
#import "TwitterConstants.h"

static GTMOAuthAuthenticationWithTwitterAdditions *auth = nil;

@interface IOSSOAuthParserClass : NSObject
// just enough of SBJSON to be able to parse
- (id)objectWithString:(NSString*)repr error:(NSError**)error;
@end

@interface Twitter ()

@property(nonatomic, readwrite, retain) NSString *clientID;
@property(nonatomic, readwrite, retain) NSString *clientSecret;
@property(nonatomic, readwrite, retain) NSString *keychainItemName;
@property(nonatomic, readwrite, retain) NSString *redirectURI;
@property(nonatomic, readwrite, retain) UIViewController *viewController;
@property(nonatomic, copy)      AuthorizationHandler authenticationHandler;

- (void)checkAuthentication;
- (GTMOAuthAuthenticationWithTwitterAdditions *)authForCustomService;

@end

@implementation Twitter

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
        // Initialization code here.
    }
    
    return self;
}

- (id)initWithDictionary:(NSDictionary*)dictionary
{
    self = [self init];
    if (self) {
        // Initialization code here.
        self.clientID           = [dictionary objectForKey:kSMTwitterClientID];
        self.clientSecret       = [dictionary objectForKey:kSMTwitterClientSecret];
        self.redirectURI        = [dictionary objectForKey:kSMTwitterRedirectURI];
        self.keychainItemName   = [dictionary objectForKey:kSMTwitterKeychainItemName];
        [self checkAuthentication];
    }
    
    return self;
}

- (void)viewController:(GTMOAuthViewControllerTouch *)viewController
      finishedWithAuth:(GTMOAuthAuthenticationWithTwitterAdditions *)newAuth
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
        auth = newAuth;
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
    
    auth = [self authForCustomService];
    auth.scope = scope;
    
    NSURL *requestURL = [NSURL URLWithString:@"https://api.twitter.com/oauth/request_token"];
    NSURL *accessURL = [NSURL URLWithString:@"https://api.twitter.com/oauth/access_token"];
    NSURL *authorizeURL = [NSURL URLWithString:@"https://api.twitter.com/oauth/authorize"];
    
    GTMOAuthAuthenticationWithTwitterAdditions *auth = [self authForCustomService];
    
    // set the callback URL to which the site should redirect, and for which
    // the OAuth controller should look to determine when sign-in has
    // finished or been canceled
    //
    // This URL does not need to be for an actual web page
    [auth setCallback:self.redirectURI];
    
    // Display the autentication view
    GTMOAuthViewControllerTouch *oaViewController;
    oaViewController = [[GTMOAuthViewControllerTouch alloc] initWithScope:scope
                                                                  language:nil
                                                           requestTokenURL:requestURL
                                                         authorizeTokenURL:authorizeURL
                                                            accessTokenURL:accessURL
                                                            authentication:auth
                                                            appServiceName:self.keychainItemName
                                                                  delegate:self
                                                          finishedSelector:@selector(viewController:finishedWithAuth:error:)];
    
    [self.viewController presentModalViewController:oaViewController animated:YES];
}

- (BOOL)isSessionValid
{
    BOOL isSignedIn = auth.canAuthorize;;
    return isSignedIn;
}

- (GTMOAuthAuthenticationWithTwitterAdditions *)authForCustomService 
{
    GTMOAuthAuthenticationWithTwitterAdditions *newAuth;
    newAuth = [[GTMOAuthAuthenticationWithTwitterAdditions alloc] initWithSignatureMethod:kGTMOAuthSignatureMethodHMAC_SHA1
                                                                              consumerKey:self.clientID
                                                                               privateKey:self.clientSecret];
    
    // setting the service name lets us inspect the auth object later to know
    // what service it is for
    auth.serviceProvider = @"Twitter Service";
    
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
    
    GTMOAuthAuthenticationWithTwitterAdditions *newAuth = [self authForCustomService];
    if (newAuth) {
        [GTMOAuthViewControllerTouch authorizeFromKeychainForName:self.keychainItemName 
                                                    authentication:newAuth];
    }
    
    auth = newAuth;
}

- (void)logout
{
    if ([auth.serviceProvider isEqual:kGTMOAuthServiceProviderGoogle]) {
        // remove the token from Google's servers
        [GTMOAuthViewControllerTouch revokeTokenForGoogleAuthentication:auth];
    }
    
    // remove the stored Google authentication from the keychain, if any
    [GTMOAuthViewControllerTouch removeParamsFromKeychainForName:self.keychainItemName];
    
    // Discard our retained authentication object.
    auth = nil;
}

+ (void)authorizeURLRequest:(NSMutableURLRequest*)URLRequest
{
    [auth authorizeRequest:URLRequest];
}

+ (id)JSONFromData:(NSData*)data
{
    id obj = nil;
    NSError *error = nil;
    
    Class serializer = NSClassFromString(@"NSJSONSerialization");
    if (serializer) {
        const NSUInteger kOpts = (1UL << 0); // NSJSONReadingMutableContainers
        obj = [serializer JSONObjectWithData:data
                                     options:kOpts
                                       error:&error];
#if DEBUG
        if (error) {
            NSString *str = [[NSString alloc] initWithData:data
                                                  encoding:NSUTF8StringEncoding];
            iOSSLog(@"NSJSONSerialization error %@ parsing %@",
                    error, str);
        }
#endif
        return obj;
    } else {
        // try SBJsonParser or SBJSON
        Class jsonParseClass = NSClassFromString(@"SBJsonParser");
        if (!jsonParseClass) {
            jsonParseClass = NSClassFromString(@"SBJSON");
        }
        if (jsonParseClass) {
            IOSSOAuthParserClass *parser = [[jsonParseClass alloc] init];
            NSString *jsonStr = [[NSString alloc] initWithData:data
                                                      encoding:NSUTF8StringEncoding];
            if (jsonStr) {
                obj = [parser objectWithString:jsonStr error:&error];
#if DEBUG
                if (error) {
                    iOSSLog(@"%@ error %@ parsing %@", NSStringFromClass(jsonParseClass),
                            error, jsonStr);
                }
#endif
                return obj;
            }
        }
    }
    return nil;
}

@end
