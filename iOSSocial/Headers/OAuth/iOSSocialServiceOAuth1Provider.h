//
//  iOSSocialServiceOAuth1Provider.h
//  iOSSocial
//
//  Created by Christopher White on 7/26/11.
//  Copyright 2011 Mad Races, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "iOSSocialOAuth.h"

@class GTMOAuthAuthenticationWithAdditions;
@interface iOSSocialServiceOAuth1Provider : NSObject

- (id)initWithDictionary:(NSDictionary*)dictionary;

- (GTMOAuthAuthenticationWithAdditions*)checkAuthenticationForKeychainItemName:(NSString*)theKeychainItemName;

- (void)assignOAuthParams:(NSDictionary*)params;

- (void)authorizeFromViewController:(UIViewController*)vc 
                            forAuth:(GTMOAuthAuthenticationWithAdditions*)theAuth 
                andKeychainItemName:(NSString*)theKeychainItemName 
                    andCookieDomain:(NSString*)cookieDomain
              withCompletionHandler:(AuthorizationHandler)completionHandler;

- (void)logout:(GTMOAuthAuthenticationWithAdditions*)theAuth forKeychainItemName:(NSString*)theKeychainItemName;

- (NSString*)apiKey;

- (NSString*)apiSecret;

- (NSString*)authorizationHeaderForRequest:(NSURLRequest *)request withAuth:(GTMOAuthAuthenticationWithAdditions*)auth;

+ (id)JSONFromData:(NSData*)data;

@end
