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
@interface iOSSocialServiceOAuth2Provider : NSObject

// See iOSSocialServiceOAuth2ProviderConstants.h for the Keys for this dictionary.
- (id)initWithDictionary:(NSDictionary*)dictionary;

- (GTMOAuth2Authentication*)checkAuthenticationForKeychainItemName:(NSString*)theKeychainItemName;

- (void)assignOAuthParams:(NSDictionary*)params;

- (void)authorizeFromViewController:(UIViewController*)vc 
                            forAuth:(GTMOAuth2Authentication*)theAuth 
                andKeychainItemName:(NSString*)theKeychainItemName 
                    andCookieDomain:(NSString*)cookieDomain
              withCompletionHandler:(AuthorizationHandler)completionHandler;

- (void)logout:(GTMOAuth2Authentication*)theAuth forKeychainItemName:(NSString*)theKeychainItemName;

@end
