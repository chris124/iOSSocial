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
#import "iOSSLog.h"
#import "iOSSocialServiceOAuth1ProviderConstants.h"

@interface IOSSOAuthParserClass : NSObject
// just enough of SBJSON to be able to parse
- (id)objectWithString:(NSString*)repr error:(NSError**)error;
- (id)objectWithString:(NSString*)repr;
@end


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
@property(nonatomic, retain)            NSString *scope;
@property(nonatomic, retain)            UINavigationController *navigationController;

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
@synthesize scope;
@synthesize navigationController;

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
        self.scope                  = [dictionary objectForKey:kSMOAuth1Scope];
    }
    
    return self;
}

- (void)assignOAuthParams:(NSDictionary*)params
{
    self.clientID               = [params objectForKey:kSMOAuth1ClientID];
    self.clientSecret           = [params objectForKey:kSMOAuth1ClientSecret];
    self.redirectURI            = [params objectForKey:kSMOAuth1RedirectURI];
    self.keychainItemName       = [params objectForKey:kSMOAuth1KeychainItemName];
    self.requestTokenURL        = [params objectForKey:kSMOAuth1RequestTokenURL];
    self.authorizeURL           = [params objectForKey:kSMOAuth1AuthorizeURL];
    self.accessTokenURL         = [params objectForKey:kSMOAuth1AccessTokenURL];
    self.serviceProviderName    = [params objectForKey:kSMOAuth1ServiceProviderName];
    self.scope                  = [params objectForKey:kSMOAuth1Scope];
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
        
        [self.viewController dismissModalViewControllerAnimated:YES];
        
        if (self.authenticationHandler) {
            self.authenticationHandler(nil, nil, error);
            self.authenticationHandler = nil;
        }
        
        self.navigationController = nil;
    } else {
        [self.viewController dismissModalViewControllerAnimated:YES];
        
        //cwnote: make these keys constants!!!
        NSMutableDictionary *userInfo = nil;
        if (newAuth.userID && newAuth.username) {
            userInfo = [NSMutableDictionary dictionary];
            NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
            [dictionary setObject:newAuth.userID forKey:@"id"];
            [dictionary setObject:newAuth.username forKey:@"username"];
            [userInfo setObject:dictionary forKey:@"user"];
        }
        
        if (self.authenticationHandler) {
            self.authenticationHandler(newAuth, userInfo, nil);
            self.authenticationHandler = nil;
        }
        
        self.navigationController = nil;
    }
}

- (void)authorizeFromViewController:(UIViewController*)vc 
                            forAuth:(GTMOAuthAuthentication*)theAuth 
                andKeychainItemName:(NSString*)theKeychainItemName 
                    andCookieDomain:(NSString*)cookieDomain 
              withCompletionHandler:(AuthorizationHandler)completionHandler
{
    self.viewController = vc;
    self.authenticationHandler = completionHandler;

    theAuth.scope = self.scope;
    
    //clear out the cookies for this domain so that we can do another login as a different user
    if (cookieDomain) {
        NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
        NSArray *cookies = [cookieStorage cookies];
        
        for (NSHTTPCookie *cookie in cookies) {
            if ([[cookie domain] hasSuffix:cookieDomain]) {
                [cookieStorage deleteCookie:cookie];
            }
        }
    }
    
    NSURL *requestURL = [NSURL URLWithString:self.requestTokenURL];
    NSURL *accessURL = [NSURL URLWithString:self.accessTokenURL];
    NSURL *authorizationURL = [NSURL URLWithString:self.authorizeURL];
    
    // set the callback URL to which the site should redirect, and for which
    // the OAuth controller should look to determine when sign-in has
    // finished or been canceled
    //
    // This URL does not need to be for an actual web page
    [theAuth setCallback:self.redirectURI];
    
    // Display the autentication view
    GTMOAuthViewControllerTouch *oaViewController;
    oaViewController = [[GTMOAuthViewControllerTouch alloc] initWithScope:self.scope
                                                                 language:nil
                                                          requestTokenURL:requestURL
                                                        authorizeTokenURL:authorizationURL
                                                           accessTokenURL:accessURL
                                                           authentication:theAuth
                                                           appServiceName:theKeychainItemName
                                                                 delegate:self
                                                         finishedSelector:@selector(viewController:finishedWithAuth:error:)];
    
    // Optional: display some html briefly before the sign-in page loads
    NSString *html = @"<html><body bgcolor=silver><div align=center>Loading sign-in page...</div></body></html>";
    oaViewController.initialHTMLString = html;
    
    self.navigationController = [[UINavigationController alloc] initWithRootViewController:oaViewController];
    [self.viewController presentModalViewController:self.navigationController animated:YES];
}

- (GTMOAuthAuthenticationWithAdditions *)authForCustomService 
{
    GTMOAuthAuthenticationWithAdditions *newAuth;
    newAuth = [[GTMOAuthAuthenticationWithAdditions alloc] initWithSignatureMethod:kGTMOAuthSignatureMethodHMAC_SHA1
                                                                       consumerKey:self.clientID
                                                                        privateKey:self.clientSecret];
    
    // setting the service name lets us inspect the auth object later to know
    // what service it is for
    newAuth.serviceProvider = self.serviceProviderName;
    
    return newAuth;
}

- (id)checkAuthenticationForKeychainItemName:(NSString*)theKeychainItemName
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
        [GTMOAuthViewControllerTouch authorizeFromKeychainForName:theKeychainItemName 
                                                   authentication:newAuth];
    }
    
    return newAuth;
}

- (void)logout:(GTMOAuthAuthentication*)theAuth forKeychainItemName:(NSString*)theKeychainItemName 
{
    if ([theAuth.serviceProvider isEqual:kGTMOAuthServiceProviderGoogle]) {
        // remove the token from Google's servers
        [GTMOAuthViewControllerTouch revokeTokenForGoogleAuthentication:theAuth];
    }
    
    // remove the stored Google authentication from the keychain, if any
    [GTMOAuthViewControllerTouch removeParamsFromKeychainForName:theKeychainItemName];
}

- (NSString*)apiKey
{
    return self.clientID;
}

- (NSString*)apiSecret
{
    return self.clientSecret;
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
            //NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            //iOSSLog(@"NSJSONSerialization error %@ parsing %@", error, str);
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
                if ([parser respondsToSelector:@selector(objectWithString:error:)]) {
                    obj = [parser objectWithString:jsonStr error:&error];
                } else {
                    obj = [parser objectWithString:jsonStr];
                }
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
