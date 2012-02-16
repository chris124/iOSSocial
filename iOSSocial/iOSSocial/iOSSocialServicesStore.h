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
@class GTMOAuth2Authentication;
@protocol iOSSocialLocalUserProtocol;

@protocol iOSSocialServiceProtocol <NSObject>

@required

@property(nonatomic, readonly, retain)  NSString *name;
@property(nonatomic, readonly, retain)  UIImage *logoImage;
@property(nonatomic, readonly, assign)  BOOL primary;

+ (id<iOSSocialServiceProtocol>)sharedService;

// This must be called before calling any of the non-class methods on a service otherwise it will cause an assertion.
// See iOSSocialServiceOAuth2ProviderConstants.h or iOSSocialServiceOAuthProviderConstants.h for the Keys for this dictionary.
- (void)assignOAuthParams:(NSDictionary*)params asPrimary:(BOOL)isPrimary;

- (id<iOSSocialLocalUserProtocol>)localUser;

- (id<iOSSocialLocalUserProtocol>)localUserWithDictionary:(NSDictionary*)dictionary;

- (id<iOSSocialLocalUserProtocol>)localUserWithIdentifier:(NSString*)uuid;

- (NSString*)apiKey;

- (NSString*)apiSecret;

- (NSString*)serviceKeychainItemName;

@optional

- (NSString*)apiScope;

- (UIViewController*)authorizeFromViewController:(UIViewController*)vc 
                            forAuth:(id)theAuth 
                andKeychainItemName:(NSString*)theKeychainItemName 
                    andCookieDomain:(NSString*)cookieDomain
              withCompletionHandler:(AuthorizationHandler)completionHandler;

- (void)logout:(id)theAuth forKeychainItemName:(NSString*)theKeychainItemName;

- (id)checkAuthenticationForKeychainItemName:(NSString*)theKeychainItemName;

+ (id)JSONFromData:(NSData*)data;

- (NSString*)urlSchemeSuffix;

@end

@interface iOSSocialServicesStore : NSObject

@property(nonatomic, readonly, retain)  NSMutableArray *services;
@property(nonatomic, readonly, retain)  NSMutableArray *accounts;
@property(nonatomic, readonly, retain)  id<iOSSocialLocalUserProtocol> defaultAccount;

+ (iOSSocialServicesStore*)sharedServiceStore;

- (id<iOSSocialServiceProtocol>)serviceWithType:(NSString*)serviceName;

- (id<iOSSocialLocalUserProtocol>)accountWithType:(NSString*)accountName;

- (id<iOSSocialLocalUserProtocol>)accountWithDictionary:(NSDictionary*)accountDictionary;

- (void)registerService:(id<iOSSocialServiceProtocol>)theService;

- (void)registerAccount:(id<iOSSocialLocalUserProtocol>)theAccount;

- (void)unregisterAccount:(id<iOSSocialLocalUserProtocol>)theAccount;

- (void)unregisterAccounts;

@end
