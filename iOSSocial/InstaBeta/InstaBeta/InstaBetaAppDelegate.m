//
//  InstaBetaAppDelegate.m
//  InstaBeta
//
//  Created by Christopher White on 7/26/11.
//  Copyright 2011 Mad Races, Inc. All rights reserved.
//

#import "InstaBetaAppDelegate.h"
#import "InstaBetaViewController.h"
//OAuth 2 Services
#import "Instagram.h"
#import "Foursquare.h"
#import "FacebookService.h"
#import "LocalFacebookUser.h"
#import "iOSSocialServiceOAuth2ProviderConstants.h"
//OAuth 1 Services
#import "Twitter.h"
#import "Flickr.h"
#import "Tumblr.h"
#import "iOSSocialServiceOAuth1ProviderConstants.h"

@implementation InstaBetaAppDelegate

@synthesize window = _window;
@synthesize viewController = _viewController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
	[params setObject:@"" forKey:kSMOAuth2ClientID];
	[params setObject:@"" forKey:kSMOAuth2ClientSecret];
	[params setObject:@"" forKey:kSMOAuth2RedirectURI];
	[params setObject:@"" forKey:kSMOAuth2KeychainItemName];
    [params setObject:@"https://api.instagram.com/oauth/authorize" forKey:kSMOAuth2AuthorizeURL];
    [params setObject:@"https://api.instagram.com/oauth/access_token" forKey:kSMOAuth2AccessTokenURL];
    [params setObject:@"Instagram Service" forKey:kSMOAuth2ServiceProviderName];
    [params setObject:@"basic comments relationships likes" forKey:kSMOAuth2Scope];
    [[Instagram sharedService] assignOAuthParams:params asPrimary:YES];
    
    [params removeAllObjects];
    
    [params setObject:@"" forKey:kSMOAuth1ClientID];
    [params setObject:@"" forKey:kSMOAuth1ClientSecret];
    [params setObject:@"" forKey:kSMOAuth1RedirectURI];
    [params setObject:@"" forKey:kSMOAuth1KeychainItemName];
    [params setObject:@"https://api.twitter.com/oauth/request_token" forKey:kSMOAuth1RequestTokenURL];
    [params setObject:@"https://api.twitter.com/oauth/access_token" forKey:kSMOAuth1AccessTokenURL];
    [params setObject:@"https://api.twitter.com/oauth/authorize" forKey:kSMOAuth1AuthorizeURL];
    [params setObject:@"Twitter Service" forKey:kSMOAuth1ServiceProviderName];
    [[Twitter sharedService] assignOAuthParams:params asPrimary:NO];
    
    [params removeAllObjects];
    
    [params setObject:@"" forKey:kSMOAuth1ClientID];
    [params setObject:@"" forKey:kSMOAuth1ClientSecret];
    [params setObject:@"" forKey:kSMOAuth1RedirectURI];
    [params setObject:@"" forKey:kSMOAuth1KeychainItemName];
    [params setObject:@"http://www.flickr.com/services/oauth/request_token" forKey:kSMOAuth1RequestTokenURL];
    [params setObject:@"http://www.flickr.com/services/oauth/access_token" forKey:kSMOAuth1AccessTokenURL];
    [params setObject:@"http://www.flickr.com/services/oauth/authorize" forKey:kSMOAuth1AuthorizeURL];
    [params setObject:@"Flickr Service" forKey:kSMOAuth1ServiceProviderName];
    [[Flickr sharedService] assignOAuthParams:params asPrimary:NO];
    
    [params removeAllObjects];
    
    [params setObject:@"" forKey:kSMOAuth2ClientID];
    [params setObject:@"" forKey:kSMOAuth2ClientSecret];
    [params setObject:@"" forKey:kSMOAuth2RedirectURI];
    [params setObject:@"" forKey:kSMOAuth2KeychainItemName];
    [params setObject:@"https://foursquare.com/oauth2/authorize" forKey:kSMOAuth2AuthorizeURL];
    [params setObject:@"https://foursquare.com/oauth2/access_token" forKey:kSMOAuth2AccessTokenURL];
    [params setObject:@"Foursquare Service" forKey:kSMOAuth2ServiceProviderName];
    [[Foursquare sharedService] assignOAuthParams:params asPrimary:NO];
    
    [params removeAllObjects];
    
    [params setObject:@"" forKey:kSMOAuth1ClientID];
    [params setObject:@"" forKey:kSMOAuth1ClientSecret];
    [params setObject:@"" forKey:kSMOAuth1RedirectURI];
    [params setObject:@"" forKey:kSMOAuth1KeychainItemName];
    [params setObject:@"http://www.tumblr.com/oauth/request_token" forKey:kSMOAuth1RequestTokenURL];
    [params setObject:@"http://www.tumblr.com/oauth/access_token" forKey:kSMOAuth1AccessTokenURL];
    [params setObject:@"http://www.tumblr.com/oauth/authorize" forKey:kSMOAuth1AuthorizeURL];
    [params setObject:@"Tumblr Service" forKey:kSMOAuth1ServiceProviderName];
    [[Tumblr sharedService] assignOAuthParams:params asPrimary:NO];
    
    [params removeAllObjects];
    
    [params setObject:@"" forKey:kSMOAuth2ClientID];
    [params setObject:@"" forKey:kSMOAuth2ClientSecret];
    [params setObject:@"" forKey:kSMOAuth2URLSchemeSuffix];
    [params setObject:@"read_stream publish_stream offline_access" forKey:kSMOAuth2Scope];
    [[FacebookService sharedService] assignOAuthParams:params asPrimary:NO];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        self.viewController = [[InstaBetaViewController alloc] initWithNibName:@"InstaBetaViewController_iPhone" bundle:nil]; 
    } else {
        self.viewController = [[InstaBetaViewController alloc] initWithNibName:@"InstaBetaViewController_iPad" bundle:nil]; 
    }
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    return [[LocalFacebookUser localFacebookUser] handleOpenURL:url];
}

@end
