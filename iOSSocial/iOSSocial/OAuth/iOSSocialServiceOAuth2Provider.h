//
//  iOSSocialServiceOAuth2Provider.h
//  iOSSocial
//
//  Created by Christopher White on 7/26/11.
//  Copyright 2011 Mad Races, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "iOSSocialOAuth.h"

@class GTMOAuth2Authentication;
@class GTMOAuthAuthenticationWithAdditions;
@interface iOSSocialServiceOAuth2Provider : NSObject

@property(nonatomic, readonly, retain) NSString *keychainItemName;

// See iOSSocialServiceOAuth2ProviderConstants.h for the Keys for this dictionary.
- (id)initWithDictionary:(NSDictionary*)dictionary;

- (id)checkAuthenticationForKeychainItemName:(NSString*)theKeychainItemName;

- (void)assignOAuthParams:(NSDictionary*)params;

- (void)authorizeFromViewController:(UIViewController*)vc 
                            forAuth:(GTMOAuth2Authentication*)theAuth 
                andKeychainItemName:(NSString*)theKeychainItemName 
                    andCookieDomain:(NSString*)cookieDomain
              withCompletionHandler:(AuthorizationHandler)completionHandler;

- (void)logout:(GTMOAuth2Authentication*)theAuth forKeychainItemName:(NSString*)theKeychainItemName;

- (NSString*)apiKey;

- (NSString*)apiSecret;

+ (id)JSONFromData:(NSData*)data;

@end
