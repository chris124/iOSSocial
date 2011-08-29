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

@class GTMOAuthAuthentication;
@interface iOSSocialServiceOAuth1Provider : NSObject

- (id)initWithDictionary:(NSDictionary*)dictionary;

- (GTMOAuthAuthentication*)checkAuthenticationForKeychainItemName:(NSString*)theKeychainItemName;

- (void)assignOAuthParams:(NSDictionary*)params;

- (void)authorizeFromViewController:(UIViewController*)vc 
                            forAuth:(GTMOAuthAuthentication*)theAuth 
                andKeychainItemName:(NSString*)theKeychainItemName 
                    andCookieDomain:(NSString*)cookieDomain
              withCompletionHandler:(AuthorizationHandler)completionHandler;

- (void)logout:(GTMOAuthAuthentication*)theAuth forKeychainItemName:(NSString*)theKeychainItemName;

@end
