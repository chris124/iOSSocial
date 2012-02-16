/*
 * Copyright 2011 Mad Races, Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "iOSSocialOAuth.h"

@class GTMOAuthAuthenticationWithAdditions;
@interface iOSSocialServiceOAuth1Provider : NSObject

@property(nonatomic, readonly, retain) NSString *keychainItemName;

- (id)initWithDictionary:(NSDictionary*)dictionary;

- (id)checkAuthenticationForKeychainItemName:(NSString*)theKeychainItemName;

- (void)assignOAuthParams:(NSDictionary*)params;

- (UIViewController*)authorizeFromViewController:(UIViewController*)vc 
                                         forAuth:(id)theAuth 
                             andKeychainItemName:(NSString*)theKeychainItemName 
                                 andCookieDomain:(NSString*)cookieDomain
                           withCompletionHandler:(AuthorizationHandler)completionHandler;

- (void)logout:(GTMOAuthAuthenticationWithAdditions*)theAuth forKeychainItemName:(NSString*)theKeychainItemName;

- (NSString*)apiKey;

- (NSString*)apiSecret;

+ (id)JSONFromData:(NSData*)data;

@end
